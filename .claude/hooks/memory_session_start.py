#!/usr/bin/env python3
"""SessionStart hook: inject vault memory files into Claude's context.

Outputs a structured `additionalContext` JSON per Claude Code hooks spec.
Also kicks off daily reflection in the background if it hasn't run today.

Files injected (in order):
  1. AGENTS.md  — vault rules
  2. SOUL.md    — agent persona
  3. USER.md    — stable user profile
  4. MEMORY.md  — long-term curated facts (capped)
  5. MOC stub   — top entries of the agent index

Total budget: ~2300 tokens, bounded by file caps.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

# Add lib/ to sys.path so we can import memory_common
sys.path.insert(0, str(Path(__file__).parent / "lib"))
from memory_common import (  # noqa: E402
    AGENTS_FILE,
    MEMORY_FILE,
    MOC_FILE,
    SOUL_FILE,
    USER_FILE,
    claim_reflection_for_today,
    moc_stub,
    truncate_to_token_cap,
)

REFLECT_SCRIPT = Path.home() / ".dotfiles" / ".claude" / "scripts" / "memory_reflect.py"


def read_or_empty(path: Path) -> str:
    if not path.exists():
        return ""
    try:
        return path.read_text()
    except Exception as exc:
        print(f"memory_session_start: failed to read {path}: {exc}", file=sys.stderr)
        return ""


def kick_off_reflection_if_first_session_of_day() -> None:
    """Fire-and-forget reflection. Non-blocking, no-op if the script isn't there yet.

    Uses an atomic claim (fcntl.flock-protected) so that when multiple Claude Code
    sessions across tmux panes start at the same time, only one wins the claim
    and kicks the subprocess.
    """
    if not REFLECT_SCRIPT.exists():
        return  # Phase 3 hasn't shipped yet

    if not claim_reflection_for_today():
        return  # another concurrent SessionStart already claimed today

    try:
        subprocess.Popen(
            ["uv", "run", str(REFLECT_SCRIPT)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            stdin=subprocess.DEVNULL,
            start_new_session=True,
        )
    except Exception as exc:
        print(f"memory_session_start: failed to kick reflection: {exc}", file=sys.stderr)


def main() -> None:
    # Consume stdin (hook input). We don't need any specific field from it.
    try:
        json.load(sys.stdin)
    except Exception:
        pass

    try:
        agents = read_or_empty(AGENTS_FILE)
        soul = read_or_empty(SOUL_FILE)
        user = read_or_empty(USER_FILE)
        memory = truncate_to_token_cap(read_or_empty(MEMORY_FILE), target_tokens=1000)
        moc_full = read_or_empty(MOC_FILE)
        moc_top = moc_stub(moc_full) if moc_full else ""

        sections: list[str] = []
        if agents:
            sections.append(f"# === Vault: AGENTS.md (rules) ===\n{agents}")
        if soul:
            sections.append(f"# === Vault: SOUL.md (persona) ===\n{soul}")
        if user:
            sections.append(f"# === Vault: USER.md (profile) ===\n{user}")
        if memory:
            sections.append(f"# === Vault: MEMORY.md (long-term curated facts) ===\n{memory}")
        if moc_top:
            sections.append(f"# === Vault: Claude Memory MOC (recent index, stub) ===\n{moc_top}")

        if not sections:
            return

        output = {
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": "\n\n".join(sections),
            }
        }
        print(json.dumps(output))

        kick_off_reflection_if_first_session_of_day()
    except Exception as exc:
        print(f"memory_session_start failed: {exc}", file=sys.stderr)


if __name__ == "__main__":
    main()
