#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "claude-agent-sdk>=0.1.72",
# ]
# ///
"""Memory flush agent — runs out-of-band, summarizes, appends to vault session log.

Spawned as a detached subprocess by `memory_session_end.py`. Reads the
pre-extracted conversation context from a markdown file, calls Claude Agent
SDK to summarize, appends the summary to today's `Claude Sessions/<date>.md`,
and inserts a wikilink under `## 💬 Sessions` of today's daily note.

Pattern ported from coleam00/claude-memory-compiler/scripts/flush.py. Adapted
for Chris's vault-based session log destination and existing summary format
(HH:MM — project, Decisions / Lessons / Action items / Files touched).

Usage: uv run memory_flush.py <context_file.md> <session_id> <project_name> <hhmm>
"""

from __future__ import annotations

# Recursion prevention: set this BEFORE any imports that might trigger Claude.
import os
os.environ["CLAUDE_INVOKED_BY"] = "memory_flush"

import asyncio
import contextlib
import fcntl
import json
import logging
import subprocess
import sys
import time
from datetime import date, datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "hooks" / "lib"))
from memory_common import (  # noqa: E402
    STATE_DIR,
    claim_reflection_for_today,
    daily_note_path,
    is_write_path_allowed,
    session_log_path,
)

LOG_FILE = STATE_DIR / "memory_flush.log"
DEDUP_STATE = STATE_DIR / "memory-flush-last.json"
DEDUP_WINDOW_SECONDS = 60

STATE_DIR.mkdir(parents=True, exist_ok=True)
logging.basicConfig(
    filename=str(LOG_FILE),
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

SUMMARY_PROMPT = """You are summarizing a Claude Code session transcript for a long-term memory log.

Output Markdown only. Format strictly as:

## <HH:MM> — <project name>
- **Decisions:** <1-line decisions made; or "—" if none>
- **Lessons:** <durable takeaways the user/agent learned; or "—">
- **Action items:** <follow-ups carried forward; or "—">
- **Files touched:** <comma-separated paths; or "—">

Be terse. Skip pleasantries. Focus on durable content. No preamble, no closing.
If the session was trivial (greeting, typo fix, file open, no decisions) respond
with exactly: FLUSH_OK

Use this header timestamp and project name:
"""

REFLECT_SCRIPT = Path.home() / ".dotfiles" / ".claude" / "scripts" / "memory_reflect.py"


@contextlib.contextmanager
def file_lock(path: Path, timeout_seconds: int = 10):
    """Exclusive advisory lock on a sidecar file. Belt-and-braces for the
    rare case of two flushes racing on the same daily file.
    """
    lock_path = path.with_suffix(path.suffix + ".lock")
    lock_path.parent.mkdir(parents=True, exist_ok=True)
    deadline = time.time() + timeout_seconds
    f = None
    try:
        f = open(lock_path, "w")
        while True:
            try:
                fcntl.flock(f, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except BlockingIOError:
                if time.time() >= deadline:
                    logging.warning("lock timeout on %s, proceeding", lock_path)
                    break
                time.sleep(0.05)
        yield
    finally:
        if f is not None:
            try:
                fcntl.flock(f, fcntl.LOCK_UN)
            except Exception:
                pass
            f.close()


def load_dedup_state() -> dict:
    if DEDUP_STATE.exists():
        try:
            return json.loads(DEDUP_STATE.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            pass
    return {}


def save_dedup_state(state: dict) -> None:
    try:
        DEDUP_STATE.write_text(json.dumps(state), encoding="utf-8")
    except OSError as exc:
        logging.error("failed to write dedup state: %s", exc)


async def run_flush(context: str, project_name: str, hhmm: str) -> str:
    from claude_agent_sdk import (
        AssistantMessage,
        ClaudeAgentOptions,
        ResultMessage,
        TextBlock,
        query,
    )

    prompt = (
        SUMMARY_PROMPT
        + f"\nTime: {hhmm}\nProject: {project_name}\n\n---\n"
        + context
    )

    response = ""
    try:
        async for message in query(
            prompt=prompt,
            options=ClaudeAgentOptions(
                model="claude-haiku-4-5-20251001",
                allowed_tools=[],
                max_turns=2,
                system_prompt="You produce terse Markdown summaries. No commentary, no preamble.",
            ),
        ):
            if isinstance(message, AssistantMessage):
                for block in message.content:
                    if isinstance(block, TextBlock):
                        response += block.text
            elif isinstance(message, ResultMessage):
                pass
    except Exception as exc:
        import traceback
        logging.error("Agent SDK error: %s\n%s", exc, traceback.format_exc())
        response = f"FLUSH_ERROR: {type(exc).__name__}: {exc}"

    return response.strip()


def append_to_session_log(summary: str) -> None:
    path = session_log_path()
    if not is_write_path_allowed(path):
        logging.error("write-guard blocked %s", path)
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    with file_lock(path):
        if not path.exists():
            path.write_text(f"# Claude Sessions — {path.stem}\n\n", encoding="utf-8")
        with open(path, "a", encoding="utf-8") as f:
            f.write("\n" + summary.rstrip() + "\n")


def patch_daily_note_with_wikilink(session_relpath: str, project_name: str, hhmm: str) -> None:
    daily = daily_note_path()
    if not daily.exists():
        return

    with file_lock(daily):
        try:
            text = daily.read_text(encoding="utf-8")
        except Exception:
            return

        heading = "## 💬 Sessions"
        if heading not in text:
            return

        new_line = f"- {hhmm} [[{session_relpath}|sessions]] — {project_name}"
        if new_line in text:
            return  # idempotent

        lines = text.splitlines()
        out: list[str] = []
        inserted = False
        in_section = False

        for line in lines:
            out.append(line)
            if line.strip() == heading:
                in_section = True
                continue
            if in_section and not inserted:
                stripped = line.strip()
                if stripped.startswith("<!--") or stripped == "":
                    continue
                if stripped.startswith("## ") or stripped == "---":
                    out.insert(-1, new_line)
                    inserted = True
                    in_section = False
                else:
                    out.insert(-1, new_line)
                    inserted = True
                    in_section = False

        if in_section and not inserted:
            out.append(new_line)
            inserted = True

        if inserted:
            daily.write_text("\n".join(out) + ("\n" if not text.endswith("\n") else ""), encoding="utf-8")


def main() -> None:
    if len(sys.argv) < 5:
        logging.error("Usage: %s <context_file.md> <session_id> <project_name> <hhmm>", sys.argv[0])
        sys.exit(1)

    context_file = Path(sys.argv[1])
    session_id = sys.argv[2]
    project_name = sys.argv[3]
    hhmm = sys.argv[4]

    logging.info("flush started: session=%s context=%s project=%s", session_id, context_file, project_name)

    if not context_file.exists():
        logging.error("context file not found: %s", context_file)
        return

    state = load_dedup_state()
    if (
        state.get("session_id") == session_id
        and time.time() - state.get("timestamp", 0) < DEDUP_WINDOW_SECONDS
    ):
        logging.info("SKIP: duplicate flush for session %s", session_id)
        context_file.unlink(missing_ok=True)
        return

    context = context_file.read_text(encoding="utf-8").strip()
    if not context:
        logging.info("SKIP: context file empty")
        context_file.unlink(missing_ok=True)
        return

    logging.info("flushing: session=%s chars=%d", session_id, len(context))

    response = asyncio.run(run_flush(context, project_name, hhmm))

    # Fix A: always write *something* per session — silent FLUSH_OK or empty
    # response is indistinguishable from "the hook never fired" in the buried
    # vault session log. Placeholder for trivial sessions, error stub for SDK
    # failures, real summary for normal sessions.
    summary_to_append: str | None = None
    flush_succeeded = False

    if not response:
        logging.info("empty SDK response — writing placeholder")
        summary_to_append = (
            f"## {hhmm} — {project_name}\n"
            f"- _(empty SDK response, see ~/.claude/state/memory_flush.log)_\n"
        )
    elif "FLUSH_ERROR" in response:
        logging.error("result: %s", response)
        summary_to_append = (
            f"## {hhmm} — {project_name}\n"
            f"- _(flush failed — context preserved at "
            f"{context_file.name}.failed for replay; see memory_flush.log)_\n"
        )
    elif "FLUSH_OK" in response:
        logging.info("result: FLUSH_OK (trivial session)")
        summary_to_append = (
            f"## {hhmm} — {project_name}\n"
            f"- _(short session, nothing durable to record)_\n"
        )
        flush_succeeded = True
    else:
        logging.info("result: appending %d chars to session log", len(response))
        summary_to_append = response
        flush_succeeded = True

    if summary_to_append:
        try:
            append_to_session_log(summary_to_append)
        except Exception as exc:
            logging.error("append_to_session_log failed: %s", exc)

        if flush_succeeded:
            try:
                today = date.today()
                relpath = f"2 - Areas/Daily Ops/{today.year}/Claude Sessions/{today.isoformat()}"
                patch_daily_note_with_wikilink(relpath, project_name, hhmm)
            except Exception as exc:
                logging.error("wikilink patch failed (non-fatal): %s", exc)

    save_dedup_state({"session_id": session_id, "timestamp": time.time()})

    # Fix C: preserve failed context for replay; delete on success/trivial.
    if "FLUSH_ERROR" in (response or "") or not response:
        try:
            context_file.rename(context_file.with_suffix(context_file.suffix + ".failed"))
            logging.info("preserved failed context: %s.failed", context_file.name)
        except Exception as exc:
            logging.error("could not preserve failed context: %s", exc)
            context_file.unlink(missing_ok=True)
    else:
        context_file.unlink(missing_ok=True)

    # Fix B: midnight rollover — also try to claim today's reflection slot from
    # here. SessionStart only fires on fresh sessions; long sessions spanning
    # midnight would otherwise block reflection. Atomic claim is shared with
    # session_start.py so we never double-fire.
    maybe_kick_reflection()

    logging.info("flush complete: session=%s", session_id)


def maybe_kick_reflection() -> None:
    """Fire-and-forget reflection if today's slot hasn't been claimed yet.

    Uses the same atomic claim as session_start.py — exactly one trigger per
    calendar day, regardless of which hook wins the race.
    """
    if not REFLECT_SCRIPT.exists():
        return
    if not claim_reflection_for_today():
        return  # already claimed today (by SessionStart or an earlier flush)
    try:
        subprocess.Popen(
            ["uv", "run", str(REFLECT_SCRIPT)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            stdin=subprocess.DEVNULL,
            start_new_session=True,
        )
        logging.info("kicked reflection (won today's claim from flush)")
    except Exception as exc:
        logging.error("failed to kick reflection: %s", exc)


if __name__ == "__main__":
    main()
