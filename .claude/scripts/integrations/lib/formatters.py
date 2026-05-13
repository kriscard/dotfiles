"""Shared output formatters for integration data.

Each integration's `format_for_context()` should call into these so the
heartbeat receives consistent markdown across all platforms.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


@dataclass
class FormattedItem:
    title: str
    subtitle: str = ""
    url: str = ""
    priority: str = "normal"  # "low" | "normal" | "high"


def render_section(heading: str, items: Iterable[FormattedItem]) -> str:
    """Render a category section as Markdown."""
    items = list(items)
    if not items:
        return f"## {heading}\n\nNothing new.\n"

    lines = [f"## {heading}\n"]
    for i in items:
        prefix = {"low": "  ", "normal": "- ", "high": "- **"}[i.priority]
        suffix = "**" if i.priority == "high" else ""
        link = f" — [open]({i.url})" if i.url else ""
        sub = f" — {i.subtitle}" if i.subtitle else ""
        lines.append(f"{prefix}{i.title}{suffix}{sub}{link}")
    return "\n".join(lines) + "\n"


def render_summary(sections: dict[str, str]) -> str:
    """Combine multiple category sections into one summary."""
    return "\n".join(sections.values())
