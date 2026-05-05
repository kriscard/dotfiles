#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""PreCompact hook — captures conversation transcript before auto-compaction.

When Claude Code's context window fills up, it auto-compacts (summarizes and
discards detail). This hook fires BEFORE that happens, extracting conversation
context and spawning memory_flush.py to extract knowledge that would otherwise
be lost to summarization.

The hook itself does NO API calls — only local file I/O for speed (<10s).

Recursion guard: same as SessionEnd — exit immediately when invoked from
within a memory_flush.py-spawned Agent SDK child process.
"""

from __future__ import annotations

import logging
import os
import sys

# Recursion guard MUST run before any other work.
if os.environ.get("CLAUDE_INVOKED_BY"):
    sys.exit(0)

import json
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "lib"))
from memory_common import (  # noqa: E402
    STATE_DIR,
    extract_conversation_context,
    spawn_flush,
)

LOG_FILE = STATE_DIR / "memory_hook.log"

STATE_DIR.mkdir(parents=True, exist_ok=True)
logging.basicConfig(
    filename=str(LOG_FILE),
    level=logging.INFO,
    format="%(asctime)s %(levelname)s [pre-compact] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

# Higher threshold than SessionEnd: don't burn a flush on a 4-turn warm-up
# that happens to trip the context window. If you're compacting, the
# conversation usually has substance worth preserving.
MIN_TURNS_TO_FLUSH = 5


def main() -> None:
    try:
        hook_input = json.load(sys.stdin)
    except Exception as exc:
        logging.error("invalid stdin JSON: %s", exc)
        return

    session_id = hook_input.get("session_id", "unknown")
    transcript_path_str = hook_input.get("transcript_path", "")
    cwd = hook_input.get("cwd", "")

    logging.info("PreCompact fired: session=%s cwd=%s", session_id, cwd)

    if not transcript_path_str:
        # Known Claude Code bug: PreCompact sometimes ships an empty
        # transcript_path. Nothing actionable, just log and bail.
        logging.info("SKIP: no transcript path")
        return
    transcript_path = Path(transcript_path_str)
    if not transcript_path.exists():
        logging.info("SKIP: transcript missing: %s", transcript_path_str)
        return

    try:
        context, turn_count = extract_conversation_context(transcript_path)
    except Exception as exc:
        logging.error("context extraction failed: %s", exc)
        return

    if not context.strip():
        logging.info("SKIP: empty context")
        return
    if turn_count < MIN_TURNS_TO_FLUSH:
        logging.info("SKIP: %d turns < %d", turn_count, MIN_TURNS_TO_FLUSH)
        return

    project_name = Path(cwd).name or "ad-hoc"
    hhmm = datetime.now().strftime("%H:%M")

    spawn_flush(context, session_id, project_name, hhmm)


if __name__ == "__main__":
    main()
