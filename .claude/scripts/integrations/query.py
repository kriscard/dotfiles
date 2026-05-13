#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# ///
"""Unified CLI for all integrations.

Usage:
    query.py <platform> <subcommand> [args...]

Examples:
    query.py github prs           # PR review requests
    query.py github my-prs        # User's own open PRs
    query.py gmail triage         # Important unread emails (last 16h)
    query.py jira overdue         # Past-due assigned tickets

Architecture: this script and its sibling modules hold all credentials.
The LLM shells out to this CLI and receives only the formatted data —
never tokens, OAuth state, or raw API responses.
"""

from __future__ import annotations

import sys
from pathlib import Path

# Make sibling integration modules importable
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from integrations.registry import REGISTRY, list_enabled  # noqa: E402


def main() -> int:
    if len(sys.argv) < 2:
        print(_help(), file=sys.stderr)
        return 2

    if sys.argv[1] in ("-h", "--help", "help"):
        print(_help())
        return 0

    if sys.argv[1] == "list":
        for name in list_enabled():
            print(name)
        return 0

    platform = sys.argv[1]
    integ = REGISTRY.get(platform)
    if integ is None:
        print(f"Unknown platform: {platform}", file=sys.stderr)
        print(f"Available: {', '.join(list_enabled())}", file=sys.stderr)
        return 2
    if not integ.enabled:
        print(f"Platform {platform} is disabled in registry.py", file=sys.stderr)
        return 2

    return integ.cli(sys.argv[2:])


def _help() -> str:
    enabled = list_enabled()
    return (
        "Usage: query.py <platform> <subcommand>\n"
        f"Enabled platforms: {', '.join(enabled) if enabled else '(none)'}\n"
        "\n"
        "Examples:\n"
        "  query.py github prs\n"
        "  query.py github my-prs\n"
        "  query.py gmail triage\n"
        "  query.py jira overdue\n"
        "  query.py list      # list enabled platforms\n"
    )


if __name__ == "__main__":
    sys.exit(main())
