"""Deterministic guardrails for any future v2 features that take actions.

The heartbeat itself is read-only externally, so this module is currently
unused — but it's in place so when (or if) draft-sending, auto-comment, or
similar features ship, the guardrail layer already exists.

Pattern: deterministic pre-check (cheap, fast) + optional LLM evaluation
(reserved for ambiguous cases). Per the architecture reference's 3-layer
security pattern, this is layer 2 ("Guardrails").
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Literal


Verdict = Literal["pass", "fail", "suspicious"]


@dataclass
class GuardrailResult:
    verdict: Verdict
    reason: str = ""


# Deterministic patterns. Pulled from user's CLAUDE.md hard rules
# (Safety Rules — HIGHEST PRIORITY).
_BANNED_BASH_PATTERNS = (
    (re.compile(r"rm\s+-rf\s+[/~]"), "rm -rf root or home"),
    (re.compile(r"git\s+push\s+--?force(?!-with-lease)"), "git push --force on master/main"),
    (re.compile(r"git\s+reset\s+--hard\s+(origin/)?(main|master)"), "git reset --hard on main/master"),
    (re.compile(r"git\s+commit.*--no-verify"), "hook bypass (--no-verify)"),
    (re.compile(r"git\s+commit.*--no-gpg-sign"), "GPG signing bypass"),
    (re.compile(r"git\s+commit.*-c\s+commit\.gpgsign=false"), "GPG signing bypass via -c"),
)

_VAULT_BULK_DELETE = re.compile(
    r"(rm|find|fd).*\b(0|1|2|3|4)\s*-\s*\w+",  # any PARA folder bulk-delete
)


def check_bash(cmd: str) -> GuardrailResult:
    """Deterministic check on a proposed shell command."""
    for pattern, reason in _BANNED_BASH_PATTERNS:
        if pattern.search(cmd):
            return GuardrailResult(verdict="fail", reason=reason)
    if _VAULT_BULK_DELETE.search(cmd):
        return GuardrailResult(
            verdict="suspicious",
            reason="possible bulk operation on PARA folder",
        )
    return GuardrailResult(verdict="pass")


def check_send_action(channel: str, recipient: str, body: str) -> GuardrailResult:
    """Block any external send unless the heartbeat has been explicitly
    upgraded to a proactivity level that permits it.

    Currently the heartbeat is read-only externally, so this always returns
    fail. When/if v2 changes the proactivity level, replace this with the
    appropriate per-channel logic.
    """
    return GuardrailResult(
        verdict="fail",
        reason=(
            "External sends are disabled at the current proactivity level "
            "(triage / advisor). Update USER.md proactivity setting first."
        ),
    )
