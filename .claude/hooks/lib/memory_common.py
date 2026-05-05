"""Shared helpers for the Claude Code memory system hooks and scripts."""

from __future__ import annotations

import json
import logging
import os
import subprocess
from datetime import date, datetime
from pathlib import Path

def _find_vault() -> Path:
    """Resolve vault path from env var or auto-detect."""
    if env_vault := os.environ.get("OBSIDIAN_VAULT"):
        return Path(env_vault).expanduser()
    # Fallback: look for obsidian-vault-* in home
    home = Path.home()
    for candidate in home.glob("obsidian-vault-*"):
        if candidate.is_dir():
            return candidate
    # Last resort — original path
    return home / "obsidian-vault-kriscard"


VAULT_PATH = _find_vault()

AGENTS_FILE = VAULT_PATH / "AGENTS.md"
SOUL_FILE = VAULT_PATH / "SOUL.md"
USER_FILE = VAULT_PATH / "USER.md"
MEMORY_FILE = VAULT_PATH / "MEMORY.md"
MEMORY_ARCHIVE = VAULT_PATH / "MEMORY.md.archive"
MOC_FILE = VAULT_PATH / "MOCs" / "Claude Memory MOC.md"

DAILY_OPS = VAULT_PATH / "2 - Areas" / "Daily Ops"
RESOURCES_DIR = VAULT_PATH / "3 - Resources"

STATE_DIR = Path.home() / ".claude" / "state"
REFLECTION_LAST_RUN = STATE_DIR / "memory-reflection-last-run.txt"


def session_log_path(d: date | None = None) -> Path:
    d = d or date.today()
    return DAILY_OPS / str(d.year) / "Claude Sessions" / f"{d.isoformat()}.md"


def daily_note_path(d: date | None = None) -> Path:
    d = d or date.today()
    return DAILY_OPS / str(d.year) / f"{d.isoformat()}.md"


def is_auto_write_allowed(path: Path) -> bool:
    """True iff the path is part of the agent's raw-capture infrastructure
    (Claude Sessions/, MEMORY.md/.archive, MOC and its archive). These are the
    only paths the agent is allowed to write WITHOUT explicit user approval.

    All other vault writes (PARA notes, Inbox, USER.md, AGENTS.md, SOUL.md,
    Templates/, etc.) require user permission via --dry-run review or
    AskUserQuestion in interactive sessions.
    """
    try:
        p = path.resolve()
    except Exception:
        return False

    daily_ops_resolved = DAILY_OPS.resolve()

    # Session logs (Claude Sessions/ subtree under any year)
    if p.is_relative_to(daily_ops_resolved) and "Claude Sessions" in p.parts:
        return True

    # MEMORY.md, MEMORY.md.archive, MOC and its archive folder
    auto_files = {
        MEMORY_FILE.resolve(),
        MEMORY_ARCHIVE.resolve(),
        MOC_FILE.resolve(),
    }
    if p in auto_files:
        return True
    if p.is_relative_to((VAULT_PATH / "MOCs" / "Claude Memory Archive").resolve()):
        return True

    return False


# Backwards-compatible alias used by older drafts of the hooks.
is_write_path_allowed = is_auto_write_allowed


def is_inside_vault(path: Path) -> bool:
    """Sanity check — never write to a path outside the vault."""
    try:
        return path.resolve().is_relative_to(VAULT_PATH.resolve())
    except Exception:
        return False


def reflection_already_ran_today() -> bool:
    if not REFLECTION_LAST_RUN.exists():
        return False
    try:
        return REFLECTION_LAST_RUN.read_text().strip() == date.today().isoformat()
    except Exception:
        return False


def mark_reflection_ran_today() -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    REFLECTION_LAST_RUN.write_text(date.today().isoformat())


def claim_reflection_for_today() -> bool:
    """Atomic test-and-set across multiple SessionStart hooks running concurrently
    in different tmux panes. Returns True iff this caller wins the right to run
    today's reflection (caller should kick the subprocess). Returns False if
    reflection was already claimed today.

    Uses fcntl.flock on the state directory to serialize the check-and-write.
    Falls back to non-locked behavior if fcntl is unavailable.
    """
    import fcntl  # noqa: PLC0415 — local to keep stdlib-only import surface

    STATE_DIR.mkdir(parents=True, exist_ok=True)
    lock_file = STATE_DIR / "memory-reflection-claim.lock"
    today = date.today().isoformat()
    f = open(lock_file, "w")
    try:
        try:
            fcntl.flock(f, fcntl.LOCK_EX)
        except Exception:
            pass
        if reflection_already_ran_today():
            return False
        REFLECTION_LAST_RUN.write_text(today)
        return True
    finally:
        try:
            fcntl.flock(f, fcntl.LOCK_UN)
        except Exception:
            pass
        f.close()


def truncate_to_token_cap(text: str, target_tokens: int) -> str:
    """Rough estimate: 1 token ≈ 4 chars. Truncate from the end."""
    target_chars = target_tokens * 4
    if len(text) <= target_chars:
        return text
    return text[:target_chars].rstrip() + "\n\n_(truncated to token budget)_"


def moc_stub(full_moc_text: str, max_lines: int = 30) -> str:
    """Return a recency-truncated stub of the MOC for SessionStart injection."""
    lines = full_moc_text.splitlines()
    if len(lines) <= max_lines:
        return full_moc_text
    return "\n".join(lines[:max_lines]) + f"\n\n_(stub: {len(lines) - max_lines} more lines in full MOC)_"


# ---------------------------------------------------------------------------
# Transcript helpers — shared by SessionEnd and PreCompact hooks.

MAX_TURNS = 30
MAX_CONTEXT_CHARS = 15_000

# .claude/hooks/lib/memory_common.py → ../../scripts/memory_flush.py
FLUSH_SCRIPT = Path(__file__).parent.parent.parent / "scripts" / "memory_flush.py"


def extract_conversation_context(transcript_path: Path) -> tuple[str, int]:
    """Read JSONL transcript, return (markdown_text, turn_count) for the last
    MAX_TURNS user/assistant turns, capped at MAX_CONTEXT_CHARS."""
    turns: list[str] = []
    with open(transcript_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            msg = entry.get("message", {})
            if isinstance(msg, dict):
                role = msg.get("role", "")
                content = msg.get("content", "")
            else:
                role = entry.get("role", "")
                content = entry.get("content", "")

            if role not in ("user", "assistant"):
                continue

            if isinstance(content, list):
                parts: list[str] = []
                for block in content:
                    if isinstance(block, dict) and block.get("type") == "text":
                        parts.append(block.get("text", ""))
                    elif isinstance(block, str):
                        parts.append(block)
                content = "\n".join(parts)

            if isinstance(content, str) and content.strip():
                label = "User" if role == "user" else "Assistant"
                turns.append(f"**{label}:** {content.strip()}\n")

    recent = turns[-MAX_TURNS:]
    context = "\n".join(recent)

    if len(context) > MAX_CONTEXT_CHARS:
        context = context[-MAX_CONTEXT_CHARS:]
        boundary = context.find("\n**")
        if boundary > 0:
            context = context[boundary + 1 :]

    return context, len(recent)


def spawn_flush(context: str, session_id: str, project_name: str, hhmm: str) -> None:
    """Write context to a temp file under STATE_DIR and Popen memory_flush.py
    detached. Fire-and-forget — errors are logged, never raised."""
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    context_file = STATE_DIR / f"session-flush-{session_id}-{timestamp}.md"
    try:
        context_file.write_text(context, encoding="utf-8")
    except Exception as exc:
        logging.error("failed to write context file: %s", exc)
        return

    cmd = [
        "uv",
        "run",
        str(FLUSH_SCRIPT),
        str(context_file),
        session_id,
        project_name,
        hhmm,
    ]
    try:
        subprocess.Popen(
            cmd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            stdin=subprocess.DEVNULL,
            start_new_session=True,
        )
        logging.info(
            "spawned memory_flush.py: session=%s chars=%d project=%s",
            session_id, len(context), project_name,
        )
    except Exception as exc:
        logging.error("failed to spawn memory_flush.py: %s", exc)
