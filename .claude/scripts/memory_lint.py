#!/usr/bin/env python3
"""memory_lint.py — read-only health check for agent-written memory notes.

Scans the vault for notes carrying `source: claude-memory` frontmatter and
reports issues. Never modifies, never deletes — output only.

Usage:
  uv run ~/.dotfiles/.claude/scripts/memory_lint.py
"""

from __future__ import annotations

import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "hooks" / "lib"))
from memory_common import (  # noqa: E402
    DAILY_OPS,
    MOC_FILE,
    RESOURCES_DIR,
    VAULT_PATH,
)

WIKILINK_RE = re.compile(r"\[\[([^\]\|#]+)(?:#[^\]\|]+)?(?:\|[^\]]+)?\]\]")
FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)


def parse_frontmatter(text: str) -> dict[str, str]:
    m = FRONTMATTER_RE.match(text)
    if not m:
        return {}
    fm = {}
    for line in m.group(1).splitlines():
        if ":" in line and not line.strip().startswith("-"):
            k, _, v = line.partition(":")
            fm[k.strip()] = v.strip().strip('"').strip("'")
    return fm


def has_source_claude_memory(path: Path) -> bool:
    try:
        head = path.read_text()[:2000]
    except Exception:
        return False
    fm = parse_frontmatter(head)
    return fm.get("source") == "claude-memory"


def collect_agent_notes() -> list[Path]:
    notes: list[Path] = []
    for md in VAULT_PATH.rglob("*.md"):
        # Skip internal cache-y dirs
        if any(part.startswith(".") for part in md.relative_to(VAULT_PATH).parts):
            continue
        if has_source_claude_memory(md):
            notes.append(md)
    return notes


def index_all_notes() -> dict[str, Path]:
    """Map basename (without .md, lowercased) → first matching path."""
    idx: dict[str, Path] = {}
    for md in VAULT_PATH.rglob("*.md"):
        if any(part.startswith(".") for part in md.relative_to(VAULT_PATH).parts):
            continue
        key = md.stem.lower()
        idx.setdefault(key, md)
    return idx


def find_wikilinks(text: str) -> list[str]:
    return [m.group(1).strip() for m in WIKILINK_RE.finditer(text)]


def collect_inbound_links(all_notes: list[Path]) -> dict[str, set[str]]:
    """Map note-stem-lower → set of files that link to it."""
    inbound: dict[str, set[str]] = defaultdict(set)
    for md in all_notes:
        try:
            text = md.read_text()
        except Exception:
            continue
        for link in find_wikilinks(text):
            target = link.split("/")[-1].lower()
            inbound[target].add(str(md.relative_to(VAULT_PATH)))
    return inbound


def main() -> int:
    print(f"memory_lint — vault: {VAULT_PATH}\n")

    agent_notes = collect_agent_notes()
    print(f"Agent-written notes (source: claude-memory): {len(agent_notes)}")

    if not agent_notes:
        print("No agent-written notes found yet. Lint has nothing to check.")
        return 0

    all_md = list(VAULT_PATH.rglob("*.md"))
    note_index = index_all_notes()
    inbound = collect_inbound_links(all_md)

    moc_text = MOC_FILE.read_text() if MOC_FILE.exists() else ""

    issues: dict[str, list[str]] = defaultdict(list)

    # 1 — broken wikilinks
    for note in agent_notes:
        try:
            text = note.read_text()
        except Exception as exc:
            issues["unreadable"].append(f"{note}: {exc}")
            continue
        for link in find_wikilinks(text):
            target = link.split("/")[-1].lower()
            if target not in note_index:
                issues["broken-wikilink"].append(
                    f"{note.relative_to(VAULT_PATH)} → [[{link}]]"
                )

    # 2 — orphans (no inbound links + not in MOC)
    for note in agent_notes:
        stem = note.stem.lower()
        moc_mentions_it = note.stem in moc_text or stem in moc_text.lower()
        if not inbound.get(stem) and not moc_mentions_it:
            issues["orphan"].append(str(note.relative_to(VAULT_PATH)))

    # 3 — MOC drift: agent notes missing from MOC
    for note in agent_notes:
        if note.stem not in moc_text and note.stem.lower() not in moc_text.lower():
            issues["missing-from-moc"].append(str(note.relative_to(VAULT_PATH)))

    # 4 — agent notes outside 3 - Resources/ (write-guard violation indicator)
    resources_resolved = RESOURCES_DIR.resolve()
    for note in agent_notes:
        try:
            note_resolved = note.resolve()
        except Exception:
            continue
        if not note_resolved.is_relative_to(resources_resolved):
            issues["outside-resources"].append(str(note.relative_to(VAULT_PATH)))

    # 5 — MOC entries pointing to deleted files
    for link in find_wikilinks(moc_text):
        target = link.split("/")[-1].lower()
        if target not in note_index:
            issues["moc-broken-link"].append(f"MOC → [[{link}]]")

    # 6 — topic concentration (≥4 agent notes sharing the same first tag)
    tag_counts: Counter[str] = Counter()
    for note in agent_notes:
        try:
            head = note.read_text()[:2000]
        except Exception:
            continue
        fm = parse_frontmatter(head)
        tags_raw = fm.get("tags", "")
        if tags_raw:
            first_tag = tags_raw.strip("[] ").split(",")[0].strip()
            if first_tag and first_tag != "claude-memory":
                tag_counts[first_tag] += 1
    for tag, count in tag_counts.most_common():
        if count >= 4:
            issues["topic-concentration"].append(
                f"tag '{tag}' has {count} agent notes — consider a parent concept page"
            )

    # 7 — agent notes with no body (just frontmatter)
    for note in agent_notes:
        try:
            text = note.read_text()
        except Exception:
            continue
        body = re.sub(FRONTMATTER_RE, "", text).strip()
        if len(body) < 50:
            issues["empty-body"].append(str(note.relative_to(VAULT_PATH)))

    # Report
    if not issues:
        print("\n✓ No issues found.")
        return 0

    total = sum(len(v) for v in issues.values())
    print(f"\nFound {total} issue(s) across {len(issues)} category/categories:\n")
    for category, items in issues.items():
        print(f"### {category} ({len(items)})")
        for item in items[:20]:
            print(f"  - {item}")
        if len(items) > 20:
            print(f"  … and {len(items) - 20} more")
        print()

    return 1 if any(c in issues for c in ("broken-wikilink", "outside-resources")) else 0


if __name__ == "__main__":
    sys.exit(main())
