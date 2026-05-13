#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "claude-agent-sdk>=0.1.72",
#   "google-api-python-client>=2.0",
#   "google-auth>=2.0",
#   "google-auth-oauthlib>=1.0",
#   "jira>=3.5",
# ]
# ///
"""Proactive heartbeat monitor.

Runs on launchd schedule (see ~/Library/LaunchAgents/com.kriscard.heartbeat.*).
For each run:
  1. GATHER  — Python pulls data from integrations (no LLM, ~free).
  2. DIFF    — compare against last snapshot, only act on NEW items.
  3. REASON  — Agent SDK summarizes new items via HEARTBEAT.md rules.
  4. NOTIFY  — macOS notification with one-line summary.
  5. ARCHIVE — full summary written to vault/2 - Areas/Daily Ops/<year>/Heartbeat/.

Modes:
  --mode morning   first run of the day; includes calendar + counts
  --mode jira      weekday Jira-only check
  --mode gmail     weekday Gmail triage
  --mode github    weekday PR sweep
  --mode linear    Monday weekly check
  --mode all       all sources (manual test)
"""

from __future__ import annotations

import argparse
import asyncio
import json
import os
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import date, datetime
from pathlib import Path

# Make integrations importable
SCRIPTS_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPTS_DIR))

from integrations import github, gmail, jira_api  # noqa: E402

VAULT_PATH = Path("/Users/kriscard/obsidian-vault-kriscard")
HEARTBEAT_CONFIG = VAULT_PATH / "HEARTBEAT.md"
USER_FILE = VAULT_PATH / "USER.md"
STATE_PATH = Path.home() / ".claude" / "state" / "heartbeat-state.json"
COST_LOG = Path("/tmp/heartbeat-cost.log")
COST_WARN_THRESHOLD = 0.01  # USD per run


# ──────────────────────────────────────────────────────────────────────────────
# Gather

@dataclass
class Snapshot:
    github_review_ids: list[int] = field(default_factory=list)
    github_my_pr_ids: list[int] = field(default_factory=list)
    gmail_important_ids: list[str] = field(default_factory=list)
    jira_overdue_keys: list[str] = field(default_factory=list)
    jira_in_progress_keys: list[str] = field(default_factory=list)
    jira_blocked_keys: list[str] = field(default_factory=list)


def gather_github() -> tuple[Snapshot, str]:
    snap = Snapshot()
    sections = []
    try:
        prs = github.list_review_requests()
        snap.github_review_ids = [p.number for p in prs]
        sections.append(github.format_for_context(prs, "GitHub — Review requests"))

        my = github.list_my_open_prs()
        snap.github_my_pr_ids = [p.number for p in my]
        sections.append(github.format_for_context(my, "GitHub — Your open PRs"))
    except Exception as exc:
        sections.append(f"## GitHub\n\n_error: {exc}_\n")
    return snap, "\n".join(sections)


def gather_gmail() -> tuple[Snapshot, str]:
    snap = Snapshot()
    try:
        emails = gmail.list_important_unread()
        snap.gmail_important_ids = [e.id for e in emails]
        return snap, gmail.format_for_context(emails, "Gmail — Important unread")
    except Exception as exc:
        return snap, f"## Gmail\n\n_error: {exc}_\n"


def gather_jira() -> tuple[Snapshot, str]:
    snap = Snapshot()
    sections = []
    try:
        overdue = jira_api.list_my_overdue()
        snap.jira_overdue_keys = [i.key for i in overdue]
        sections.append(jira_api.format_for_context(overdue, "Jira — Overdue"))

        ip = jira_api.list_my_in_progress()
        snap.jira_in_progress_keys = [i.key for i in ip]
        sections.append(jira_api.format_for_context(ip, "Jira — In progress"))

        blocked = jira_api.list_my_blocked()
        snap.jira_blocked_keys = [i.key for i in blocked]
        sections.append(jira_api.format_for_context(blocked, "Jira — Blocked"))
    except Exception as exc:
        sections.append(f"## Jira\n\n_error: {exc}_\n")
    return snap, "\n".join(sections)


# ──────────────────────────────────────────────────────────────────────────────
# State / Diff

def load_state() -> Snapshot:
    if not STATE_PATH.exists():
        return Snapshot()
    try:
        data = json.loads(STATE_PATH.read_text())
        return Snapshot(**data)
    except Exception:
        return Snapshot()


def save_state(snap: Snapshot) -> None:
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(json.dumps(snap.__dict__, indent=2))


def diff_new_items(prev: Snapshot, curr: Snapshot) -> dict[str, list]:
    """Return only items in curr that weren't in prev. Empty dict = nothing new."""
    prev_d = prev.__dict__
    curr_d = curr.__dict__
    new = {}
    for key, curr_vals in curr_d.items():
        prev_vals = set(prev_d.get(key, []))
        new_only = [v for v in curr_vals if v not in prev_vals]
        if new_only:
            new[key] = new_only
    return new


# ──────────────────────────────────────────────────────────────────────────────
# Reason (LLM)

PROMPT_TEMPLATE = """You are this user's morning heartbeat monitor.

Below is data fetched from their integrations. Output a SHORT markdown
summary (3-6 sentences total) of what's new and what they should know.

Follow the user's voice (from USER.md): concise, technical-educator,
peer-level, no emojis, no AI attribution.

Output ONLY the markdown summary. No preamble like "Here's your summary".

---

USER VOICE PREFERENCES (excerpt):
{voice}

---

HEARTBEAT CONFIG (what to surface):
{config}

---

NEW ITEMS THIS RUN:
{new_items_text}

---

FULL CONTEXT (for grounding):
{full_context}
"""


async def reason(new_items: dict, full_context: str, voice: str, config: str) -> str:
    from claude_agent_sdk import ClaudeAgentOptions, query

    new_items_text = "\n".join(f"- {k}: {v}" for k, v in new_items.items())
    prompt = PROMPT_TEMPLATE.format(
        voice=voice[:1500],  # keep prompt cheap
        config=config[:1500],
        new_items_text=new_items_text,
        full_context=full_context[:3000],
    )
    options = ClaudeAgentOptions(
        system_prompt="You are a concise morning monitor.",
        max_thinking_tokens=0,
    )
    parts: list[str] = []
    async for msg in query(prompt=prompt, options=options):
        text = _extract_text(msg)
        if text:
            parts.append(text)
    return "".join(parts).strip()


def _extract_text(msg) -> str:
    """Be tolerant of SDK message shapes."""
    try:
        if hasattr(msg, "content"):
            content = msg.content
            if isinstance(content, str):
                return content
            if isinstance(content, list):
                return "".join(
                    c.text if hasattr(c, "text") else ""
                    for c in content
                )
        text_attr = getattr(msg, "text", None)
        if isinstance(text_attr, str):
            return text_attr
    except Exception:
        pass
    return ""


# ──────────────────────────────────────────────────────────────────────────────
# Notify

ICON_PATH = SCRIPTS_DIR / "assets" / "heartbeat-icon.png"


def notify_macos(title: str, body: str, group: str = "heartbeat") -> None:
    """Display a macOS banner via terminal-notifier when available, else osascript.

    `terminal-notifier` gives a custom app icon and groups successive runs
    so each new run replaces the previous notification rather than stacking.
    Falls back to osascript (Script Editor icon) if terminal-notifier isn't
    installed — system still works, just less polished.
    """
    short = body[:300].replace("\n", " — ")
    if len(body) > 300:
        short += "…"

    if _has_terminal_notifier():
        cmd = [
            "terminal-notifier",
            "-title", title,
            "-message", short,
            "-sound", "Pop",
            "-group", group,
        ]
        if ICON_PATH.exists():
            cmd += ["-appIcon", str(ICON_PATH)]
        try:
            subprocess.run(cmd, check=False, timeout=5)
            return
        except Exception as exc:
            print(f"heartbeat: terminal-notifier failed ({exc}); falling back to osascript", file=sys.stderr)

    # Fallback: AppleScript display notification (no custom icon)
    safe = short.replace('"', '\\"')
    try:
        subprocess.run(
            ["osascript", "-e", f'display notification "{safe}" with title "{title}" sound name "Pop"'],
            check=False,
            timeout=5,
        )
    except Exception as exc:
        print(f"heartbeat: notification failed: {exc}", file=sys.stderr)


def _has_terminal_notifier() -> bool:
    from shutil import which

    return which("terminal-notifier") is not None


def archive_summary(mode: str, summary: str, full_context: str) -> Path:
    today = date.today()
    archive_dir = VAULT_PATH / "2 - Areas" / "Daily Ops" / f"{today.year}" / "Heartbeat"
    archive_dir.mkdir(parents=True, exist_ok=True)
    path = archive_dir / f"{today.isoformat()}-{mode}.md"
    body = (
        f"---\ndate: {today.isoformat()}\nmode: {mode}\ntags: [heartbeat]\n---\n\n"
        f"# Heartbeat {mode.title()} — {today.isoformat()}\n\n"
        f"## Summary\n\n{summary}\n\n"
        f"## Full context\n\n{full_context}\n"
    )
    path.write_text(body)
    return path


# ──────────────────────────────────────────────────────────────────────────────
# Orchestrate

async def run(mode: str) -> int:
    if not HEARTBEAT_CONFIG.exists():
        print(f"heartbeat: config missing at {HEARTBEAT_CONFIG}", file=sys.stderr)
        return 1
    config = HEARTBEAT_CONFIG.read_text()
    voice = USER_FILE.read_text() if USER_FILE.exists() else ""

    # 1. GATHER (only the sources relevant to mode)
    snap = Snapshot()
    full_sections: list[str] = []

    if mode in ("morning", "all", "github"):
        s, text = gather_github()
        _merge(snap, s)
        full_sections.append(text)
    if mode in ("morning", "all", "gmail"):
        s, text = gather_gmail()
        _merge(snap, s)
        full_sections.append(text)
    if mode in ("morning", "all", "jira"):
        s, text = gather_jira()
        _merge(snap, s)
        full_sections.append(text)
    # Linear + Calendar deferred (Phase 4.5)

    full_context = "\n".join(full_sections)

    # 2. DIFF
    prev = load_state()
    new_items = diff_new_items(prev, snap)
    if not new_items:
        print("heartbeat: no new items since last run")
        return 0
    print(f"heartbeat: {sum(len(v) for v in new_items.values())} new items across {len(new_items)} categories")

    # 3. REASON
    try:
        summary = await reason(new_items, full_context, voice, config)
    except Exception as exc:
        print(f"heartbeat: SDK reason failed: {exc}", file=sys.stderr)
        # Still notify with the raw new-items list as a fallback
        summary = "Heartbeat reasoning failed; new items:\n" + json.dumps(new_items, indent=2)

    # 4. NOTIFY
    notify_macos(title=f"Heartbeat — {mode}", body=summary)

    # 5. ARCHIVE
    archived = archive_summary(mode, summary, full_context)
    print(f"heartbeat: archived to {archived}")

    # 6. SAVE STATE
    save_state(snap)
    return 0


def _merge(target: Snapshot, source: Snapshot) -> None:
    for key, val in source.__dict__.items():
        if val:
            setattr(target, key, val)


def main() -> int:
    parser = argparse.ArgumentParser(description="Proactive heartbeat monitor")
    parser.add_argument(
        "--mode",
        choices=["morning", "jira", "gmail", "github", "linear", "all"],
        default="morning",
        help="Which sources to gather and reason over",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Gather + diff + print summary; do not notify or archive or save state.",
    )
    args = parser.parse_args()

    if args.dry_run:
        print("(dry-run mode — no notification, no archive, no state update)")
        # Run without side effects
        async def _dry():
            snap = Snapshot()
            sections = []
            if args.mode in ("morning", "all", "github"):
                s, t = gather_github()
                _merge(snap, s)
                sections.append(t)
            if args.mode in ("morning", "all", "gmail"):
                s, t = gather_gmail()
                _merge(snap, s)
                sections.append(t)
            if args.mode in ("morning", "all", "jira"):
                s, t = gather_jira()
                _merge(snap, s)
                sections.append(t)
            print("\n".join(sections))
            prev = load_state()
            new = diff_new_items(prev, snap)
            print("\n--- new vs. last snapshot ---")
            print(json.dumps(new, indent=2))
            return 0
        return asyncio.run(_dry())

    return asyncio.run(run(args.mode))


if __name__ == "__main__":
    sys.exit(main())
