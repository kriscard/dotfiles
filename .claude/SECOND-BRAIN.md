# Second Brain — Setup Guide

End-to-end instructions for reproducing this AI second brain on a new machine (work laptop, new personal machine, etc.). The system is local-first, vault-based, and built on Claude Code's memory + hook system.

Based on the [second-brain-starter](https://github.com/coleam00/second-brain-starter) architecture, adapted to Chris's existing Obsidian PARA vault. **This is the minimal blueprint variant** — vault as the memory layer, SessionStart hook as the delivery mechanism, qmd for semantic recall. No proactive monitoring layer, no platform integrations (those are handled by MCP plugins).

---

## What this system does

- **Remembers** across Claude Code sessions via vault-backed `SOUL.md` / `USER.md` / `MEMORY.md` + session capture
- **Searches** months of personal notes with hybrid keyword + vector + LLM-rerank (qmd)
- **Captures** every Claude Code conversation as a daily session log
- **Distills** session logs into PARA concept notes (`memory_compile.py`)
- **Reflects** durable facts into `MEMORY.md` daily (`memory_reflect.py`)
- **Catalogs** wiki content in `index.md` (vault root, per Karpathy LLM-wiki pattern)
- **Logs** operational events in `log.md` (vault root, append-only timeline)
- **Ingests** clipped sources into the catalog (`memory_ingest.py`, single file or `--inbox` batch)

---

## Prerequisites

| Tool                                     | Why                                 | Install                                        |
| ---------------------------------------- | ----------------------------------- | ---------------------------------------------- |
| macOS (Sequoia or newer)                 | dev environment                     | n/a                                            |
| Python 3.10+                             | scripts                             | `brew install python`                          |
| `uv`                                     | inline-script dep management        | `brew install uv`                              |
| GNU `stow`                               | dotfiles symlinking                 | `brew install stow`                            |
| Obsidian                                 | vault viewer + CLI                  | obsidian.md (enable CLI in Settings → General) |
| `qmd`                                    | hybrid vault search                 | `npm i -g @tobilu/qmd`                         |
| Node.js                                  | qmd runtime                         | `brew install node`                            |
| `fd`, `rg`, `ast-grep`, `zoxide`, `tree` | modern CLI defaults                 | `brew install fd ripgrep ast-grep zoxide tree` |
| `jq`                                     | JSON inspection (hook verification) | `brew install jq`                              |

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
ls -l ~/.claude/scripts/memory_*.py
```

Each should point at the `~/.dotfiles/.claude/...` source.

---

## 2. Vault setup

### 2a. Sync the Obsidian vault

If using **Obsidian Sync**: log in, restore vault to `~/obsidian-vault-<your-username>/`.

If using **git-backed vault**: clone it.

**Vault path resolution.** The hooks auto-detect the vault — no per-machine edit needed as long as the directory is named `obsidian-vault-*` under the current user's home. Resolution order in `~/.dotfiles/.claude/hooks/lib/memory_common.py:12`:

1. `$OBSIDIAN_VAULT` env var (if set — useful for non-standard locations)
2. Glob match `~/obsidian-vault-*`
3. Fallback: `~/obsidian-vault-kriscard`

Username is always derived from `Path.home()`, so different usernames on different machines work automatically.

**Other places that hardcode the vault directory name** (username already dynamic via `~/`, but the literal `obsidian-vault-kriscard` is baked in):

- `.config/nvim/lua/plugins/obsidian.lua` (3 lines)
- `.config/nvim/lua/kriscard/autocmds.lua:109`
- `.config/sesh/configs/personal.toml:10`

Keep your vault directory named `obsidian-vault-kriscard` on every machine and these all "just work." If you must rename, do a `rg -l obsidian-vault-kriscard ~/.dotfiles` and update the matches.

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
# Expected: SOUL.md, USER.md, MEMORY.md, AGENTS.md, index.md, log.md
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
jq '.hooks | {SessionStart, SessionEnd, PreCompact}' ~/.claude/settings.json
```

Each `command` field should point at `~/.dotfiles/.claude/hooks/memory_session_*.py`.

**Test the SessionStart payload size** — it must stay under ~10 KB or Claude Code evicts it to disk:

```bash
echo '{}' | uv run ~/.dotfiles/.claude/hooks/memory_session_start.py | wc -c
# Expected: under 10000. Current ~9.7 KB.
```

If over the threshold, trim USER.md / MEMORY.md (or shrink the MEMORY.md token cap in the hook).

**Verify in Claude Code:** open a session in the vault and ask Claude — without reading any file — what your role is, your training schedule, and a recent decision. If Claude answers correctly, the hook delivered the content. The `/context` "Memory files" row will only show `~/.claude/CLAUDE.md` — vault content arrives via Messages, not Memory files, which is the blueprint's design.

---

## 5. Auto-memory dir (optional)

> _Skip this step if you're keeping a pure blueprint setup. The dir is a Claude Code convention, not part of coleam00's pattern._

Claude Code uses `~/.claude/projects/<slug>/memory/` as a harness-guaranteed inline tier. If you want short-term typed memories visible in `/context` Memory files row, populate it. For strict blueprint compliance, leave it empty — the vault is the canonical layer.

---

## 6. Shell aliases (`zsh/zsh.d/70-functions.zsh`)

Already stowed by step 1. Source your shell to pick them up: `exec zsh`.

| Command | Effect |
|---|---|
| `mcompile-dry [--date YYYY-MM-DD]` | Compile preview — extract concepts from session log, route via qmd, save plan. No writes. |
| `mcompile [--date YYYY-MM-DD]` | Apply saved plan (or run + apply if no plan exists). Writes new concept notes + index.md + log.md. |
| `mcompile --skip-backlinks` | Apply only new-notes + appends (drop moc-backlink actions when qmd matches look noisy). |
| `mingest-dry [--inbox] [--entities] [--force]` | Ingest preview — show which clippings would land in index.md, optionally with entity-page fanout. |
| `mingest [--inbox] [--entities] [--force]` | Apply ingest. With `--entities` it walks summary wikilinks and creates concept stubs + appends citations. |

All run from anywhere — vault path auto-resolves via `~/obsidian-vault-*` glob.

---

## 7. Image download (Karpathy tip — clipped images live in vault)

Two GUI changes in Obsidian (~30 seconds total). Worth doing if you clip image-heavy articles — without this, clipped images stay as remote URLs that may break.

### 7a. Set the attachment folder

Obsidian → Settings → **Files and links** → **Attachment folder path** → enter:

```
3 - Resources/assets
```

(Or another path of your choice. This is where downloaded attachments will land.)

### 7b. Bind a hotkey to "Download attachments for current file"

Obsidian → Settings → **Hotkeys** → search for **"Download attachments"** → bind it.

Suggested: **⌃⇧D** (Control + Shift + D).

### Workflow

1. Web Clipper saves a clipped article to `3 - Resources/Articles/<title>.md`
2. The clip's body has remote image URLs (e.g., `![alt](https://cdn...)`)
3. Open the clipped note in Obsidian, hit ⌃⇧D
4. All images download to `3 - Resources/assets/` and the note's image links update to local paths
5. Images now survive forever even if the original URL breaks

---

## 8. End-to-end verification checklist

After everything is set up:

| Check                   | Command                                                                                                                                   | Expected                                                                            |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Hook size               | `echo '{}' \| uv run ~/.dotfiles/.claude/hooks/memory_session_start.py \| wc -c`                                                          | < 10000                                                                             |
| Hook delivers sections  | `echo '{}' \| uv run ~/.dotfiles/.claude/hooks/memory_session_start.py \| jq -r '.hookSpecificOutput.additionalContext' \| grep "^# ==="` | 5 lines (SOUL, USER, MEMORY, MOC, Vault rules)                                      |
| qmd indexed             | `qmd ls`                                                                                                                                  | shows vault collection                                                              |
| qmd recall works        | `qmd query "PARA" --json -n 2`                                                                                                            | returns notes                                                                       |
| /context in Claude Code | open session in vault, run `/context`                                                                                                     | Memory files = 858 tokens (CLAUDE.md only); Messages includes the ~2 K hook payload |
| Direct recall           | ask Claude "without reading any file, what's my role?"                                                                                    | answers correctly from USER.md                                                      |

---

## Architecture overview

```
                ┌─────────────────────────────────────────┐
                │            Obsidian Vault               │
                │  SOUL.md  USER.md  MEMORY.md  AGENTS.md │
                │  Claude Sessions/  3 - Resources/       │
                │  MOCs/Claude Memory MOC                 │
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
                │  ├── memory_session_start.py            │
                │  ├── memory_session_end.py              │
                │  ├── memory_pre_compact.py              │
                │  ├── memory_reflect.py                  │
                │  ├── memory_compile.py                  │
                │  └── memory_lint.py                     │
                └─────────────────────────────────────────┘

         ┌──────────────────┐
         │   qmd search     │
         │  (vault index)   │
         └──────────────────┘
```

---

## Troubleshooting

**SessionStart hook silent / not injecting context**

- Run `echo '{}' | uv run ~/.dotfiles/.claude/hooks/memory_session_start.py` manually
- Check `~/.claude/settings.json` has the SessionStart entry
- Check hook script is executable: `ls -l ~/.claude/hooks/memory_session_start.py` (must have `x`)

**Hook payload too big (evicted to disk)**

- Run: `echo '{}' | uv run ~/.dotfiles/.claude/hooks/memory_session_start.py | wc -c`
- Must be under ~10 KB. If over, trim USER.md or MEMORY.md (or shrink the MEMORY.md token cap in the hook).

**`qmd query` slow on first call**

- Reranker model (~1.28 GB) downloads on first call. Subsequent calls are sub-second.

**Daily reflection not firing**

- `memory_session_start.py` kicks it off via subprocess on the first session of the day (atomic claim via `fcntl.flock` so multiple tmux panes don't race).
- Check `~/.claude/state/memory-reflection-processed.json` — entries with today's date mean reflection already ran.
- Force re-run for a specific date: `uv run ~/.dotfiles/.claude/scripts/memory_reflect.py --date YYYY-MM-DD --force`

**MOC empty after `memory_compile.py`**

- Compile uses LLM extraction + qmd matching. If qmd matches at 0.55+ to a human note, the concept gets a backlink-only entry. Many false positives at 0.88-0.92 — tune `QMD_MATCH_THRESHOLD` in `memory_compile.py` if you want stricter routing.
- Plans are persisted at `~/.claude/state/memory-compile-plans/<date>.json` after a dry-run, so `--apply` consumes the same plan.

**`MEMORY.md.archive` has duplicate `## YYYY-MM-DD Reflection` sections**

- Run once: `uv run ~/.dotfiles/.claude/scripts/memory_reflect.py --dedup-archive`. Keeps the last occurrence per date.

---

## Cost expectation

- Daily reflection: ~$0.01/day (one Haiku call against yesterday's session log)
- Compile (manual): ~$0.02–0.05 per session log
- **Total monthly cost: well under $1** if you only use reflection + compile, covered by Claude Max if you use Claude Code.

---

## What's intentionally NOT in this system

This setup is the minimal blueprint variant. Out of scope:

- **Proactive heartbeat monitoring** — no scheduled "morning brief" pulling from GitHub / Gmail / Jira. The system reacts to your sessions; it doesn't push updates.
- **Platform integrations** (Gmail / Calendar / Linear / Jira CLI wrappers) — no scripted querying of external APIs. Use MCP plugins for those (the `obsidian-second-brain` plugin handles vault ops; the Linear plugin handles Linear queries).
- **Chat interface** (Slack / Discord bot) — Claude Code only.
- **Habits tracking** (`HABITS.md` with pillars) — duplicates the existing OKR + weekly review system in the vault.
- **VPS deployment** — local only.
- **Auto-organizing inbox clippings** — handled by the Web Clipper templates with PARA routing.

If you want to add any of these later, the architecture reference at `~/.claude/skills/create-second-brain-prd/references/architecture-reference.md` is the canonical blueprint for how to wire them in.
