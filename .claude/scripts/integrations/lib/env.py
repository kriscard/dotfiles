"""Minimal .env loader so each integration module can read credentials.

Looks for `.env` next to the integrations package. Falls back to existing
environment variables if the file is absent. Never logs or prints values.
"""

from __future__ import annotations

import os
from pathlib import Path

ENV_PATH = Path(__file__).resolve().parent.parent / ".env"


def load_env() -> None:
    """Idempotent — safe to call multiple times."""
    if not ENV_PATH.exists():
        return
    for raw in ENV_PATH.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        # Don't overwrite explicitly set env vars
        if key and key not in os.environ:
            os.environ[key] = value


def require(name: str) -> str:
    load_env()
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(
            f"Missing credential: {name}. "
            f"Set it in {ENV_PATH} (see .env.example) or export it."
        )
    return value
