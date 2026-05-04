#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "claude-agent-sdk>=0.1.72",
# ]
# ///
"""memory_reflect.py — daily memory consolidation.

Reads yesterday's `Claude Sessions/YYYY-MM-DD.md` and promotes durable facts
(decisions, lessons, evergreen takeaways) to `<vault>/MEMORY.md`.

Auto-write: MEMORY.md is in the auto-write set per AGENTS.md, so this runs
without per-write user approval. Idempotent via state file.

Usage:
  uv run ~/.dotfiles/.claude/scripts/memory_reflect.py            # process yesterday
  uv run ~/.dotfiles/.claude/scripts/memory_reflect.py --date 2026-05-03
  uv run ~/.dotfiles/.claude/scripts/memory_reflect.py --dry-run
"""

from __future__ import annotations

import argparse
import asyncio
import json
import re
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "hooks" / "lib"))
from memory_common import (  # noqa: E402
    MEMORY_ARCHIVE,
    MEMORY_FILE,
    STATE_DIR,
    is_auto_write_allowed,
    session_log_path,
)

REFLECTION_STATE = STATE_DIR / "memory-reflection-processed.json"
MEMORY_TOKEN_CAP = 1000  # ~4000 chars
MEMORY_CHAR_CAP = MEMORY_TOKEN_CAP * 4

REFLECT_PROMPT = """You are reading a Claude Code session log for a single day.
Your job is to extract DURABLE facts that should outlive the conversation —
things worth remembering weeks or months from now.

What counts as durable:
- Decisions made (architectural, tactical, lifestyle, project-level)
- Lessons learned (gotchas, surprising discoveries, "next time" rules)
- Evergreen takeaways (named concepts, patterns, principles)
- Stable user preferences revealed in the session

What does NOT count:
- Trivial chatter, pleasantries
- One-off debugging steps without a generalizable lesson
- Volatile state ("I'm working on X today")

Output Markdown, no preamble, exactly this structure:

### Decisions
- <bullet> — <terse reason if non-obvious>

### Lessons
- <bullet>

### Takeaways
- <bullet> (named concept or pattern)

If a section has nothing worth promoting, write `- _(none)_` under it.

Session log follows:
---
"""


def load_processed_state() -> dict:
    if not REFLECTION_STATE.exists():
        return {}
    try:
        return json.loads(REFLECTION_STATE.read_text())
    except Exception:
        return {}


def save_processed_state(state: dict) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    REFLECTION_STATE.write_text(json.dumps(state, indent=2))


async def reflect_via_sdk(session_log_text: str) -> str:
    from claude_agent_sdk import (
        AssistantMessage,
        ClaudeAgentOptions,
        TextBlock,
        query,
    )

    options = ClaudeAgentOptions(
        model="claude-haiku-4-5-20251001",
        max_turns=1,
        system_prompt="You produce terse Markdown summaries. No commentary, no preamble.",
    )
    full_prompt = REFLECT_PROMPT + session_log_text

    chunks: list[str] = []
    async for msg in query(prompt=full_prompt, options=options):
        if isinstance(msg, AssistantMessage):
            for block in msg.content:
                if isinstance(block, TextBlock):
                    chunks.append(block.text)
    return "".join(chunks).strip()


def append_to_memory(reflection_md: str, target_date: date) -> None:
    if not is_auto_write_allowed(MEMORY_FILE):
        print(f"reflect: write-guard rejected {MEMORY_FILE}", file=sys.stderr)
        return

    if not MEMORY_FILE.exists():
        MEMORY_FILE.write_text("# MEMORY — Curated Long-Term Facts\n\n")

    section = f"\n## {target_date.isoformat()} Reflection\n\n{reflection_md.strip()}\n"
    with open(MEMORY_FILE, "a") as f:
        f.write(section)


def cap_memory_and_archive() -> None:
    """If MEMORY.md exceeds the token cap, roll oldest dated reflection sections into the archive."""
    if not MEMORY_FILE.exists():
        return

    text = MEMORY_FILE.read_text()
    if len(text) <= MEMORY_CHAR_CAP:
        return

    section_re = re.compile(r"(?=^## \d{4}-\d{2}-\d{2} Reflection\b)", re.MULTILINE)
    splits = section_re.split(text)
    if len(splits) <= 2:
        return  # only header + one section, nothing to roll

    header = splits[0]
    sections = splits[1:]

    # Archive oldest until under cap
    archived: list[str] = []
    while len(header + "".join(sections)) > MEMORY_CHAR_CAP and sections:
        archived.append(sections.pop(0))

    if not archived:
        return

    if MEMORY_ARCHIVE.exists():
        archive_text = MEMORY_ARCHIVE.read_text()
    else:
        archive_text = "# MEMORY — Archive\n\nOlder reflections rolled out of MEMORY.md to keep the live file under the token cap.\n\n"

    archive_text += "".join(archived)

    if is_auto_write_allowed(MEMORY_ARCHIVE):
        MEMORY_ARCHIVE.write_text(archive_text)
        MEMORY_FILE.write_text(header + "".join(sections))
        print(
            f"reflect: rolled {len(archived)} oldest section(s) to MEMORY.md.archive",
            file=sys.stderr,
        )
    else:
        print(f"reflect: write-guard rejected MEMORY.md.archive", file=sys.stderr)


def main() -> int:
    parser = argparse.ArgumentParser(description="Promote durable facts from a session log to MEMORY.md")
    parser.add_argument(
        "--date",
        help="Session log date to process (YYYY-MM-DD). Default: yesterday.",
    )
    parser.add_argument("--dry-run", action="store_true", help="Print plan, do not write.")
    parser.add_argument("--force", action="store_true", help="Re-run even if already processed.")
    args = parser.parse_args()

    if args.date:
        target = datetime.strptime(args.date, "%Y-%m-%d").date()
    else:
        target = date.today() - timedelta(days=1)

    log_path = session_log_path(target)
    if not log_path.exists():
        print(f"reflect: no session log at {log_path} (nothing to reflect)", file=sys.stderr)
        return 0

    state = load_processed_state()
    if not args.force and state.get(target.isoformat()) == str(int(log_path.stat().st_mtime)):
        print(f"reflect: already processed {target} (use --force to re-run)", file=sys.stderr)
        return 0

    log_text = log_path.read_text()
    if len(log_text.strip()) < 200:
        print(f"reflect: session log for {target} too short ({len(log_text)} chars), skipping", file=sys.stderr)
        return 0

    try:
        reflection = asyncio.run(reflect_via_sdk(log_text))
    except Exception as exc:
        print(f"reflect: SDK call failed: {exc}", file=sys.stderr)
        return 1

    if not reflection:
        print("reflect: empty reflection output, skipping", file=sys.stderr)
        return 0

    if args.dry_run:
        print(f"# DRY RUN — would append to {MEMORY_FILE}\n")
        print(f"## {target.isoformat()} Reflection\n")
        print(reflection)
        return 0

    append_to_memory(reflection, target)
    cap_memory_and_archive()

    state[target.isoformat()] = str(int(log_path.stat().st_mtime))
    save_processed_state(state)

    print(f"reflect: appended reflection for {target} to MEMORY.md", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
