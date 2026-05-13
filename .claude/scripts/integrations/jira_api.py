"""Jira integration — read-only ticket queries for Roofr work.

Uses an Atlassian API token (read from .env). Weekday-only schedule per
HEARTBEAT.md.

Setup:
    1. Generate token at id.atlassian.com/manage-profile/security/api-tokens
    2. Add to .env:
         JIRA_EMAIL=you@company.com
         JIRA_API_TOKEN=ATATT3xFf...
         JIRA_DOMAIN=your-org      # the subdomain before .atlassian.net
"""

from __future__ import annotations

import os
from dataclasses import dataclass

from .lib.env import require
from .lib.formatters import FormattedItem, render_section
from .lib.sanitize import sanitize_external


@dataclass
class Issue:
    key: str
    summary: str
    status: str
    assignee: str
    due_date: str
    days_in_status: int
    url: str


def get_client():
    from jira import JIRA  # lazy import

    email = require("JIRA_EMAIL")
    token = require("JIRA_API_TOKEN")
    domain = require("JIRA_DOMAIN")
    return JIRA(
        server=f"https://{domain}.atlassian.net",
        basic_auth=(email, token),
    )


def _to_issue(j) -> Issue:
    """Map a JIRA library Issue to our dataclass."""
    fields = j.fields
    status = fields.status.name if fields.status else "Unknown"
    assignee = fields.assignee.displayName if fields.assignee else "Unassigned"
    due = fields.duedate or ""
    # JIRA exposes changelog only with expand=changelog; cheap approximation
    days_in_status = 0
    try:
        from datetime import datetime, timezone
        updated = fields.updated
        if updated:
            updated_dt = datetime.fromisoformat(updated.replace("Z", "+00:00"))
            now = datetime.now(timezone.utc)
            days_in_status = (now - updated_dt).days
    except Exception:
        pass
    return Issue(
        key=j.key,
        summary=fields.summary,
        status=status,
        assignee=assignee,
        due_date=due,
        days_in_status=days_in_status,
        url=f"{j.permalink()}",
    )


def list_my_overdue(account_id: str | None = None) -> list[Issue]:
    client = get_client()
    me = account_id or "currentUser()"
    jql = (
        f"assignee = {me} AND duedate < now() "
        f'AND status NOT IN ("Done", "Closed", "Cancelled", "Resolved")'
    )
    return [_to_issue(i) for i in client.search_issues(jql, maxResults=30)]


def list_my_in_progress(account_id: str | None = None) -> list[Issue]:
    client = get_client()
    me = account_id or "currentUser()"
    jql = f'assignee = {me} AND status = "In Progress"'
    return [_to_issue(i) for i in client.search_issues(jql, maxResults=30)]


def list_my_blocked(account_id: str | None = None) -> list[Issue]:
    client = get_client()
    me = account_id or "currentUser()"
    jql = f'assignee = {me} AND status = "Blocked"'
    return [_to_issue(i) for i in client.search_issues(jql, maxResults=30)]


def format_for_context(issues: list[Issue], heading: str) -> str:
    items: list[FormattedItem] = []
    for i in issues:
        # Summary is untrusted (user-written) but typically short and benign;
        # full sanitization would make output noisy. Keep it as-is for headings.
        # If we surface description text in v2, wrap that through sanitize.
        subtitle_parts = [f"status={i.status}"]
        if i.assignee != "Unassigned":
            subtitle_parts.append(f"assigned to {i.assignee}")
        if i.due_date:
            subtitle_parts.append(f"due {i.due_date}")
        if i.days_in_status > 5 and i.status == "In Progress":
            subtitle_parts.append(f"in progress {i.days_in_status}d")
        items.append(
            FormattedItem(
                title=f"{i.key} — {i.summary}",
                subtitle=", ".join(subtitle_parts),
                url=i.url,
                priority="high" if (i.days_in_status > 5 or i.due_date) else "normal",
            )
        )
    return render_section(heading, items)


def cli(args: list[str]) -> int:
    import sys

    if not args:
        print(
            "jira subcommands: overdue | in-progress | blocked",
            file=sys.stderr,
        )
        return 2

    sub = args[0]
    try:
        if sub == "overdue":
            print(format_for_context(list_my_overdue(), "Jira — Overdue"))
            return 0
        if sub == "in-progress":
            print(format_for_context(list_my_in_progress(), "Jira — In progress"))
            return 0
        if sub == "blocked":
            print(format_for_context(list_my_blocked(), "Jira — Blocked"))
            return 0
        print(f"Unknown subcommand: {sub}", file=sys.stderr)
        return 2
    except RuntimeError as exc:
        print(f"jira error: {exc}", file=sys.stderr)
        return 1
    except ImportError as exc:
        print(
            f"jira error: missing Python deps ({exc}). "
            f"Run via `uv run query.py` which auto-installs them.",
            file=sys.stderr,
        )
        return 1
