#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "claude-agent-sdk>=0.1.72",
# ]
# ///
"""SessionEnd / PreCompact hook: summarize transcript, append to today's session log.

Reads the JSONL transcript at `transcript_path`, spawns a Claude Agent SDK
subprocess to summarize, and appends the result to:
  <vault>/2 - Areas/Daily Ops/<year>/Claude Sessions/YYYY-MM-DD.md

Also patches today's daily note (in-place under `## 💬 Sessions`) with a wikilink.
Graceful degradation: if the heading is absent, the wikilink step is skipped.
"""

from __future__ import annotations

import asyncio
import contextlib
import fcntl
import json
import sys
from datetime import date, datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "lib"))
from memory_common import (  # noqa: E402
    daily_note_path,
    is_write_path_allowed,
    session_log_path,
)


@contextlib.contextmanager
def file_lock(path: Path, timeout_seconds: int = 10):
    """Exclusive advisory lock on a sidecar file. Safe across multiple Claude Code
    sessions (different tmux panes) ending concurrently. Falls back gracefully:
    if the lock can't be acquired in `timeout_seconds`, yields anyway.
    """
    import time

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
                    print(
                        f"memory_session_end: lock timeout on {lock_path}, proceeding anyway",
                        file=sys.stderr,
                    )
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

MIN_TURNS_TO_SUMMARIZE = 5
MAX_TRANSCRIPT_TURNS = 50
MAX_CHARS_PER_MESSAGE = 2000

SUMMARY_PROMPT = """You are summarizing a Claude Code session transcript for a long-term memory log.

Output Markdown only. Format strictly as:

## <HH:MM> — <project name>
- **Decisions:** <1-line decisions made; or "—" if none>
- **Lessons:** <durable takeaways the user/agent learned; or "—">
- **Action items:** <follow-ups carried forward; or "—">
- **Files touched:** <comma-separated paths; or "—">

Be terse. Skip pleasantries. Focus on durable content. No preamble, no closing.

Use this header timestamp and project name:
"""


def load_transcript(path: str) -> list[dict]:
    msgs: list[dict] = []
    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    msgs.append(json.loads(line))
                except Exception:
                    continue
    except Exception as exc:
        print(f"memory_session_end: failed to read transcript {path}: {exc}", file=sys.stderr)
    return msgs


def transcript_to_text(msgs: list[dict], max_turns: int) -> str:
    tail = msgs[-(max_turns * 2):]
    parts: list[str] = []
    for m in tail:
        msg_type = m.get("type") or m.get("role") or "?"
        message = m.get("message", m)
        content = message.get("content", "") if isinstance(message, dict) else ""
        if isinstance(content, list):
            text_parts: list[str] = []
            for c in content:
                if isinstance(c, dict):
                    if c.get("type") == "text":
                        text_parts.append(c.get("text", ""))
                    elif c.get("type") == "tool_use":
                        name = c.get("name", "?")
                        text_parts.append(f"[tool_use:{name}]")
                    elif c.get("type") == "tool_result":
                        text_parts.append("[tool_result]")
                else:
                    text_parts.append(str(c))
            content = "\n".join(text_parts)
        text = str(content)[:MAX_CHARS_PER_MESSAGE]
        if text.strip():
            parts.append(f"[{msg_type}] {text}")
    return "\n\n".join(parts)


async def summarize(transcript_text: str, project_name: str, hhmm: str) -> str:
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
    full_prompt = (
        SUMMARY_PROMPT
        + f"\nTime: {hhmm}\nProject: {project_name}\n\n---\n"
        + transcript_text
    )

    chunks: list[str] = []
    async for msg in query(prompt=full_prompt, options=options):
        if isinstance(msg, AssistantMessage):
            for block in msg.content:
                if isinstance(block, TextBlock):
                    chunks.append(block.text)
    return "".join(chunks).strip()


def append_to_session_log(summary: str) -> None:
    path = session_log_path()
    if not is_write_path_allowed(path):
        print(f"memory_session_end: write-guard blocked {path}", file=sys.stderr)
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    # POSIX O_APPEND is atomic for single small writes, so the lock is belt-and-braces:
    # it also serializes the existence-check + header-write race when the file is
    # being created for the first time on a day with parallel sessions.
    with file_lock(path):
        if not path.exists():
            path.write_text(f"# Claude Sessions — {path.stem}\n\n")
        with open(path, "a") as f:
            f.write("\n" + summary.rstrip() + "\n")


def patch_daily_note_with_wikilink(session_relpath: str, project_name: str, hhmm: str) -> None:
    daily = daily_note_path()
    if not daily.exists():
        return

    # Hold the lock across the entire read-modify-write so concurrent SessionEnd
    # hooks (multiple tmux panes ending at the same time) don't clobber each other.
    with file_lock(daily):
        try:
            text = daily.read_text()
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
                # Pass through the comment line and any blank lines, then insert
                if stripped.startswith("<!--") or stripped == "":
                    continue
                if stripped.startswith("## ") or stripped == "---":
                    # Insert above this boundary
                    out.insert(-1, new_line)
                    inserted = True
                    in_section = False
                else:
                    # Existing wikilink lines — insert after them
                    out.insert(-1, new_line)
                    inserted = True
                    in_section = False

        if in_section and not inserted:
            out.append(new_line)
            inserted = True

        if inserted:
            daily.write_text("\n".join(out) + ("\n" if not text.endswith("\n") else ""))


def main() -> None:
    try:
        input_data = json.load(sys.stdin)
    except Exception as exc:
        print(f"memory_session_end: invalid stdin JSON: {exc}", file=sys.stderr)
        return

    transcript_path = input_data.get("transcript_path")
    cwd = input_data.get("cwd", "")
    event = input_data.get("hook_event_name", "?")

    if not transcript_path or not Path(transcript_path).exists():
        print(f"memory_session_end ({event}): transcript not found at {transcript_path}", file=sys.stderr)
        return

    msgs = load_transcript(transcript_path)
    if len(msgs) < MIN_TURNS_TO_SUMMARIZE:
        print(
            f"memory_session_end ({event}): {len(msgs)} turns < {MIN_TURNS_TO_SUMMARIZE}, skipping",
            file=sys.stderr,
        )
        return

    transcript_text = transcript_to_text(msgs, MAX_TRANSCRIPT_TURNS)
    project_name = Path(cwd).name or "ad-hoc"
    hhmm = datetime.now().strftime("%H:%M")

    try:
        summary = asyncio.run(summarize(transcript_text, project_name, hhmm))
    except Exception as exc:
        print(f"memory_session_end ({event}): SDK summarize failed: {exc}", file=sys.stderr)
        return

    if not summary:
        print(f"memory_session_end ({event}): empty summary, skipping write", file=sys.stderr)
        return

    append_to_session_log(summary)

    try:
        today = date.today()
        relpath = f"2 - Areas/Daily Ops/{today.year}/Claude Sessions/{today.isoformat()}"
        patch_daily_note_with_wikilink(relpath, project_name, hhmm)
    except Exception as exc:
        print(f"memory_session_end ({event}): wikilink patch failed (non-fatal): {exc}", file=sys.stderr)


if __name__ == "__main__":
    main()
