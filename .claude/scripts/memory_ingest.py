#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# ///
"""memory_ingest.py — catalog clipped sources into vault/index.md.

Reads a Web Clipper source file from 3 - Resources/<Type>/ (article, tweet,
video, etc.), parses its frontmatter, and adds one entry to index.md under
the matching category section. Appends a line to log.md.

This is the Karpathy LLM-wiki "ingest" operation for raw clipped sources.
Concept-page entity updates are NOT done here yet (that's a v2 expansion).

Usage:
    memory_ingest.py <source-path>             # dry-run, show what would happen
    memory_ingest.py <source-path> --apply     # write index + log
    memory_ingest.py --inbox [--apply]         # batch every clipping in vault
    memory_ingest.py --inbox --dry-run         # batch dry-run (default)
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from datetime import date, datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "hooks" / "lib"))
from memory_common import (  # noqa: E402
    INDEX_FILE,
    RESOURCES_DIR,
    STATE_DIR,
    VAULT_PATH,
    append_to_log,
    is_auto_write_allowed,
)


INGEST_STATE = STATE_DIR / "memory-ingest-processed.json"


# Map (second tag in `clipping, X`) → index.md section heading.
# Mirrors what Web Clipper templates emit.
CATEGORY_MAP = {
    "article": "Articles",
    "twitter": "Tweets",
    "tweet": "Tweets",
    "youtube": "Videos",
    "podcast": "Podcasts",
    "book": "Books",
    "github": "GitHub",
    "documentation": "Coding",
}


# ──────────────────────────────────────────────────────────────────────────────
# State

def load_state() -> dict[str, str]:
    """Map of vault-relative source path → ingest timestamp."""
    if not INGEST_STATE.exists():
        return {}
    try:
        return json.loads(INGEST_STATE.read_text())
    except Exception:
        return {}


def save_state(state: dict[str, str]) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    INGEST_STATE.write_text(json.dumps(state, indent=2))


# ──────────────────────────────────────────────────────────────────────────────
# Parse

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)


def parse_frontmatter(text: str) -> dict[str, str | list[str]]:
    m = FRONTMATTER_RE.match(text)
    if not m:
        return {}
    fm: dict[str, str | list[str]] = {}
    raw = m.group(1)
    current_key: str | None = None
    current_list: list[str] | None = None
    for line in raw.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("- ") and current_key:
            if current_list is None:
                current_list = []
                fm[current_key] = current_list
            current_list.append(_unquote(stripped[2:].strip()))
            continue
        if ":" in line and not line.startswith((" ", "\t")):
            key, _, val = line.partition(":")
            key = key.strip()
            val = val.strip()
            current_key = key
            if val:
                # Inline value (could be list-ish '[a, b]', scalar, or quoted string)
                if val.startswith("[") and val.endswith("]"):
                    items = [_unquote(x.strip()) for x in val[1:-1].split(",") if x.strip()]
                    fm[key] = items
                else:
                    fm[key] = _unquote(val)
                current_list = None
            else:
                # Multi-line list follows
                current_list = None
    return fm


def _unquote(val: str) -> str:
    val = val.strip()
    if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
        return val[1:-1]
    return val


def _tags(fm: dict) -> list[str]:
    tags = fm.get("tags", [])
    if isinstance(tags, str):
        # Comma-separated string fallback
        return [t.strip() for t in tags.split(",") if t.strip()]
    return [str(t).strip() for t in tags if t]


def _determine_category(tags: list[str]) -> str | None:
    """First non-'clipping' tag that maps to a category."""
    for t in tags:
        if t == "clipping":
            continue
        if t in CATEGORY_MAP:
            return CATEGORY_MAP[t]
    return None


def _strip_md(text: str) -> str:
    """Quick markdown-noise stripper for one-liner summary extraction."""
    # Remove wikilinks but keep label: [[Foo|Bar]] → Bar, [[Foo]] → Foo
    text = re.sub(r"\[\[([^\]\|]+)\|([^\]]+)\]\]", r"\2", text)
    text = re.sub(r"\[\[([^\]\|]+)\]\]", r"\1", text)
    # Remove inline links: [text](url) → text
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    # Remove emphasis markers
    text = re.sub(r"[*_`]+", "", text)
    return text.strip()


SUMMARY_HEADINGS = ("# Summary", "## Summary", "## AI Highlights:", "## AI Highlights")


def extract_summary_oneliner(text: str, max_chars: int = 200) -> str:
    """Pull the first sentence/bullet after a Summary/Highlights heading."""
    body = re.sub(FRONTMATTER_RE, "", text, count=1)
    for heading in SUMMARY_HEADINGS:
        if heading in body:
            tail = body.split(heading, 1)[1]
            # Stop at next heading
            tail = re.split(r"\n#{1,3} ", tail, maxsplit=1)[0]
            # Look for first bullet or paragraph
            for raw in tail.splitlines():
                line = raw.strip()
                if not line:
                    continue
                if line.startswith("-"):
                    line = line[1:].strip()
                clean = _strip_md(line)
                if len(clean) >= 20:  # ignore short stubs
                    return clean[:max_chars] + ("…" if len(clean) > max_chars else "")
    # Fallback: first non-frontmatter, non-heading line of substance
    for raw in body.splitlines():
        line = _strip_md(raw.strip())
        if len(line) >= 20 and not line.startswith("#"):
            return line[:max_chars] + ("…" if len(line) > max_chars else "")
    return "(no summary)"


def _source_hostname(url: str) -> str:
    m = re.match(r"https?://(?:www\.)?([^/]+)", url)
    return m.group(1) if m else url


# ──────────────────────────────────────────────────────────────────────────────
# Plan

@dataclass
class IngestPlan:
    source_path: Path  # absolute
    rel_path: str  # vault-relative
    title: str
    category: str
    summary: str
    source_url: str
    created_date: str
    skipped_reason: str = ""  # set if plan is invalid


def plan_for(source_path: Path) -> IngestPlan:
    rel_path = str(source_path.relative_to(VAULT_PATH))
    try:
        text = source_path.read_text()
    except Exception as exc:
        return IngestPlan(
            source_path=source_path, rel_path=rel_path,
            title=source_path.stem, category="", summary="",
            source_url="", created_date="",
            skipped_reason=f"unreadable: {exc}",
        )

    fm = parse_frontmatter(text)
    tags = _tags(fm)
    if "clipping" not in tags:
        return IngestPlan(
            source_path=source_path, rel_path=rel_path,
            title=source_path.stem, category="", summary="",
            source_url="", created_date="",
            skipped_reason="not a clipping (no 'clipping' tag)",
        )

    category = _determine_category(tags)
    if not category:
        return IngestPlan(
            source_path=source_path, rel_path=rel_path,
            title=source_path.stem, category="", summary="",
            source_url="", created_date="",
            skipped_reason=f"no category mapped for tags: {tags}",
        )

    title_raw = fm.get("title")
    title = str(title_raw) if isinstance(title_raw, str) and title_raw else source_path.stem
    source_url = str(fm.get("source", "")) if isinstance(fm.get("source"), str) else ""
    created_raw = fm.get("created", "")
    created_date = str(created_raw)[:10] if created_raw else date.today().isoformat()
    summary = extract_summary_oneliner(text)

    return IngestPlan(
        source_path=source_path, rel_path=rel_path,
        title=title, category=category, summary=summary,
        source_url=source_url, created_date=created_date,
    )


def render_index_line(plan: IngestPlan) -> str:
    host = f" · from {_source_hostname(plan.source_url)}" if plan.source_url else ""
    return (
        f"- **{plan.title}** ({plan.created_date}) — "
        f"[[{plan.source_path.stem}]] ({plan.rel_path}){host}. _{plan.summary}_\n"
    )


# ──────────────────────────────────────────────────────────────────────────────
# Apply

def _append_to_index(line: str, section: str) -> None:
    """Prepend a line under the given section in vault/index.md."""
    if not is_auto_write_allowed(INDEX_FILE):
        print(f"ingest: write-guard rejected {INDEX_FILE}", file=sys.stderr)
        return
    if not INDEX_FILE.exists():
        INDEX_FILE.write_text(
            "# Wiki Index\n\n"
            "> Catalog of LLM-touchable content. Updated by `memory_compile.py` "
            "and `memory_ingest.py`. Sections populate as content is added.\n"
        )
    text = INDEX_FILE.read_text()
    heading = f"## {section}"
    if heading not in text:
        text += f"\n{heading}\n\n"
    insert_at = text.index(heading) + len(heading) + len("\n\n")
    new_text = text[:insert_at] + line + text[insert_at:]
    INDEX_FILE.write_text(new_text)


def apply_plan(plan: IngestPlan) -> None:
    _append_to_index(render_index_line(plan), plan.category)
    append_to_log("ingest", plan.title, f"{plan.category} · {plan.rel_path}")
    print(f"  ✓ indexed under '{plan.category}': {plan.rel_path}")


# ──────────────────────────────────────────────────────────────────────────────
# Discovery

def find_clippings() -> list[Path]:
    """Walk 3 - Resources/ for files with 'clipping' in frontmatter tags."""
    matches: list[Path] = []
    for md in RESOURCES_DIR.rglob("*.md"):
        try:
            head = md.read_text()[:2000]
        except Exception:
            continue
        fm = parse_frontmatter(head)
        tags = _tags(fm)
        if "clipping" in tags:
            matches.append(md)
    return matches


# ──────────────────────────────────────────────────────────────────────────────
# Main

def main() -> int:
    parser = argparse.ArgumentParser(description="Catalog clipped sources into index.md")
    parser.add_argument("source", nargs="?", help="Path to a single source file (within vault)")
    parser.add_argument("--inbox", action="store_true", help="Batch-process every clipping in 3 - Resources/")
    parser.add_argument("--apply", action="store_true", help="Write to index.md / log.md (default: dry-run)")
    parser.add_argument("--force", action="store_true", help="Re-ingest sources already in state file")
    args = parser.parse_args()

    if not args.source and not args.inbox:
        parser.print_help()
        return 2

    state = load_state()

    # Build list of candidate sources
    sources: list[Path] = []
    if args.inbox:
        sources = find_clippings()
    else:
        src = Path(args.source).expanduser().resolve()
        if not src.exists():
            print(f"ingest: not found: {src}", file=sys.stderr)
            return 1
        sources = [src]

    plans: list[IngestPlan] = []
    skipped: list[tuple[Path, str]] = []
    for src in sources:
        try:
            rel = str(src.relative_to(VAULT_PATH))
        except ValueError:
            skipped.append((src, "outside vault"))
            continue
        if not args.force and rel in state:
            skipped.append((src, f"already ingested {state[rel][:10]}"))
            continue
        p = plan_for(src)
        if p.skipped_reason:
            skipped.append((src, p.skipped_reason))
            continue
        plans.append(p)

    # Report
    print(f"\nFound {len(plans)} ingestable source(s), {len(skipped)} skipped\n")
    for p in plans:
        print(f"  [{p.category}] {p.title}")
        print(f"    → {p.rel_path}")
        print(f"    summary: {p.summary[:120]}{'…' if len(p.summary) > 120 else ''}")
        print()

    if skipped and len(skipped) <= 20:
        print("Skipped:")
        for path, reason in skipped:
            print(f"  - {path.relative_to(VAULT_PATH) if path.is_relative_to(VAULT_PATH) else path}: {reason}")
        print()
    elif skipped:
        print(f"Skipped {len(skipped)} sources (use --force to re-ingest already-processed ones)\n")

    if not args.apply:
        print("(dry-run — pass --apply to write to index.md and log.md)")
        return 0

    if not plans:
        print("Nothing to apply.")
        return 0

    print(f"\nApplying {len(plans)} ingest(s)...")
    now = datetime.now().isoformat(timespec="seconds")
    for p in plans:
        apply_plan(p)
        state[p.rel_path] = now

    save_state(state)
    print(f"\ningest: done. {len(plans)} entries added to index.md, {len(plans)} lines in log.md.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
