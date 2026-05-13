"""Gmail integration — read-only triage.

NEVER drafts, NEVER sends. Surfaces important unread emails for the
heartbeat morning brief. OAuth tokens cached at .tokens/google.json
(gitignored). The LLM only sees subjects + senders + sanitized snippets,
never the OAuth token itself.

First-time setup:
    uv run github_path/integrations/query.py gmail --setup

This opens a browser for Google OAuth consent. After approval, the token
is cached and subsequent runs are non-interactive.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path

from .lib.formatters import FormattedItem, render_section
from .lib.sanitize import sanitize_external

TOKENS_DIR = Path(__file__).resolve().parent / ".tokens"
TOKEN_PATH = TOKENS_DIR / "google.json"
CLIENT_SECRET_PATH = TOKENS_DIR / "google-client-secret.json"

# Read-only scope — explicitly forbid send/modify.
SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"]

# Triage rules (sender + subject keyword heuristics).
IMPORTANT_SENDER_FRAGMENTS = (
    "@roofr.com",
    "newsletter",
    "@anthropic.com",
    "noreply@github.com",  # PR / issue digests
)
IMPORTANT_SUBJECT_KEYWORDS = (
    "this week in",     # newsletter pattern (react, next.js, etc.)
    "action required",
    "deadline",
    "approve",
    "urgent",
    "security advisory",
)


@dataclass
class Email:
    id: str
    sender: str
    subject: str
    snippet: str
    date: str
    url: str


def _is_important(sender: str, subject: str) -> bool:
    s_lo = sender.lower()
    sub_lo = subject.lower()
    if any(frag in s_lo for frag in IMPORTANT_SENDER_FRAGMENTS):
        return True
    if any(kw in sub_lo for kw in IMPORTANT_SUBJECT_KEYWORDS):
        return True
    return False


def get_client():
    """Lazy-imports googleapiclient so the rest of the package stays light."""
    from google.auth.transport.requests import Request
    from google.oauth2.credentials import Credentials
    from googleapiclient.discovery import build

    if not TOKEN_PATH.exists():
        raise RuntimeError(
            f"No Google OAuth token at {TOKEN_PATH}. "
            f"Run `uv run query.py gmail --setup` to authenticate."
        )

    creds = Credentials.from_authorized_user_file(str(TOKEN_PATH), SCOPES)
    if not creds.valid:
        if creds.expired and creds.refresh_token:
            creds.refresh(Request())
            TOKEN_PATH.write_text(creds.to_json())
        else:
            raise RuntimeError(
                "Google OAuth token is invalid and cannot be refreshed. "
                "Re-run `--setup`."
            )
    return build("gmail", "v1", credentials=creds, cache_discovery=False)


def run_setup() -> int:
    """Interactive OAuth flow — user runs this once."""
    from google_auth_oauthlib.flow import InstalledAppFlow

    if not CLIENT_SECRET_PATH.exists():
        print(
            f"Missing {CLIENT_SECRET_PATH}.\n\n"
            f"Setup steps:\n"
            f"  1. console.cloud.google.com → APIs & Services → Credentials\n"
            f"  2. Create OAuth 2.0 Client ID (Desktop application)\n"
            f"  3. Download JSON, save to {CLIENT_SECRET_PATH}\n"
            f"  4. Re-run this command.\n"
        )
        return 1

    TOKENS_DIR.mkdir(parents=True, exist_ok=True)
    flow = InstalledAppFlow.from_client_secrets_file(str(CLIENT_SECRET_PATH), SCOPES)
    creds = flow.run_local_server(port=0)
    TOKEN_PATH.write_text(creds.to_json())
    print(f"Token cached at {TOKEN_PATH}. Subsequent runs will not prompt.")
    return 0


def list_important_unread(since_hours: int = 16) -> list[Email]:
    """Fetch unread mail filtered against the triage rules."""
    service = get_client()
    query = f"is:unread newer_than:{since_hours}h"
    list_resp = service.users().messages().list(
        userId="me", q=query, maxResults=50
    ).execute()
    msgs = list_resp.get("messages", [])

    important: list[Email] = []
    for m in msgs:
        full = service.users().messages().get(
            userId="me",
            id=m["id"],
            format="metadata",
            metadataHeaders=["From", "Subject", "Date"],
        ).execute()
        headers = {h["name"]: h["value"] for h in full["payload"]["headers"]}
        sender = headers.get("From", "")
        subject = headers.get("Subject", "(no subject)")
        if not _is_important(sender, subject):
            continue
        important.append(
            Email(
                id=m["id"],
                sender=sender,
                subject=subject,
                snippet=full.get("snippet", ""),
                date=headers.get("Date", ""),
                url=f"https://mail.google.com/mail/u/0/#inbox/{m['id']}",
            )
        )
    return important


def count_total_unread() -> int:
    service = get_client()
    # `is:unread in:inbox` to avoid counting promotions/social archives
    resp = service.users().messages().list(
        userId="me", q="is:unread in:inbox", maxResults=1
    ).execute()
    return int(resp.get("resultSizeEstimate", 0))


def format_for_context(emails: list[Email], heading: str) -> str:
    items = []
    for e in emails:
        # Snippet is untrusted external content — wrap it
        safe_snippet = sanitize_external(e.snippet, "gmail") if e.snippet else ""
        items.append(
            FormattedItem(
                title=e.subject,
                subtitle=f"from {e.sender}",
                url=e.url,
                priority="normal",
            )
        )
    rendered = render_section(heading, items)
    if not emails:
        return rendered
    # Append snippet blocks below (sanitized)
    snippets = [
        f"\n### {e.subject}\n{sanitize_external(e.snippet, 'gmail')}"
        for e in emails if e.snippet
    ]
    return rendered + "".join(snippets)


def cli(args: list[str]) -> int:
    import sys

    if not args:
        print("gmail subcommands: triage | count-unread | --setup", file=sys.stderr)
        return 2

    sub = args[0]
    try:
        if sub == "--setup":
            return run_setup()
        if sub == "triage":
            emails = list_important_unread()
            print(format_for_context(emails, "Gmail — Important unread"))
            return 0
        if sub == "count-unread":
            count = count_total_unread()
            print(f"Total unread in inbox: {count}")
            return 0
        print(f"Unknown subcommand: {sub}", file=sys.stderr)
        return 2
    except RuntimeError as exc:
        print(f"gmail error: {exc}", file=sys.stderr)
        return 1
    except ImportError as exc:
        print(
            f"gmail error: missing Python deps ({exc}). "
            f"Run via `uv run query.py` which auto-installs them.",
            file=sys.stderr,
        )
        return 1
