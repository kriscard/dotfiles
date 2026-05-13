"""Registry of available integrations.

Each integration registers a name → module mapping. `query.py` looks here
to dispatch CLI subcommands. New integrations are added by importing them
below and appending to `REGISTRY`.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable


@dataclass(frozen=True)
class Integration:
    name: str
    enabled: bool
    cli: Callable[[list[str]], int]


def _build_registry() -> dict[str, Integration]:
    registry: dict[str, Integration] = {}

    # GitHub
    try:
        from . import github  # type: ignore

        registry["github"] = Integration(
            name="github", enabled=True, cli=github.cli
        )
    except ImportError:
        pass

    # Gmail (added when phase 4.2 ships)
    try:
        from . import gmail  # type: ignore

        registry["gmail"] = Integration(name="gmail", enabled=True, cli=gmail.cli)
    except ImportError:
        pass

    # Jira (renamed jira_api to avoid shadowing PyPI "jira" package)
    try:
        from . import jira_api  # type: ignore

        registry["jira"] = Integration(name="jira", enabled=True, cli=jira_api.cli)
    except ImportError:
        pass

    # Calendar (shares Google OAuth with gmail via lib/google_auth.py)
    try:
        from . import calendar_api  # type: ignore

        registry["calendar"] = Integration(
            name="calendar", enabled=True, cli=calendar_api.cli
        )
    except ImportError:
        pass

    return registry


REGISTRY = _build_registry()


def list_enabled() -> list[str]:
    return sorted(name for name, integ in REGISTRY.items() if integ.enabled)
