# Heartbeat launchd installation

These plists schedule the heartbeat to fire on macOS via `launchd`. They live in this dotfiles directory as the source of truth; installation copies (or symlinks) them into `~/Library/LaunchAgents/`.

## First-time install

```bash
# Choose the platforms you've set up credentials for. GitHub works out of the box
# (gh CLI). Gmail and Jira need their respective setup steps first (see below).

# 1. Symlink each plist into LaunchAgents
ln -sf ~/.dotfiles/.claude/scripts/launchd/com.kriscard.heartbeat.github.plist \
       ~/Library/LaunchAgents/com.kriscard.heartbeat.github.plist
ln -sf ~/.dotfiles/.claude/scripts/launchd/com.kriscard.heartbeat.gmail.plist \
       ~/Library/LaunchAgents/com.kriscard.heartbeat.gmail.plist
ln -sf ~/.dotfiles/.claude/scripts/launchd/com.kriscard.heartbeat.jira.plist \
       ~/Library/LaunchAgents/com.kriscard.heartbeat.jira.plist

# 2. Load each one
launchctl load ~/Library/LaunchAgents/com.kriscard.heartbeat.github.plist
launchctl load ~/Library/LaunchAgents/com.kriscard.heartbeat.gmail.plist
launchctl load ~/Library/LaunchAgents/com.kriscard.heartbeat.jira.plist

# 3. Verify
launchctl list | grep com.kriscard.heartbeat
```

## Trigger a run manually (test)

```bash
launchctl start com.kriscard.heartbeat.github
# Then check the macOS notification + the log:
tail /tmp/heartbeat-github.log /tmp/heartbeat-github.err
# And the archived note:
ls "/Users/kriscard/obsidian-vault-kriscard/2 - Areas/Daily Ops/$(date +%Y)/Heartbeat/"
```

## Schedules

- `github` — weekdays 9:30 ET (PR review sweep, after standup)
- `gmail` — weekdays 8:15 ET (newsletter triage)
- `jira` — weekdays 8:00 ET (overdue + in-progress carry-forward check)
- *(linear — Mondays 8:00 ET, deferred to v1.1)*
- *(calendar — weekdays 7:45 ET, deferred to v1.1)*

## Disable / uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.kriscard.heartbeat.github.plist
rm ~/Library/LaunchAgents/com.kriscard.heartbeat.github.plist
```

## Credential setup (required before plists become useful)

### GitHub
Already works if `gh auth status` is logged in. No setup needed.

### Gmail
```bash
# 1. console.cloud.google.com → APIs & Services → Credentials
#    → Create OAuth 2.0 Client ID (Desktop app)
# 2. Download JSON, save it to:
#    ~/.dotfiles/.claude/scripts/integrations/.tokens/google-client-secret.json
# 3. Run the OAuth flow once:
uv run ~/.dotfiles/.claude/scripts/integrations/query.py gmail --setup
# Browser opens; approve. Token cached in .tokens/google.json.
```

### Jira
```bash
# 1. Generate API token at id.atlassian.com/manage-profile/security/api-tokens
# 2. Add to .env:
cat >> ~/.dotfiles/.claude/scripts/integrations/.env <<EOF
JIRA_EMAIL=you@company.com
JIRA_API_TOKEN=ATATT3xFf...
JIRA_DOMAIN=your-subdomain
EOF
# 3. Test:
uv run ~/.dotfiles/.claude/scripts/integrations/query.py jira overdue
```

## Gotchas

- macOS Notification permissions: the first run may not show the notification banner. Open System Settings → Notifications → find "Script Editor" / "Terminal" / the parent app and enable banners.
- launchd plists are loaded per-user. They won't run if the user is fully logged out.
- If `uv` is in a non-standard path, edit each plist's `ProgramArguments` to point at the actual `uv` binary (`which uv`).
- Run-at-load is **disabled** in all plists — they only fire on schedule. Test with `launchctl start` if you want immediate.
