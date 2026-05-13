"""Shared Google OAuth helper for Gmail + Calendar integrations.

Single OAuth client, single token file. Both APIs share .tokens/google.json
because the integration plan picked additive scopes on one consent flow
(Option A — gmail.readonly + calendar.readonly granted together).

Adding a new Google API later: append its read-only scope to SCOPES,
then have the user re-run `query.py gmail --setup` to mint a token
covering the new scope set.
"""

from __future__ import annotations

from pathlib import Path

TOKENS_DIR = Path(__file__).resolve().parent.parent / ".tokens"
TOKEN_PATH = TOKENS_DIR / "google.json"
CLIENT_SECRET_PATH = TOKENS_DIR / "google-client-secret.json"

# Read-only across all Google APIs we touch. Order matters for the consent
# screen display but not for API behavior.
SCOPES = [
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/calendar.readonly",
]


def get_credentials():
    """Load cached creds, refreshing if expired. Raises if not set up.

    Used by gmail.get_client() and calendar_api.get_client().
    """
    from google.auth.transport.requests import Request
    from google.oauth2.credentials import Credentials

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
    return creds


def run_setup() -> int:
    """Interactive OAuth flow — user runs this once for all Google APIs."""
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
