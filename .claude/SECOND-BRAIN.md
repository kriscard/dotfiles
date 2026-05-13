# Second Brain — Setup Guide

End-to-end instructions for reproducing this AI second brain on a new machine (work laptop, new personal machine, etc.). The system is local-first, vault-based, and built on Claude Code + Claude Agent SDK.

Based on the [second-brain-starter](https://github.com/coleam00/second-brain-starter) architecture, adapted to Chris's existing Obsidian PARA vault.

---

## What this system does

- **Remembers** across Claude Code sessions via vault-backed `SOUL.md`/`USER.md`/`MEMORY.md` + session capture
- **Searches** months of personal notes with hybrid keyword + vector + LLM-rerank (qmd)
- **Captures** every Claude Code conversation as a daily session log
- **Distills** session logs into PARA concept notes (memory_compile.py)
- **Monitors** proactively via scheduled heartbeat: surfaces new GitHub PR reviews, important Gmail, overdue Jira on weekdays
- **Defends** with a 3-layer sanitization wrapper for any external content
- **Routes credentials** through Python CLI wrappers — the LLM never sees API keys

---

## Prerequisites

| Tool | Why | Install |
|---|---|---|
| macOS (Sequoia or newer) | launchd scheduling | n/a |
| Python 3.10+ | scripts | `brew install python` |
| `uv` | inline-script dep management | `brew install uv` or `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| GNU `stow` | dotfiles symlinking | `brew install stow` |
| Obsidian | vault viewer + CLI | obsidian.md (install + enable CLI in Settings → General) |
| `gh` CLI | GitHub integration | `brew install gh` then `gh auth login` |
| `qmd` | hybrid vault search | `npm i -g @tobilu/qmd` |
| Node.js | qmd runtime | `brew install node` |
| `fd`, `rg`, `ast-grep`, `zoxide`, `tree` | modern CLI defaults | `brew install fd ripgrep ast-grep zoxide tree` |

Optional but recommended:
- VSCode / Neovim with Claude Code extension
- A separate Google Cloud project for Gmail OAuth (if Gmail integration desired)
- An Atlassian API token if Jira integration desired

---

## 1. Clone dotfiles + stow

```bash
git clone git@github.com:kriscard/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --target=$HOME .
```

This symlinks:
- `~/.dotfiles/.claude/` → `~/.claude/` (hooks, scripts, skills, settings)
- `~/.dotfiles/.config/` → `~/.config/`
- All other dotfile targets

Verify:
```bash
ls -l ~/.claude/hooks/memory_*.py
ls -l ~/.claude/scripts/heartbeat.py
ls -l ~/.claude/scripts/integrations/
```

Each should point at the `~/.dotfiles/.claude/...` source.

---

## 2. Vault setup

### 2a. Sync the Obsidian vault

If using **Obsidian Sync**: log in, restore vault to `~/obsidian-vault-<your-username>/`.

If using **git-backed vault**: clone it.

**Important: vault path.** The hooks hardcode `/Users/kriscard/obsidian-vault-kriscard`. On a new machine with a different username, edit `~/.dotfiles/.claude/hooks/lib/memory_common.py:9`:
```python
VAULT_PATH = Path("/Users/<username>/obsidian-vault-kriscard")
```
*(Future improvement: env var fallback — see TODO in setup recap.)*

### 2b. Enable Obsidian CLI

Obsidian → Settings → General → enable **"Command line interface"**. Verify:
```bash
obsidian --version
```

### 2c. Install Web Clipper templates

Repo: https://github.com/kriscard/obsidian-web-clippers

```bash
git clone git@github.com:kriscard/obsidian-web-clippers.git ~/projects/obsidian-web-clippers
```

In the Obsidian Web Clipper browser extension settings:
- Templates → Import → import each `.json` file from the repo
- Verify the `path` field in each template matches your vault structure (e.g. `3 - Resources/Articles/`)

### 2d. Confirm the memory-layer files exist

These should already be in the synced vault:

```bash
ls /Users/<username>/obsidian-vault-kriscard/
# Expected: SOUL.md, USER.md, MEMORY.md, AGENTS.md, HEARTBEAT.md
```

If missing, copy them from the canonical machine — they're vault content, not dotfiles.

---

## 3. QMD search index

QMD provides hybrid BM25 + vector + LLM rerank over the vault.

```bash
# Install
npm i -g @tobilu/qmd

# Register vault as a collection
qmd collection add /Users/<username>/obsidian-vault-kriscard --name vault

# Build the index (downloads ~333MB embedding model first run; ~2-3 min for a ~500-note vault)
qmd embed

# Verify search works (downloads ~1.28GB reranker on first call)
qmd query "PARA structure" --json -n 3
```

---

## 4. Verify hooks

Claude Code reads hooks from `~/.claude/settings.json`. Should already be wired by step 1 (stow). Verify:

```bash
grep -A2 '"SessionStart"\|"SessionEnd"\|"PreCompact"' ~/.claude/settings.json
```

Each should point at `~/.dotfiles/.claude/hooks/memory_session_*.py`.

**Test the SessionStart payload size** — it must stay under ~10 KB or Claude Code evicts it to disk:

```bash
echo '{}' | uv run ~/.dotfiles/.claude/hooks/memory_session_start.py | wc -c
# Expected: under 10000. Current ~8.6 KB.
```

If over the threshold, trim AGENTS.md / USER.md per the same pattern already in the hook.

**Test in Claude Code:** open a session in the vault and run `/context`. The `Memory files` line should show **~2–3K tokens** (not 858 = just CLAUDE.md). If 858, the hook output is being evicted.

---

## 5. Auto-memory dir

Claude Code uses `~/.claude/projects/<slug>/memory/` as a harness-guaranteed inline tier. Populate with the typed feedback memories that exist on the canonical machine:

```bash
# Copy memories from the source machine
mkdir -p ~/.claude/projects/-Users-<username>-obsidian-vault-kriscard/memory/
scp source-machine:~/.claude/projects/-Users-kriscard-obsidian-vault-kriscard/memory/*.md \
    ~/.claude/projects/-Users-<username>-obsidian-vault-kriscard/memory/
```

Or rebuild on the new machine by asking Claude (in a new session) to remember the same feedback rules.

---

## 6. Integrations layer

Pattern: Python CLI wrapper holds credentials. LLM shells out to `query.py <platform> <subcommand>` and receives only data — never tokens.

### 6a. GitHub (zero setup needed)

```bash
# Verify gh CLI is authenticated
gh auth status

# Test the integration
uv run ~/.dotfiles/.claude/scripts/integrations/query.py github prs
uv run ~/.dotfiles/.claude/scripts/integrations/query.py github my-prs
```

First run installs ~30 Python deps via `uv` (one-time, ~10 seconds).

### 6b. Gmail (OAuth)

```bash
# 1. Create OAuth credentials
#    Go to: console.cloud.google.com → APIs & Services → Credentials
#    Create OAuth 2.0 Client ID → Application type: Desktop app
#    Download JSON.

# 2. Save credentials file:
mkdir -p ~/.dotfiles/.claude/scripts/integrations/.tokens
mv ~/Downloads/client_secret_*.json \
   ~/.dotfiles/.claude/scripts/integrations/.tokens/google-client-secret.json

# 3. Run the OAuth flow (opens browser):
uv run ~/.dotfiles/.claude/scripts/integrations/query.py gmail --setup

# 4. After approving, the token is cached. Test:
uv run ~/.dotfiles/.claude/scripts/integrations/query.py gmail triage
uv run ~/.dotfiles/.claude/scripts/integrations/query.py gmail count-unread
```

Scope is **gmail.readonly only**. The system never drafts or sends emails.

**Triage rules** (`~/.dotfiles/.claude/scripts/integrations/gmail.py`):
- Important senders: `@roofr.com`, `newsletter`, `@anthropic.com`, `noreply@github.com`
- Important subjects: `this week in`, `action required`, `deadline`, `approve`, `urgent`, `security advisory`

Edit the constants `IMPORTANT_SENDER_FRAGMENTS` / `IMPORTANT_SUBJECT_KEYWORDS` to tune for your inbox.

### 6c. Jira (API token)

```bash
# 1. Generate token: id.atlassian.com/manage-profile/security/api-tokens

# 2. Create .env file:
cat > ~/.dotfiles/.claude/scripts/integrations/.env <<'EOF'
JIRA_EMAIL=your.email@your-org.com
JIRA_API_TOKEN=ATATT3xFf...
JIRA_DOMAIN=your-subdomain     # without .atlassian.net
EOF

# 3. Test:
uv run ~/.dotfiles/.claude/scripts/integrations/query.py jira overdue
uv run ~/.dotfiles/.claude/scripts/integrations/query.py jira in-progress
uv run ~/.dotfiles/.claude/scripts/integrations/query.py jira blocked
```

The `.env` is gitignored — never commit it.

### 6d. Linear / Calendar (deferred)

Templates exist; modules not built yet. When ready, copy `integration_template.py` to `linear.py` / `calendar_api.py` and follow the existing patterns.

---

## 7. Heartbeat scheduling (launchd)

The heartbeat fires on schedule via macOS launchd. Source plists live in dotfiles; symlink into `~/Library/LaunchAgents/` to activate.

```bash
# Symlink each plist
ln -sf ~/.dotfiles/.claude/scripts/launchd/com.kriscard.heartbeat.github.plist \
       ~/Library/LaunchAgents/com.kriscard.heartbeat.github.plist
ln -sf ~/.dotfiles/.claude/scripts/launchd/com.kriscard.heartbeat.gmail.plist \
       ~/Library/LaunchAgents/com.kriscard.heartbeat.gmail.plist
ln -sf ~/.dotfiles/.claude/scripts/launchd/com.kriscard.heartbeat.jira.plist \
       ~/Library/LaunchAgents/com.kriscard.heartbeat.jira.plist

# Load each
launchctl load ~/Library/LaunchAgents/com.kriscard.heartbeat.github.plist
launchctl load ~/Library/LaunchAgents/com.kriscard.heartbeat.gmail.plist
launchctl load ~/Library/LaunchAgents/com.kriscard.heartbeat.jira.plist

# Verify
launchctl list | grep com.kriscard.heartbeat

# Test immediately (don't wait for schedule)
launchctl start com.kriscard.heartbeat.github

# Inspect logs
tail /tmp/heartbeat-github.log /tmp/heartbeat-github.err
```

**Schedules (Eastern Time):**
- `github` — weekdays 9:30 (PR review sweep, post-standup)
- `gmail` — weekdays 8:15 (newsletter triage)
- `jira` — weekdays 8:00 (overdue + in-progress carry awareness)

**The plists' `RunAtLoad` is `false`** — they don't fire on load, only on schedule.

### Notification permissions

macOS may suppress notifications until you grant permission. After the first manual `launchctl start`:
- System Settings → Notifications → find the helper that triggered (often "Script Editor" or "Terminal")
- Enable banners

### Heartbeat dry-run (no notification, no cost)

```bash
uv run ~/.dotfiles/.claude/scripts/heartbeat.py --mode github --dry-run
```

Useful while tuning triage rules or testing new integrations.

---

## 8. Optional: install the create-second-brain-prd skill

If you want to regenerate a PRD on the new machine:

```bash
git clone https://github.com/coleam00/second-brain-starter /tmp/sb-starter
mkdir -p ~/.claude/skills/create-second-brain-prd
cp -r /tmp/sb-starter/.claude/skills/create-second-brain-prd/* \
      ~/.claude/skills/create-second-brain-prd/
```

The skill is **optional** — the system is already built. The skill is only useful if you want to revise requirements and regenerate the build plan.

---

## 9. End-to-end verification checklist

After everything is set up:

| Check | Command | Expected |
|---|---|---|
| Hook size | `echo '{}' \| uv run ~/.dotfiles/.claude/hooks/memory_session_start.py \| wc -c` | < 10000 |
| qmd indexed | `qmd ls` | shows vault collection |
| qmd recall works | `qmd query "PARA" --json -n 2` | returns notes |
| GitHub integration | `uv run ~/.dotfiles/.claude/scripts/integrations/query.py github prs` | markdown or empty section |
| Gmail integration (after OAuth) | `uv run ... query.py gmail triage` | markdown or empty section |
| Jira integration (after .env) | `uv run ... query.py jira overdue` | markdown or empty section |
| Heartbeat dry-run | `uv run ~/.dotfiles/.claude/scripts/heartbeat.py --mode github --dry-run` | prints sections, no notification |
| launchd loaded | `launchctl list \| grep kriscard.heartbeat` | 3 entries |
| Manual heartbeat fires | `launchctl start com.kriscard.heartbeat.github` then check macOS notification | banner appears within 10–60 sec |
| /context in Claude Code | open session in vault, run `/context` | Memory files ~2-3K tokens (not 858) |

---

## Architecture overview

```
                ┌─────────────────────────────────────────┐
                │            Obsidian Vault               │
                │  SOUL.md  USER.md  MEMORY.md  AGENTS.md │
                │  Claude Sessions/  3 - Resources/       │
                │  HEARTBEAT.md  MOCs/Claude Memory MOC   │
                └─────────────────────────────────────────┘
                            │             ▲
              SessionStart  │             │  SessionEnd / PreCompact
              loads memory  │             │  captures session
                            ▼             │
                ┌─────────────────────────────────────────┐
                │            Claude Code                  │
                │   (hooks fire on lifecycle events)      │
                └─────────────────────────────────────────┘
                            ▲             │
                       /context           │ subprocess
                       (memory recall)    │
                            │             ▼
                ┌─────────────────────────────────────────┐
                │       Python scripts (dotfiles)         │
                │  ├── memory_compile.py / reflect.py     │
                │  ├── heartbeat.py                       │
                │  └── integrations/                      │
                │      ├── query.py (unified CLI)         │
                │      ├── github.py  gmail.py  jira_api  │
                │      └── lib/{sanitize,guardrails,...}  │
                └─────────────────────────────────────────┘
                            │
                            │ (Python holds API tokens; LLM never sees them)
                            ▼
                ┌─────────────────────────────────────────┐
                │      External APIs                      │
                │  GitHub  Gmail  Jira  Linear  Calendar  │
                └─────────────────────────────────────────┘

         ┌──────────────────┐               ┌──────────────────┐
         │  qmd search       │               │   launchd        │
         │  (vault index)    │               │  (scheduling)    │
         └──────────────────┘               └──────────────────┘
```

---

## Troubleshooting

**SessionStart hook silent / not injecting context**
- Run `echo '{}' | uv run ~/.dotfiles/.claude/hooks/memory_session_start.py` manually
- Check `~/.claude/settings.json` has the SessionStart entry
- Check hook script is executable: `ls -l ~/.claude/hooks/memory_session_start.py` (must have `x`)

**`/context` shows Memory files = 858 tokens (= only CLAUDE.md)**
- Hook output > 10 KB and harness evicted it to disk
- Check: `echo '{}' | uv run ~/.dotfiles/.claude/hooks/memory_session_start.py | wc -c`
- Trim AGENTS.md / USER.md in the hook output if needed

**`qmd query` slow on first call**
- Reranker model (~1.28 GB) downloads on first call. Subsequent calls are sub-second.

**Gmail OAuth fails with "Access blocked"**
- OAuth consent screen must be in "Testing" mode with your email added as a test user
- Don't need full Google verification for personal use

**Jira `assignee` JQL errors**
- Modern Atlassian Cloud requires `accountId`, not username
- Use `currentUser()` in JQL (already done in `jira_api.py`)

**`launchctl load` "already loaded"**
- `launchctl unload <plist>` then re-`load`

**Heartbeat notification never appears**
- System Settings → Notifications → "Script Editor" or the trigger app → Allow banners
- Notification queued but suppressed; check `/tmp/heartbeat-<mode>.log` for the actual output

**Integration module shadows a PyPI package (e.g., `jira.py`)**
- Pattern bit us during build: integration files in `~/.dotfiles/.claude/scripts/integrations/` end up on `sys.path` when query.py runs, shadowing top-level PyPI packages of the same name
- Workaround: rename the integration module (`jira.py` → `jira_api.py`)
- Currently affects: `jira_api.py` (could affect future `linear.py`, `slack.py`, etc.)

---

## Cost expectation

- Daily reflection: ~$0.01/day (one Haiku call against yesterday's session log)
- Compile (when run): ~$0.02–0.05 per session log
- Heartbeat per run: ~$0.005 (Sonnet, ~500 input + ~300 output tokens)
- 15 heartbeat runs/week × $0.005 = ~$0.08/week ≈ **$0.30/month**

Total monthly cost: well under $5 even with all features active. Already covered by your Claude Max subscription if you use Claude Code; otherwise pay-as-you-go API.

---

## What's intentionally NOT in this system (v1)

Per the [requirements decisions](/Users/kriscard/.claude/second-brain-prd/my-second-brain-requirements.md) made during the build:

- **Chat interface** (Slack/Discord bot) — deferred to v2
- **Email drafting / sending** — user doesn't reply to email much; surfacing only
- **Habits tracking** (`HABITS.md`) — duplicates the existing OKR + weekly review system
- **VPS deployment** — local-only
- **Auto-organizing inbox clippings** — already handled by user's Web Clipper templates with PARA routing

To add any of these later, follow the architecture reference at `~/.claude/skills/create-second-brain-prd/references/architecture-reference.md` and the integration_template.py pattern.
