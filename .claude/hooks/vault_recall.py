#!/usr/bin/env python3
"""UserPromptSubmit hook: force a vault lookup on knowledge/recall questions.

Design note: there is no fast AND accurate vault search. BM25 (`qmd search`) is
sub-second but matches common words and fires on everything; the accurate path
(`qmd query`, auto-expand + rerank) is ~25s and would block every prompt. So
this hook does NOT search inside the hook. Instead it gates on knowledge-question
intent (regex, ~0 latency) and injects a directive telling Claude to run the
real search in-turn. The gate is what kills noise; "commit my changes" never
matches, so nothing is injected. A cheap BM25 head-start is appended only when it
returns strong hits, and is explicitly marked as approximate.

Never blocks: any failure exits 0 silently.
"""
import json
import os
import re
import subprocess
import sys

# First-person recall phrasings. Deliberately high-precision: we want silence on
# everything that isn't the user asking about their OWN accumulated knowledge.
INTENT_RE = re.compile(
    r"\b("
    r"what do i know|what did i (learn|write|decide|note|say|think|conclude)|"
    r"do i have (notes|anything|something)|did i (write|note|decide|learn|read|save)|"
    r"have i (learned|written|noted|read|decided|saved)|"
    r"(in|from|check|search|find .* in) my (notes|vault)|my notes (on|about)|"
    r"we (discussed|talked about|decided|figured out)|i already (know|have|wrote|noted)|"
    r"what do i think about|connect .+ (and|with) .+|bridges? between|"
    r"have i (looked|thought) (at|about)|did we (discuss|decide|talk about)"
    r")\b",
    re.IGNORECASE,
)

THRESHOLD = 0.6   # BM25 head-start: only surface clearly-strong hits
MAX_HITS = 3

QMD_ENV = {
    **os.environ,
    "PATH": os.path.expanduser("~/.asdf/shims") + ":/opt/homebrew/bin:" + os.environ.get("PATH", ""),
}


def bm25_candidates(prompt):
    try:
        result = subprocess.run(
            ["qmd", "search", prompt[:200], "--json", "-n", str(MAX_HITS)],
            capture_output=True, text=True, timeout=4, env=QMD_ENV,
        )
        hits = json.loads(result.stdout)
    except Exception:
        return []
    out = []
    for h in hits:
        if h.get("score", 0) < THRESHOLD:
            continue
        path = h.get("file", "").replace("qmd://vault/", "")
        out.append(f"  - {h.get('docid','')}  {path}  ({h.get('score',0):.2f})")
    return out


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    prompt = (data.get("prompt") or "").strip()
    if not prompt or not INTENT_RE.search(prompt):
        sys.exit(0)

    lines = [
        "This reads as a question about the user's OWN vault knowledge. Before "
        "answering from general knowledge, run the memory-recall skill: it reads the "
        "wiki index (index.md) first, then drills into the relevant notes and cites "
        "them. Do not answer from training data until the vault has been checked.",
    ]
    cands = bm25_candidates(prompt)
    if cands:
        lines.append("Optional BM25 head-start (keyword-only, may be off-topic; the "
                     "skill's index-first pass is authoritative):")
        lines.extend(cands)

    print("\n".join(lines))
    sys.exit(0)


if __name__ == "__main__":
    main()
