# Personal Settings (Max Subscription)

This document explains the home/personal Claude Code settings. For work/API settings, see `work-settings.md`.

---

## Design Philosophy

Home environment uses Max subscription (unlimited). Settings optimize for **capability over cost**:

- Most powerful model (Opus)
- Extended thinking always on
- Full plugin ecosystem
- Complete hook pipeline (notifications, linting, status)
- Learning output style for educational responses

---

## Full Configuration

Place in `~/.claude/settings.json` or use `ch` / `claude-work` (defaults to home profile):

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "ENABLE_TOOL_SEARCH": "auto"
  },
  "attribution": {
    "commit": "",
    "pr": ""
  },
  "permissions": {
    "allow": [
      "Bash(agent-browser back)",
      "Bash(agent-browser click *)",
      "Bash(agent-browser close)",
      "Bash(agent-browser console)",
      "Bash(agent-browser console *)",
      "Bash(agent-browser diff *)",
      "Bash(agent-browser errors)",
      "Bash(agent-browser errors *)",
      "Bash(agent-browser fill *)",
      "Bash(agent-browser find *)",
      "Bash(agent-browser forward)",
      "Bash(agent-browser get *)",
      "Bash(agent-browser hover *)",
      "Bash(agent-browser is *)",
      "Bash(agent-browser network har *)",
      "Bash(agent-browser network requests)",
      "Bash(agent-browser network requests *)",
      "Bash(agent-browser open *)",
      "Bash(agent-browser pdf *)",
      "Bash(agent-browser press *)",
      "Bash(agent-browser reload)",
      "Bash(agent-browser screenshot)",
      "Bash(agent-browser screenshot *)",
      "Bash(agent-browser scroll *)",
      "Bash(agent-browser select *)",
      "Bash(agent-browser snapshot)",
      "Bash(agent-browser snapshot *)",
      "Bash(agent-browser type *)",
      "Bash(agent-browser wait)",
      "Bash(agent-browser wait *)",
      "Bash(docker compose exec *)",
      "Bash(docker run *)",
      "Bash(gh pr view *)",
      "Bash(gh run view *)",
      "Bash(git add *)",
      "Bash(git blame *)",
      "Bash(git diff)",
      "Bash(git diff *)",
      "Bash(git fetch)",
      "Bash(git fetch *)",
      "Bash(git log)",
      "Bash(git log *)",
      "Bash(git ls-files *)",
      "Bash(git show)",
      "Bash(git show *)",
      "Bash(git status)",
      "Bash(git status *)",
      "Bash(mkdir *)",
      "Bash(node *)",
      "Bash(npm run build *)",
      "Bash(obsidian)",
      "Bash(obsidian *)",
      "Bash(qmd --help)",
      "Bash(qmd bench *)",
      "Bash(qmd get *)",
      "Bash(qmd ls)",
      "Bash(qmd ls *)",
      "Bash(qmd multi-get *)",
      "Bash(qmd query *)",
      "Bash(qmd search *)",
      "Bash(qmd skill show*)",
      "Bash(qmd status)",
      "Bash(qmd vsearch *)",
      "ExitPlanMode(*)",
      "Fetch(*)",
      "Glob(*)",
      "Grep(*)",
      "LS(*)",
      "Read(*)",
      "Task(*)",
      "TodoWrite(*)",
      "WebFetch(domain:*)",
      "WebSearch",
      "mcp__*"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./config/credentials.json)",
      "Read(./build)",
      "Edit(./.env)",
      "Edit(./.env.*)",
      "Edit(./package-lock.json)",
      "Edit(./yarn.lock)",
      "Edit(./pnpm-lock.yaml)",
      "Bash( /dev/sda)",
      "Bash(> /dev/sda)",
      "Bash(dd if=/dev/zero of=/dev/sda)",
      "Bash(diskutil apfs changePassphrase)",
      "Bash(diskutil apfs decryptVolume)",
      "Bash(diskutil apfs deleteContainer)",
      "Bash(diskutil apfs deleteSnapshot)",
      "Bash(diskutil apfs deleteVolume)",
      "Bash(diskutil apfs deleteVolumeGroup)",
      "Bash(diskutil apfs eraseVolume)",
      "Bash(diskutil appleRAID)",
      "Bash(diskutil coreStorage)",
      "Bash(diskutil cs)",
      "Bash(diskutil disableJournal)",
      "Bash(diskutil disableOwnership)",
      "Bash(diskutil eraseDisk)",
      "Bash(diskutil eraseVolume)",
      "Bash(diskutil partitionDisk)",
      "Bash(diskutil randomDisk)",
      "Bash(diskutil reformat)",
      "Bash(diskutil resetFusion)",
      "Bash(diskutil zeroDisk)",
      "Bash(fork bomb)",
      "Bash(git branch -D *)",
      "Bash(git clean -df *)",
      "Bash(git clean -f *)",
      "Bash(git clean -fd *)",
      "Bash(git filter-branch *)",
      "Bash(git push --force)",
      "Bash(git push --force *)",
      "Bash(git push -f)",
      "Bash(git push -f *)",
      "Bash(git rebase)",
      "Bash(git rebase *)",
      "Bash(git reflog expire *)",
      "Bash(git reset --hard)",
      "Bash(git reset --hard *)",
      "Bash(git rm *)",
      "Bash(mkfs.ext4 /dev/sda)",
      "Bash(obsidian dev:cdp *)",
      "Bash(obsidian dev:debug *)",
      "Bash(obsidian dev:eval *)",
      "Bash(obsidian devtools)",
      "Bash(obsidian devtools *)",
      "Bash(obsidian eval *)",
      "Bash(rm -rf $HOME)",
      "Bash(rm -rf $PAI_DIR)",
      "Bash(rm -rf $PAI_HOME)",
      "Bash(rm -rf $DOTFILES)",
      "Bash(rm -rf /)",
      "Bash(rm -rf /*)",
      "Bash(rm -rf ~)",
      "Bash(sudo rm -rf /)",
      "Bash(sudo rm -rf /*)"
    ],
    "ask": [
      "Bash(agent-browser auth delete *)",
      "Bash(agent-browser auth login *)",
      "Bash(agent-browser auth save *)",
      "Bash(agent-browser clipboard copy *)",
      "Bash(agent-browser clipboard write *)",
      "Bash(agent-browser connect *)",
      "Bash(agent-browser cookies clear)",
      "Bash(agent-browser cookies clear *)",
      "Bash(agent-browser cookies set *)",
      "Bash(agent-browser download *)",
      "Bash(agent-browser eval *)",
      "Bash(agent-browser network route *)",
      "Bash(agent-browser network unroute *)",
      "Bash(agent-browser set credentials *)",
      "Bash(agent-browser storage *)",
      "Bash(agent-browser upload *)",
      "Bash(git branch *)",
      "Bash(git checkout *)",
      "Bash(git cherry-pick *)",
      "Bash(git commit)",
      "Bash(git commit *)",
      "Bash(git merge *)",
      "Bash(git pull)",
      "Bash(git pull *)",
      "Bash(git push)",
      "Bash(git push *)",
      "Bash(git restore *)",
      "Bash(git revert *)",
      "Bash(git stash *)",
      "Bash(git switch *)",
      "Bash(git tag *)",
      "Bash(obsidian append *)",
      "Bash(obsidian base:create *)",
      "Bash(obsidian bookmark *)",
      "Bash(obsidian create *)",
      "Bash(obsidian daily:append *)",
      "Bash(obsidian daily:prepend *)",
      "Bash(obsidian delete)",
      "Bash(obsidian delete *)",
      "Bash(obsidian history:restore *)",
      "Bash(obsidian move *)",
      "Bash(obsidian patch *)",
      "Bash(obsidian plugin:disable *)",
      "Bash(obsidian plugin:enable *)",
      "Bash(obsidian plugin:install *)",
      "Bash(obsidian plugin:reload *)",
      "Bash(obsidian plugin:uninstall *)",
      "Bash(obsidian plugins:restrict)",
      "Bash(obsidian plugins:restrict *)",
      "Bash(obsidian prepend *)",
      "Bash(obsidian property:remove *)",
      "Bash(obsidian property:set *)",
      "Bash(obsidian reload)",
      "Bash(obsidian rename *)",
      "Bash(obsidian restart)",
      "Bash(obsidian snippet:disable *)",
      "Bash(obsidian snippet:enable *)",
      "Bash(obsidian sync)",
      "Bash(obsidian sync *)",
      "Bash(obsidian sync:restore *)",
      "Bash(obsidian task *)",
      "Bash(obsidian template:insert *)",
      "Bash(obsidian theme:install *)",
      "Bash(obsidian theme:set *)",
      "Bash(obsidian theme:uninstall *)",
      "mcp__browsermcp__*"
    ]
  },
  "model": "opus[1m]",
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": ["context7", "browsermcp"],
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.dotfiles/bin/claude-status-hook PreToolUse"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "uv run ~/.dotfiles/.claude/hooks/notification.py"
          },
          {
            "type": "command",
            "command": "~/.dotfiles/bin/claude-status-hook Stop"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.dotfiles/bin/claude-status-hook SubagentStop"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "uv run ~/.dotfiles/.claude/hooks/notification.py"
          },
          {
            "type": "command",
            "command": "~/.dotfiles/bin/claude-status-hook Notification"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "uv run ~/.dotfiles/.claude/hooks/ts_lint.py"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "uv run ~/.dotfiles/.claude/hooks/memory_session_start.py"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "uv run ~/.dotfiles/.claude/hooks/memory_session_end.py",
            "timeout": 10
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "uv run ~/.dotfiles/.claude/hooks/memory_pre_compact.py",
            "timeout": 10
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "~/.dotfiles/bin/claude-statusline"
  },
  "enabledPlugins": {
    "feature-dev@claude-plugins-official": true,
    "agent-sdk-dev@claude-plugins-official": true,
    "learning-output-style@claude-plugins-official": true,
    "plugin-dev@claude-plugins-official": true,
    "linear@claude-plugins-official": true,
    "obsidian@obsidian-skills": true,
    "skill-creator@claude-plugins-official": true,
    "lua-lsp@claude-plugins-official": true,
    "claude-md-management@claude-plugins-official": true,
    "essentials@kriscard": true,
    "developer-tools@kriscard": true,
    "testing@kriscard": true,
    "assistant@kriscard": true,
    "til@kriscard": true,
    "architecture@kriscard": true,
    "obsidian-second-brain@kriscard": true,
    "ideation@kriscard": true,
    "content@kriscard": true,
    "ai-development@kriscard": true,
    "neovim-advisor@kriscard": true,
    "dotfiles-optimizer@kriscard": true,
    "studio-startup@kriscard": true,
    "interactive-learning@kriscard": true
  },
  "extraKnownMarketplaces": {
    "claude-plugins-official": {
      "source": {
        "source": "github",
        "repo": "anthropics/claude-plugins-official"
      }
    },
    "better-auth-agent-skills": {
      "source": {
        "source": "git",
        "url": "https://github.com/better-auth/skills.git"
      }
    },
    "kriscard": {
      "source": {
        "source": "github",
        "repo": "kriscard/kriscard-claude-plugins"
      }
    }
  },
  "alwaysThinkingEnabled": true,
  "editorMode": "vim",
  "teammateMode": "tmux",
  "voiceEnabled": true
}
```

---

## Settings Breakdown

### Environment Variables

| Variable                               | Value    | Purpose                                                       |
| -------------------------------------- | -------- | ------------------------------------------------------------- |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `"1"`    | Enables multi-agent team coordination (experimental)          |
| `ENABLE_TOOL_SEARCH`                   | `"auto"` | Defers MCP tool loading until needed (~47% context reduction) |

### Attribution

```json
"attribution": { "commit": "", "pr": "" }
```

Enforces the safety rule: **no AI attribution** in commits or PRs. Empty strings suppress any auto-generated attribution lines.

### Model & Thinking

- **Model**: `opus[1m]` - Most capable reasoning model with 1M context (5x cost vs Sonnet, but unlimited on Max)
- **Voice**: Enabled — hold-to-talk dictation
- **Extended thinking**: Always on - Better reasoning, deeper analysis, fewer errors

---

## Permission System

### Allow Rules

Broad auto-approve for common dev operations. Notable:

- All read-only tools (`Glob`, `Grep`, `LS`, `Read`) - no friction for exploration
- Docker exec/run, Node, npm build
- All MCP tools (`mcp__*`) auto-approved except browsermcp (see Ask rules)

### Deny Rules (Hardened)

Two categories of deny rules:

**Data protection** (shared with work):

- `.env`, `.env.*`, `secrets/**`, `credentials.json` - prevents credential leaks
- Lock files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`) - prevents accidental corruption

**Destructive command blocklist** (home only):

- Disk operations (`diskutil erase/partition/reformat`, `dd`, `mkfs`)
- Recursive deletions (`rm -rf /`, `rm -rf ~`, `rm -rf $HOME`, `rm -rf $DOTFILES`)
- Fork bombs

This extended deny list exists because home sessions run with `opus` + extended thinking, which is more autonomous. The extra guardrails prevent catastrophic mistakes during long autonomous sessions.

### Ask Rules

```json
"ask": ["Bash(git *)", "mcp__browsermcp__*"]
```

- **All git operations** require explicit approval — commit, push, add, rebase, etc.
- **Browser automation** requires confirmation — prevents unexpected browser interactions during autonomous work.

---

## Hook Pipeline

8 hook events, each with specific purpose:

| Event            | Matcher                        | Hook(s)                                  | Purpose                                                                                                            |
| ---------------- | ------------------------------ | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **PreToolUse**   | `Bash\|Write\|Edit\|MultiEdit` | `claude-status-hook`                     | Track status for write operations only                                                                             |
| **Stop**         | all                            | `notification.py` + `claude-status-hook` | Desktop notification + status update on completion                                                                 |
| **SubagentStop** | all                            | `claude-status-hook`                     | Track when subagents finish                                                                                        |
| **Notification** | all                            | `notification.py` + `claude-status-hook` | System notifications + status                                                                                      |
| **PostToolUse**  | `Write\|Edit\|MultiEdit`       | `ts_lint.py`                             | Auto-lint TypeScript after edits                                                                                   |
| **SessionStart** | all                            | `memory_session_start.py`                | Inject vault memory (AGENTS/SOUL/USER/MEMORY/MOC stub) into context, kick daily reflection if first session of day |
| **SessionEnd**   | all                            | `memory_session_end.py`                  | Summarize transcript via Claude Agent SDK → append to vault session log + patch daily-note wikilink                |
| **PreCompact**   | all                            | `memory_session_end.py`                  | Same handler — captures context before auto-compaction wipes it                                                    |

### What's Different from Work

| Feature                         | Home                 | Work       | Why                       |
| ------------------------------- | -------------------- | ---------- | ------------------------- |
| PreToolUse matcher              | Yes (write ops only) | Yes (same) | Reduces hook overhead     |
| Stop notification               | `notification.py`    | Removed    | Python overhead per-stop  |
| SubagentStop                    | Enabled              | Removed    | Not needed at work        |
| Notification hook               | Enabled              | Removed    | Extra overhead            |
| PostToolUse linting             | Enabled              | Removed    | Node process per-edit     |
| SessionStart memory injection   | Enabled              | Removed    | Personal vault, home only |
| SessionEnd / PreCompact capture | Enabled              | Removed    | Personal vault, home only |

---

## Plugin Ecosystem (22 plugins)

### Official Plugins (8)

| Plugin                  | Purpose                             |
| ----------------------- | ----------------------------------- |
| `feature-dev`           | Guided feature development workflow |
| `agent-sdk-dev`         | Claude Agent SDK app creation       |
| `learning-output-style` | Educational response mode           |
| `plugin-dev`            | Plugin creation and validation      |
| `linear`                | Linear issue tracker integration    |
| `skill-creator`         | Skill creation and optimization     |
| `claude-md-management`  | CLAUDE.md audit and improvement     |
| `lua-lsp`               | Lua/Neovim LSP support              |

### Community Plugins (13 @kriscard)

| Plugin                  | Category  | Purpose                                               |
| ----------------------- | --------- | ----------------------------------------------------- |
| `essentials`            | Core      | Git commits, PRs, specs, search, deep thinking        |
| `developer-tools`       | Dev       | Code review, debugging, TypeScript, frontend, Next.js |
| `testing`               | QA        | Unit, integration, E2E, automation testing            |
| `assistant`             | Workflow  | Standup, weekly summary, context management, career   |
| `til`                   | Learning  | Today I Learned note creation                         |
| `architecture`          | Design    | Repo analysis, sprint planning, arch docs, ADRs       |
| `obsidian-second-brain` | PKM       | Vault management, PARA, OKRs, templates               |
| `ideation`              | Planning  | Brain dump to structured specs workflow               |
| `content`               | Writing   | Blog posts, conference talks, technical docs          |
| `ai-development`        | AI/ML     | Prompt engineering, RAG, agent orchestration          |
| `neovim-advisor`        | Editor    | Plugin recommendations, LSP config, performance       |
| `dotfiles-optimizer`    | Config    | Shell config optimization, audit                      |
| `studio-startup`        | Projects  | New project/MVP guided workflow                       |
| `interactive-learning`  | Education | Interactive learning sessions                         |
| `browser`               | Browser   | Page inspection, screenshots, automation              |

### Third-Party (1)

| Plugin                     | Purpose                               |
| -------------------------- | ------------------------------------- |
| `obsidian@obsidian-skills` | Obsidian markdown, bases, JSON canvas |

---

## MCP Server Configuration

### Enabled Servers (2)

| Server         | Purpose               | When Used                                             |
| -------------- | --------------------- | ----------------------------------------------------- |
| **context7**   | Library documentation | Up-to-date framework/library docs                     |
| **browsermcp** | Browser automation    | Interactive web testing (requires `ask` confirmation) |

### CLI Over MCP

Prefer built-in tools and CLI over MCP where possible:

- **GitHub**: `gh` CLI commands
- **Web content**: `WebFetch` / `WebSearch` built-ins
- **Obsidian**: `obsidian` CLI first, MCP as fallback
- **Browser**: Only MCP when interaction needed (clicking, forms)

---

## Memory System (vault-backed second brain)

Auto-captures every Claude Code session into the Obsidian vault, compiles distilled knowledge into PARA notes, and re-injects vault context at SessionStart. Inspired by Karpathy's LLM-knowledge-base gist + coleam00's claude-memory-compiler. PARA-native (no parallel `Knowledge/` taxonomy) and plugin-aware (coexists with `obsidian-second-brain` without modifying it).

### Files in this dotfiles dir

```
.claude/
├── hooks/
│   ├── lib/memory_common.py         # vault paths, write-guard, atomic-claim helper for tmux concurrency
│   ├── memory_session_start.py      # SessionStart: inject AGENTS+SOUL+USER+MEMORY+MOC stub
│   └── memory_session_end.py        # SessionEnd + PreCompact: SDK-summarize transcript → session log + wikilink
└── scripts/
    ├── memory_compile.py            # concept extraction + qmd query + permission-gated writes
    ├── memory_reflect.py            # daily curation: yesterday's session log → vault MEMORY.md
    └── memory_lint.py               # read-only health check (broken links, orphans, MOC drift)
```

All Python scripts use `uv run` with PEP 723 inline-script deps (`claude-agent-sdk`). No requirements.txt or venv to manage.

### Files in the vault (created in Phase 1, not in this repo)

| Path                                                  | Purpose                                               |
| ----------------------------------------------------- | ----------------------------------------------------- |
| `<vault>/AGENTS.md`                                   | Schema / operational rules (Karpathy convention)      |
| `<vault>/SOUL.md`                                     | Short persona for vault-aware operation               |
| `<vault>/USER.md`                                     | Stable user profile                                   |
| `<vault>/MEMORY.md`                                   | Curated long-term facts (managed by daily reflection) |
| `<vault>/MOCs/Claude Memory MOC.md`                   | Agent-readable index of compiled notes                |
| `<vault>/2 - Areas/Daily Ops/<year>/Claude Sessions/` | Per-day session capture directory                     |

The vault path is hardcoded in `hooks/lib/memory_common.py:9`. To port to a different machine with a different vault location, edit that one line.

### External dependencies (install on each machine)

| Tool           | Install command                             | Purpose                                  |
| -------------- | ------------------------------------------- | ---------------------------------------- |
| `uv`           | `brew install uv`                           | Runs Python scripts with inline deps     |
| `qmd`          | `npm install -g @tobilu/qmd`                | Hybrid BM25 + vector + LLM-rerank search |
| `obsidian` CLI | Settings → General → Command line interface | File ops on the vault                    |
| GNU stow       | `brew install stow`                         | Symlink dotfiles into `~/.claude/`       |

After installing `qmd`:

```bash
qmd collection add <vault-path> --name vault
qmd context add qmd://vault "<short context line for the agent>"
qmd embed                                # one-time, ~2-3 min
```

`claude-agent-sdk` installs lazily when uv first runs the SessionEnd / compile / reflect scripts — no manual install needed.

### Hook behavior at a glance

- **SessionStart** — emits ~2300 tokens of vault context (AGENTS + SOUL + USER + MEMORY + MOC stub) via `hookSpecificOutput.additionalContext`. Bounded forever regardless of vault growth (MOC is stub-loaded; MEMORY.md is capped + auto-archived). Also kicks `memory_reflect.py` in the background if first session of day (atomic claim across tmux panes).
- **SessionEnd / PreCompact** — receives transcript JSON via stdin, spawns Haiku 4.5 via `claude-agent-sdk` to summarize, appends `## HH:MM — <project>` section to today's session log, and patches today's daily note in-place under `## 💬 Sessions` with a wikilink. Uses `fcntl.flock` for safe concurrent writes from parallel tmux sessions.

### Safety model

The compile script writes ONLY to the auto-write set without permission:

- `Claude Sessions/*.md` (raw captures)
- `MEMORY.md` + archive
- `MOCs/Claude Memory MOC.md` + archive
- `## 💬 Sessions` line in today's daily note

Everything else — new concept notes in `3 - Resources/<subfolder>/`, edits to existing notes, deletions — requires explicit user approval. `compile.py` defaults to `--dry-run`; `--apply` requires interactive confirmation; `--apply --yes` skips the prompt for scripted runs.

### Recall mechanism

The `memory-recall` skill in the `obsidian-second-brain` plugin fires on natural-language patterns ("what did I learn about", "remember when we", "did I decide", "what's my note on") and runs:

```
qmd query "<topic>" --json -n 8       → semantic+hybrid+rerank match
obsidian search:context query="..."    → keyword fallback
```

No `/recall` slash command — recall lives as a skill in the plugin marketplace.

### Token budget (bounded by design)

| Source                 | Frequency                       | Cost cap                                         |
| ---------------------- | ------------------------------- | ------------------------------------------------ |
| SessionStart injection | every session                   | ~2300 tokens (AGENTS+SOUL+USER+MEMORY+MOC stub)  |
| SessionEnd Agent SDK   | every session-end (if ≥5 turns) | bounded — Haiku 4.5, last 50 turns, ~2KB/msg cap |
| MOC full read          | on-demand only                  | ~3000 tokens cap (auto-rolls older entries)      |
| MEMORY.md              | every session                   | ~1000 tokens cap (auto-archives oldest)          |
| Daily reflection       | once per active day             | bounded by yesterday's session log               |
| Compile / lint         | manual                          | bounded by today's session log                   |

Net effect: per-session overhead is bounded regardless of how big memory grows over years.

### Reusable from the existing setup

Memory hooks follow the conventions of the existing `notification.py` and `ts_lint.py` hooks: `uv run` shebang for the SDK-using ones, stdin-JSON parsing, stderr for logs. The compile script shells out to the `obsidian` CLI (already on PATH via the `obsidian-second-brain` plugin's `obsidian` skill).

---

## Quick Reference

```
Model: opus[1m] (1M context)
Thinking: always on
Voice: enabled
Plugins: 22 (8 official + 13 @kriscard + 1 third-party)
MCP servers: 2 (context7, browsermcp)
Hooks: full pipeline (status, notifications, linting, memory capture)
Memory system: enabled (SessionStart injection + SessionEnd/PreCompact capture + daily reflection + compile/lint scripts)
External tooling: uv, qmd (npm), obsidian CLI, stow
Style: learning (educational responses)
Teams: enabled (experimental)
Tool search: auto (deferred loading)
Attribution: suppressed (empty strings)
Git ops: ask (all git commands require approval)
Status line: enabled
```

---

## Side-by-Side Comparison with Work

| Setting       | Home (Max)                          | Work (API)             |
| ------------- | ----------------------------------- | ---------------------- |
| Model         | `opus[1m]`                          | `sonnet`               |
| Thinking      | Always on                           | Off (per-task)         |
| Plugins       | 22                                  | 7                      |
| MCP servers   | 3                                   | project-only           |
| Hooks         | 8 events (full pipeline + memory)   | 2 events (status only) |
| Memory system | Enabled (vault-backed second brain) | Disabled               |
| Output style  | Learning                            | Default                |
| Agent teams   | Enabled                             | Not set                |
| Deny rules    | Extended (disk + rm)                | Basic (env + locks)    |
| Ask rules     | git + browsermcp                    | git + browsermcp       |
| Attribution   | Suppressed                          | Not set                |
| Cost concern  | None (unlimited)                    | Per-token              |
