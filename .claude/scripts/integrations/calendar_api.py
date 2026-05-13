"""Google Calendar integration — read-only schedule queries.

Shares OAuth client + token with gmail.py via lib/google_auth.py. Surfaces
upcoming events for the heartbeat morning brief.

NEVER creates, edits, or deletes events. Read-only scope enforced in
lib/google_auth.SCOPES.

First-time setup (covers Gmail + Calendar in one consent flow):
    uv run query.py gmail --setup

Subcommands:
    today   — events today on primary calendar (skips declined / all-day)
    next    — next ≤3 events within the next 8h
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

from .lib.formatters import FormattedItem, render_section
from .lib.google_auth import get_credentials

# User's local timezone — used for "today" window boundaries and display.
LOCAL_TZ = ZoneInfo("America/Toronto")


@dataclass
class Event:
    id: str
    title: str
    start: datetime
    end: datetime
    all_day: bool
    status: str          # "confirmed" | "tentative" | "cancelled"
    response: str        # self responseStatus: accepted/declined/tentative/needsAction
    location: str
    url: str


def get_client():
    """Lazy-imports googleapiclient so the rest of the package stays light."""
    from googleapiclient.discovery import build

    creds = get_credentials()
    return build("calendar", "v3", credentials=creds, cache_discovery=False)


def _parse_dt(raw: str) -> datetime:
    """RFC3339 → aware datetime. Python 3.10 fromisoformat() chokes on 'Z'."""
    if raw.endswith("Z"):
        raw = raw[:-1] + "+00:00"
    return datetime.fromisoformat(raw)


def _parse_event(raw: dict) -> Event:
    start_block = raw["start"]
    end_block = raw["end"]
    all_day = "date" in start_block

    if all_day:
        start = datetime.fromisoformat(start_block["date"]).replace(tzinfo=LOCAL_TZ)
        end = datetime.fromisoformat(end_block["date"]).replace(tzinfo=LOCAL_TZ)
    else:
        start = _parse_dt(start_block["dateTime"])
        end = _parse_dt(end_block["dateTime"])

    # If attendees array is absent, user is the sole organizer → implicitly accepted.
    response = "accepted"
    for attendee in raw.get("attendees", []):
        if attendee.get("self"):
            response = attendee.get("responseStatus", "accepted")
            break

    return Event(
        id=raw["id"],
        title=raw.get("summary", "(no title)"),
        start=start,
        end=end,
        all_day=all_day,
        status=raw.get("status", "confirmed"),
        response=response,
        location=raw.get("location", ""),
        url=raw.get("htmlLink", ""),
    )


def _passes_filters(e: Event) -> bool:
    """Default filters: skip cancelled, skip declined, skip all-day."""
    if e.status == "cancelled":
        return False
    if e.response == "declined":
        return False
    if e.all_day:
        return False
    return True


def _list_events(time_min: datetime, time_max: datetime) -> list[Event]:
    service = get_client()
    resp = service.events().list(
        calendarId="primary",
        timeMin=time_min.isoformat(),
        timeMax=time_max.isoformat(),
        singleEvents=True,   # expand recurring events into instances
        orderBy="startTime",
        maxResults=50,
    ).execute()
    events = [_parse_event(item) for item in resp.get("items", [])]
    return [e for e in events if _passes_filters(e)]


def list_today() -> list[Event]:
    """Events on the user's local 'today' (midnight to midnight)."""
    now = datetime.now(LOCAL_TZ)
    start_of_day = now.replace(hour=0, minute=0, second=0, microsecond=0)
    end_of_day = start_of_day + timedelta(days=1)
    return _list_events(start_of_day, end_of_day)


def list_next(within_hours: int = 8, limit: int = 3) -> list[Event]:
    """Up to `limit` events starting in the next `within_hours` hours."""
    now = datetime.now(LOCAL_TZ)
    window_end = now + timedelta(hours=within_hours)
    upcoming = [e for e in _list_events(now, window_end) if e.start >= now]
    return upcoming[:limit]


def _fmt_clock(e: Event) -> str:
    start = e.start.astimezone(LOCAL_TZ).strftime("%H:%M")
    end = e.end.astimezone(LOCAL_TZ).strftime("%H:%M")
    return f"{start}–{end}"


def _fmt_relative(target: datetime) -> str:
    """'in 15min' / 'in 2h 30min' — leading 'in 0min' suppressed to 'now'."""
    minutes = max(0, int((target - datetime.now(LOCAL_TZ)).total_seconds() // 60))
    if minutes == 0:
        return "now"
    if minutes < 60:
        return f"in {minutes}min"
    hours, mins = divmod(minutes, 60)
    return f"in {hours}h {mins}min" if mins else f"in {hours}h"


def format_today(events: list[Event]) -> str:
    items = [
        FormattedItem(title=e.title, subtitle=_fmt_clock(e), url=e.url)
        for e in events
    ]
    return render_section("Calendar — Today", items)


def format_next(events: list[Event]) -> str:
    items = [
        FormattedItem(
            title=e.title,
            subtitle=f"{_fmt_relative(e.start)} ({_fmt_clock(e)})",
            url=e.url,
        )
        for e in events
    ]
    return render_section("Calendar — Next up", items)


def cli(args: list[str]) -> int:
    import sys

    if not args:
        print(
            "calendar subcommands: today | next\n"
            "Setup (shared with gmail): `query.py gmail --setup`",
            file=sys.stderr,
        )
        return 2

    sub = args[0]
    try:
        if sub == "today":
            print(format_today(list_today()))
            return 0
        if sub == "next":
            print(format_next(list_next()))
            return 0
        print(f"Unknown subcommand: {sub}", file=sys.stderr)
        return 2
    except RuntimeError as exc:
        print(f"calendar error: {exc}", file=sys.stderr)
        return 1
    except ImportError as exc:
        print(
            f"calendar error: missing Python deps ({exc}). "
            f"Run via `uv run query.py` which auto-installs them.",
            file=sys.stderr,
        )
        return 1
