#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "claude-agent-sdk>=0.1.72",
# ]
# ///
"""memory_compile.py — distill session log concepts into PARA notes.

Reads a session log, extracts durable concepts via Claude Agent SDK, runs
search-before-write (qmd query) for each, and proposes:
  - "new-note"     — create a new note in 3 - Resources/<subfolder>/
  - "append-to"    — append a dated section to an existing agent note
  - "moc-backlink" — match exists in a HUMAN note; never modify it, log a
                      backlink in MOCs/Claude Memory MOC.md instead

Default: --dry-run (print plan, write nothing). Real writes require --apply
AND interactive confirmation. Pass --yes to skip the prompt for scripted runs.

Usage:
  uv run ~/.dotfiles/.claude/scripts/memory_compile.py                 # dry-run for today
  uv run ~/.dotfiles/.claude/scripts/memory_compile.py --date 2026-05-03
  uv run ~/.dotfiles/.claude/scripts/memory_compile.py --apply         # interactive confirm
  uv run ~/.dotfiles/.claude/scripts/memory_compile.py --apply --yes   # no prompt
"""

from __future__ import annotations

import argparse
import asyncio
import json
import re
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import date, datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "hooks" / "lib"))
from memory_common import (  # noqa: E402
    MOC_FILE,
    RESOURCES_DIR,
    STATE_DIR,
    VAULT_PATH,
    is_auto_write_allowed,
    is_inside_vault,
    session_log_path,
)

COMPILE_STATE = STATE_DIR / "memory-compile-processed.json"

QMD_MATCH_THRESHOLD = 0.55  # below this, treat as no-match
EXTRACT_PROMPT = """You are reading a Claude Code session log and extracting durable concepts
worth preserving as standalone notes in a PARA-organized Obsidian vault.

For each concept found, output ONE JSON object per line (NDJSON), with keys:
  - "topic": short topic name (3-6 words, will become the note title)
  - "summary": 2-4 sentence summary of the durable insight
  - "suggested_subfolder": one of the existing 3 - Resources/ subfolders
    (e.g. "Coding", "Communication", "Obsidian", "Articles", "Reflections", "Thoughts").
    Pick the closest fit. If genuinely none fits, use "Coding".
  - "tags": list of 1-3 short kebab-case tags (excluding "claude-memory")

If nothing in the session is durable enough to warrant a note, output an empty line.

Rules:
- Concepts must be reusable knowledge, not session-specific events.
- "Decided to use X" is a concept; "ran X command at 14:23" is not.
- Skip pleasantries, debugging steps, ephemeral state.
- 0-5 concepts per session is normal; 0 is fine.

Session log follows:
---
"""


@dataclass
class Concept:
    topic: str
    summary: str
    suggested_subfolder: str
    tags: list[str] = field(default_factory=list)


@dataclass
class PlannedAction:
    action: str  # "new-note", "append-to", "moc-backlink"
    concept: Concept
    target_path: Path | None = None
    score: float = 0.0
    reason: str = ""


def load_processed_state() -> dict:
    if not COMPILE_STATE.exists():
        return {}
    try:
        return json.loads(COMPILE_STATE.read_text())
    except Exception:
        return {}


def save_processed_state(state: dict) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    COMPILE_STATE.write_text(json.dumps(state, indent=2))


# ──────────────────────────────────────────────────────────────────────────────
# Concept extraction via Claude Agent SDK


async def extract_concepts(session_log_text: str) -> list[Concept]:
    from claude_agent_sdk import (
        AssistantMessage,
        ClaudeAgentOptions,
        TextBlock,
        query,
    )

    options = ClaudeAgentOptions(
        model="claude-haiku-4-5-20251001",
        max_turns=1,
        system_prompt="You output NDJSON only — one JSON object per line, no preamble, no fences.",
    )
    full_prompt = EXTRACT_PROMPT + session_log_text

    raw: list[str] = []
    async for msg in query(prompt=full_prompt, options=options):
        if isinstance(msg, AssistantMessage):
            for block in msg.content:
                if isinstance(block, TextBlock):
                    raw.append(block.text)
    text = "".join(raw).strip()
    text = re.sub(r"^```(?:json|ndjson)?\n", "", text)
    text = re.sub(r"\n```$", "", text)

    concepts: list[Concept] = []
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
            concepts.append(
                Concept(
                    topic=str(obj.get("topic", "")).strip(),
                    summary=str(obj.get("summary", "")).strip(),
                    suggested_subfolder=str(obj.get("suggested_subfolder", "Coding")).strip(),
                    tags=[str(t).strip() for t in obj.get("tags", [])],
                )
            )
        except Exception as exc:
            print(f"compile: skipped malformed line: {line[:80]}... ({exc})", file=sys.stderr)

    return [c for c in concepts if c.topic and c.summary]


# ──────────────────────────────────────────────────────────────────────────────
# Search-before-write via QMD


def qmd_query(topic: str, n: int = 5) -> list[dict]:
    try:
        result = subprocess.run(
            ["qmd", "query", topic, "--json", "-n", str(n)],
            capture_output=True,
            text=True,
            timeout=60,
        )
        if result.returncode != 0:
            print(f"compile: qmd query failed for '{topic}': {result.stderr}", file=sys.stderr)
            return []
        # qmd writes progress to stderr; stdout is pure JSON
        return json.loads(result.stdout)
    except Exception as exc:
        print(f"compile: qmd query exception for '{topic}': {exc}", file=sys.stderr)
        return []


def qmd_uri_to_filesystem_path(uri: str) -> Path | None:
    """Convert qmd://vault/<lowercased-hyphenated-path>.md to actual filesystem path.
    Strategy: case-insensitive search by basename, then by parent-dir hint.
    """
    if not uri.startswith("qmd://vault/"):
        return None
    relative = uri[len("qmd://vault/"):]
    basename_lower = Path(relative).stem.lower()

    candidates: list[Path] = []
    for md in VAULT_PATH.rglob("*.md"):
        if md.stem.lower().replace(" ", "-") == basename_lower:
            candidates.append(md)
        elif md.stem.lower() == basename_lower.replace("-", " "):
            candidates.append(md)
    if not candidates:
        # last resort — exact stem match ignoring hyphens/spaces
        for md in VAULT_PATH.rglob("*.md"):
            if md.stem.lower().replace(" ", "").replace("-", "") == basename_lower.replace("-", "").replace(" ", ""):
                candidates.append(md)
    if not candidates:
        return None
    if len(candidates) == 1:
        return candidates[0]
    # Prefer candidate whose parent dir matches the URI's parent
    uri_parent = "/".join(relative.split("/")[:-1]).lower()
    for cand in candidates:
        cand_parent = str(cand.parent.relative_to(VAULT_PATH)).lower().replace(" ", "-")
        if uri_parent in cand_parent or cand_parent in uri_parent:
            return cand
    return candidates[0]


FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)


def has_claude_memory_frontmatter(path: Path) -> bool:
    try:
        head = path.read_text()[:2000]
    except Exception:
        return False
    m = FRONTMATTER_RE.match(head)
    if not m:
        return False
    return re.search(r"^source:\s*claude-memory\s*$", m.group(1), re.MULTILINE) is not None


# ──────────────────────────────────────────────────────────────────────────────
# Planning


def plan_for_concept(concept: Concept, session_date: date) -> PlannedAction:
    results = qmd_query(concept.topic, n=5)
    if not results:
        return _plan_new_note(concept, session_date)

    top = results[0]
    score = float(top.get("score", 0))
    if score < QMD_MATCH_THRESHOLD:
        return _plan_new_note(concept, session_date, score=score)

    target = qmd_uri_to_filesystem_path(top.get("file", ""))
    if target is None:
        return _plan_new_note(
            concept,
            session_date,
            score=score,
            reason=f"qmd score {score:.2f} but path resolution failed",
        )

    if has_claude_memory_frontmatter(target):
        return PlannedAction(
            action="append-to",
            concept=concept,
            target_path=target,
            score=score,
            reason=f"prior agent note (score {score:.2f})",
        )

    # Human note → MOC backlink only
    return PlannedAction(
        action="moc-backlink",
        concept=concept,
        target_path=target,
        score=score,
        reason=f"human note (score {score:.2f}) — no modification",
    )


def _plan_new_note(concept: Concept, session_date: date, score: float = 0.0, reason: str = "") -> PlannedAction:
    subfolder = concept.suggested_subfolder
    target = RESOURCES_DIR / subfolder / _safe_filename(concept.topic)
    return PlannedAction(
        action="new-note",
        concept=concept,
        target_path=target,
        score=score,
        reason=reason or "no qmd match above threshold",
    )


def _safe_filename(topic: str) -> str:
    # Title-cased, spaces preserved, strip invalid filesystem chars
    safe = re.sub(r"[^\w\s\-]", "", topic).strip()
    return safe + ".md"


# ──────────────────────────────────────────────────────────────────────────────
# Execution


def render_new_note(concept: Concept, session_date: date) -> str:
    tags = ["claude-memory"] + concept.tags
    tags_yaml = "[" + ", ".join(tags) + "]"
    return (
        f"---\n"
        f"source: claude-memory\n"
        f"created: {session_date.isoformat()}\n"
        f'session-log: "[[{session_date.isoformat()}]]"\n'
        f"tags: {tags_yaml}\n"
        f"---\n\n"
        f"# {concept.topic}\n\n"
        f"{concept.summary}\n\n"
        f"## Source\n\n"
        f"Promoted from session log [[2 - Areas/Daily Ops/{session_date.year}/Claude Sessions/{session_date.isoformat()}|{session_date.isoformat()}]].\n"
    )


def render_append(concept: Concept, session_date: date) -> str:
    return (
        f"\n## {session_date.isoformat()} update\n\n"
        f"{concept.summary}\n\n"
        f"_Promoted from [[2 - Areas/Daily Ops/{session_date.year}/Claude Sessions/{session_date.isoformat()}|session {session_date.isoformat()}]]._\n"
    )


def render_moc_backlink(action: PlannedAction, session_date: date) -> str:
    target_rel = (
        action.target_path.relative_to(VAULT_PATH).as_posix()
        if action.target_path
        else action.concept.topic
    )
    target_stem = action.target_path.stem if action.target_path else action.concept.topic
    return (
        f"- **{action.concept.topic}** ({session_date.isoformat()}) — see existing note [[{target_stem}]]"
        f" ({target_rel}). _{action.concept.summary}_\n"
    )


def execute_plan(actions: list[PlannedAction], session_date: date) -> None:
    for a in actions:
        if a.target_path is None:
            continue

        if a.action == "new-note":
            if not _confirm_target(a.target_path, "new-note"):
                print(f"  ✗ skipped (write-guard or out-of-vault): {a.target_path}", file=sys.stderr)
                continue
            a.target_path.parent.mkdir(parents=True, exist_ok=True)
            a.target_path.write_text(render_new_note(a.concept, session_date))
            print(f"  ✓ wrote {a.target_path.relative_to(VAULT_PATH)}")

        elif a.action == "append-to":
            if not _confirm_target(a.target_path, "append-to"):
                print(f"  ✗ skipped (write-guard or out-of-vault): {a.target_path}", file=sys.stderr)
                continue
            with open(a.target_path, "a") as f:
                f.write(render_append(a.concept, session_date))
            print(f"  ✓ appended to {a.target_path.relative_to(VAULT_PATH)}")

        elif a.action == "moc-backlink":
            backlink = render_moc_backlink(a, session_date)
            _append_to_moc(backlink)
            print(f"  ✓ MOC backlink → {a.target_path.relative_to(VAULT_PATH) if a.target_path else '?'}")


def _confirm_target(path: Path, action: str) -> bool:
    """Belt-and-braces: even after user approval, refuse to write outside the vault.

    For new-note and append-to into PARA, the user already approved interactively.
    This guard catches accidental path bugs (e.g. trying to write to /tmp).
    """
    if not is_inside_vault(path):
        return False
    return True


def _append_to_moc(line: str) -> None:
    if not is_auto_write_allowed(MOC_FILE):
        print(f"compile: write-guard rejected {MOC_FILE}", file=sys.stderr)
        return
    if not MOC_FILE.exists():
        MOC_FILE.parent.mkdir(parents=True, exist_ok=True)
        MOC_FILE.write_text("# Claude Memory MOC\n\n## Recent entries\n\n")
    text = MOC_FILE.read_text()
    if "## Recent entries" not in text:
        text += "\n## Recent entries\n\n"
    insert_at = text.index("## Recent entries") + len("## Recent entries\n\n")
    new_text = text[:insert_at] + line + text[insert_at:]
    MOC_FILE.write_text(new_text)


# ──────────────────────────────────────────────────────────────────────────────
# Main


def print_plan(actions: list[PlannedAction]) -> None:
    print(f"\nPlanned actions ({len(actions)}):\n")
    for i, a in enumerate(actions, 1):
        target = (
            str(a.target_path.relative_to(VAULT_PATH)) if a.target_path else "(no path)"
        )
        print(f"{i}. [{a.action}] {a.concept.topic}")
        print(f"   → {target}")
        print(f"   reason: {a.reason}")
        print(f"   summary: {a.concept.summary[:120]}{'…' if len(a.concept.summary) > 120 else ''}")
        if a.concept.tags:
            print(f"   tags: {', '.join(a.concept.tags)}")
        print()


def main() -> int:
    parser = argparse.ArgumentParser(description="Distill session log into PARA concept notes.")
    parser.add_argument("--date", help="Session log date (YYYY-MM-DD). Default: today.")
    parser.add_argument("--apply", action="store_true", help="Execute the plan (with confirmation).")
    parser.add_argument("--yes", action="store_true", help="Skip interactive confirmation. Requires --apply.")
    parser.add_argument("--force", action="store_true", help="Re-process even if already done.")
    args = parser.parse_args()

    if args.yes and not args.apply:
        print("--yes requires --apply", file=sys.stderr)
        return 2

    target = (
        datetime.strptime(args.date, "%Y-%m-%d").date()
        if args.date
        else date.today()
    )

    log_path = session_log_path(target)
    if not log_path.exists():
        print(f"compile: no session log at {log_path}", file=sys.stderr)
        return 0

    state = load_processed_state()
    log_mtime = str(int(log_path.stat().st_mtime))
    if not args.force and state.get(target.isoformat()) == log_mtime:
        print(f"compile: already processed {target} (use --force to re-run)", file=sys.stderr)
        return 0

    log_text = log_path.read_text()
    if len(log_text.strip()) < 200:
        print(f"compile: session log for {target} too short ({len(log_text)} chars), skipping", file=sys.stderr)
        return 0

    print(f"compile: extracting concepts from {log_path.relative_to(VAULT_PATH)}…")
    try:
        concepts = asyncio.run(extract_concepts(log_text))
    except Exception as exc:
        print(f"compile: SDK extract failed: {exc}", file=sys.stderr)
        return 1

    if not concepts:
        print("compile: no durable concepts extracted")
        return 0

    print(f"compile: {len(concepts)} concept(s) extracted; running search-before-write…")
    actions = [plan_for_concept(c, target) for c in concepts]
    print_plan(actions)

    if not args.apply:
        print("(dry-run — pass --apply to execute, or --apply --yes to skip the prompt)")
        return 0

    if not args.yes:
        try:
            response = input("Apply this plan? [y/N] ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            response = ""
        if response not in {"y", "yes"}:
            print("Aborted.")
            return 0

    execute_plan(actions, target)

    state[target.isoformat()] = log_mtime
    save_processed_state(state)
    print(f"\ncompile: done. Processed {target}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
