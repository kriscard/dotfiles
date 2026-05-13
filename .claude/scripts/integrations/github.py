"""GitHub integration — shells out to `gh` CLI for credential isolation.

Uses the `gh` CLI's existing auth (run `gh auth status` to confirm). No
OAuth dance, no token storage in this module — `gh` holds it. The LLM
never sees the token.

Use cases:
    - PR review sweep (assigned to you)
    - Your own open PRs awaiting review
    - Mentions in last 7 days
"""

from __future__ import annotations

import json
import subprocess
from dataclasses import dataclass

from .lib.formatters import FormattedItem, render_section


@dataclass
class PullRequest:
    number: int
    title: str
    repo: str
    author: str
    additions: int
    deletions: int
    url: str

    @property
    def loc(self) -> int:
        return self.additions + self.deletions

    @property
    def depth_hint(self) -> str:
        """Heuristic for review depth. Refine in v2."""
        if self.loc < 50:
            return "trivial"
        if self.loc < 300:
            return "moderate"
        return "deep"


def _gh_json(args: list[str]) -> list[dict]:
    """Run `gh` and return parsed JSON. Never logs the command's full output."""
    result = subprocess.run(
        ["gh", *args],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"gh failed (exit {result.returncode}). "
            f"Run `gh auth status` to verify credentials."
        )
    try:
        return json.loads(result.stdout) if result.stdout.strip() else []
    except json.JSONDecodeError:
        return []


def list_review_requests(user: str = "@me") -> list[PullRequest]:
    """PRs where the user is a requested reviewer, still open."""
    raw = _gh_json(
        [
            "search",
            "prs",
            "--review-requested",
            user,
            "--state",
            "open",
            "--limit",
            "50",
            "--json",
            "number,title,repository,author,url",
        ]
    )
    prs = []
    for r in raw:
        # Per-PR diff stats require a second call; the search API doesn't return them
        stats = _pr_stats(r["repository"]["nameWithOwner"], r["number"])
        prs.append(
            PullRequest(
                number=r["number"],
                title=r["title"],
                repo=r["repository"]["nameWithOwner"],
                author=r["author"]["login"],
                additions=stats[0],
                deletions=stats[1],
                url=r["url"],
            )
        )
    return prs


def list_my_open_prs(user: str = "@me") -> list[PullRequest]:
    """PRs the user opened, still open."""
    raw = _gh_json(
        [
            "search",
            "prs",
            "--author",
            user,
            "--state",
            "open",
            "--limit",
            "30",
            "--json",
            "number,title,repository,author,url",
        ]
    )
    prs = []
    for r in raw:
        stats = _pr_stats(r["repository"]["nameWithOwner"], r["number"])
        prs.append(
            PullRequest(
                number=r["number"],
                title=r["title"],
                repo=r["repository"]["nameWithOwner"],
                author=r["author"]["login"],
                additions=stats[0],
                deletions=stats[1],
                url=r["url"],
            )
        )
    return prs


def _pr_stats(repo: str, number: int) -> tuple[int, int]:
    """Return (additions, deletions) for a PR. Best-effort, returns (0,0) on failure."""
    try:
        result = subprocess.run(
            ["gh", "pr", "view", str(number), "--repo", repo, "--json", "additions,deletions"],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            return (0, 0)
        data = json.loads(result.stdout)
        return (int(data.get("additions", 0)), int(data.get("deletions", 0)))
    except Exception:
        return (0, 0)


def format_for_context(prs: list[PullRequest], heading: str) -> str:
    """Format PRs as markdown for heartbeat context."""
    items = []
    for pr in prs:
        priority = "high" if pr.depth_hint == "deep" else "normal"
        items.append(
            FormattedItem(
                title=f"{pr.repo}#{pr.number} — {pr.title}",
                subtitle=f"by {pr.author}, {pr.loc} LOC, {pr.depth_hint}",
                url=pr.url,
                priority=priority,
            )
        )
    return render_section(heading, items)


def cli(args: list[str]) -> int:
    if not args:
        print("github subcommands: prs | my-prs", file=__import__("sys").stderr)
        return 2
    sub = args[0]
    try:
        if sub == "prs":
            prs = list_review_requests()
            print(format_for_context(prs, "GitHub — PRs awaiting your review"))
            return 0
        if sub == "my-prs":
            prs = list_my_open_prs()
            print(format_for_context(prs, "GitHub — Your open PRs"))
            return 0
        print(f"Unknown subcommand: {sub}", file=__import__("sys").stderr)
        return 2
    except RuntimeError as exc:
        print(f"github error: {exc}", file=__import__("sys").stderr)
        return 1
