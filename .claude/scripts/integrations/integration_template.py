"""Template for new integrations.

Copy this file to `<platform>.py`, fill in the TODOs, and add a registration
entry in `registry.py`.

Pattern:
    1. Data model (dataclass) — one or more typed structures
    2. Auth (read credentials, return authenticated client)
    3. Query functions — one per use case (returns list[DataModel])
    4. Formatter — `format_for_context()` returns markdown
    5. CLI dispatch — handle subcommands from query.py
"""

from __future__ import annotations

from dataclasses import dataclass

from .lib.env import require  # for .env-based credentials
from .lib.formatters import FormattedItem, render_section


# ── 1. DATA MODEL ──────────────────────────────────────────────────────────
@dataclass
class Item:
    # TODO: fields for one logical unit from this platform
    id: str
    title: str
    url: str


# ── 2. AUTH ────────────────────────────────────────────────────────────────
def get_client():
    """Read credentials, return authenticated client.

    For OAuth-style: cache token at ~/.dotfiles/.claude/scripts/integrations/.tokens/
    For API-token style: read from .env via require("PLATFORM_TOKEN")
    """
    # TODO: implement based on platform's auth model
    raise NotImplementedError


# ── 3. QUERIES ─────────────────────────────────────────────────────────────
def list_something() -> list[Item]:
    """One concrete use case from HEARTBEAT.md."""
    # TODO
    raise NotImplementedError


# ── 4. FORMATTER ───────────────────────────────────────────────────────────
def format_for_context(items: list[Item], heading: str) -> str:
    formatted = [
        FormattedItem(title=i.title, url=i.url, priority="normal")
        for i in items
    ]
    return render_section(heading, formatted)


# ── 5. CLI DISPATCH ────────────────────────────────────────────────────────
def cli(args: list[str]) -> int:
    if not args:
        print("subcommands: something", file=__import__("sys").stderr)
        return 2
    sub = args[0]
    if sub == "something":
        print(format_for_context(list_something(), "Platform — section"))
        return 0
    print(f"Unknown subcommand: {sub}", file=__import__("sys").stderr)
    return 2
