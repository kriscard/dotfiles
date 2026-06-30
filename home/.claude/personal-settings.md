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
  "alwaysThinkingEnabled": true,
  "attribution": {
    "commit": "",
    "pr": ""
  },
  "editorMode": "vim",
  "effortLevel": "high",
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": ["context7", "browsermcp"],
  "enabledPlugins": {
    "agent-sdk-dev@claude-plugins-official": true,
    "claude-code-setup@claude-plugins-official": true,
    "claude-md-management@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true,
    "learning-output-style@claude-plugins-official": true,
    "linear@claude-plugins-official": true,
    "lua-lsp@claude-plugins-official": true,
    "obsidian@obsidian-skills": true,
    "plannotator@plannotator": true,
    "plugin-dev@claude-plugins-official": true,
    "skill-creator@claude-plugins-official": true
  },
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "ENABLE_TOOL_SEARCH": "auto"
  },
  "extraKnownMarketplaces": {
    "better-auth-agent-skills": {
      "source": {
        "source": "git",
        "url": "https://github.com/better-auth/skills.git"
      }
    },
    "claude-plugins-official": {
      "source": {
        "repo": "anthropics/claude-plugins-official",
        "source": "github"
      }
    },
    "plannotator": {
      "source": {
        "source": "github",
        "repo": "backnotprop/plannotator"
      }
    }
  },
  "fileCheckpointingEnabled": true,
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "command": "uv run ~/.dotfiles/.claude/hooks/notification.py",
            "type": "command"
          },
          {
            "command": "~/.dotfiles/bin/claude-status-hook Notification",
            "type": "command"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "command": "uv run ~/.dotfiles/.claude/hooks/format.py",
            "type": "command"
          },
          {
            "command": "uv run ~/.dotfiles/.claude/hooks/ts_lint.py",
            "type": "command"
          }
        ],
        "matcher": "Write|Edit|MultiEdit"
      }
    ],
    "PreToolUse": [
      {
        "hooks": [
          {
            "command": "~/.dotfiles/bin/claude-status-hook PreToolUse",
            "type": "command"
          }
        ],
        "matcher": "Bash|Write|Edit|MultiEdit"
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "command": "bash '/Users/kriscard/.claude/hooks/herdr-agent-state.sh' session",
            "timeout": 10,
            "type": "command"
          }
        ],
        "matcher": "*"
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "command": "uv run ~/.dotfiles/.claude/hooks/notification.py",
            "type": "command"
          },
          {
            "command": "~/.dotfiles/bin/claude-status-hook Stop",
            "type": "command"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "command": "~/.dotfiles/bin/claude-status-hook SubagentStop",
            "type": "command"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "command": "python3 ~/.dotfiles/.claude/hooks/vault_recall.py",
            "statusMessage": "Checking vault...",
            "timeout": 8,
            "type": "command"
          }
        ]
      }
    ]
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
      "Bash(gh pr list *)",
      "Bash(gh pr checks *)",
      "Bash(gh pr diff *)",
      "Bash(gh run view *)",
      "Bash(gh run list *)",
      "Bash(gh issue view *)",
      "Bash(gh issue list *)",
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
      "Bash(fd *)",
      "Bash(tree *)",
      "Bash(sg *)",
      "Bash(ast-grep *)",
      "Bash(nvim --headless *)",
      "Bash(luajit *)",
      "Bash(lua -e *)",
      "Bash(ls:*)",
      "Bash(dotfiles doctor *)",
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
      "mcp__context7__*"
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
      "mcp__browsermcp__*",
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
    ]
  },
  "skipAutoPermissionPrompt": true,
  "statusLine": {
    "command": "~/.dotfiles/bin/claude-statusline",
    "type": "command"
  },
  "teammateMode": "tmux",
  "tui": "fullscreen",
  "voiceEnabled": true,
  "worktree": {
    "symlinkDirectories": ["node_modules"]
  }
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
- Search/dev CLIs (`fd`, `tree`, `sg`/`ast-grep`) - preferred tools from CLAUDE.md, no per-run prompt
- Neovim config verification (`nvim --headless`, `luajit`, `lua -e`) - syntax/health checks during nvim work
- `dotfiles doctor` - repo health check (note: `stow`/`dotfiles sync` deliberately left to prompt, they mutate symlinks)
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

5 hook events, each with specific purpose:

| Event            | Matcher                        | Hook(s)                                  | Purpose                                            |
| ---------------- | ------------------------------ | ---------------------------------------- | -------------------------------------------------- |
| **PreToolUse**   | `Bash\|Write\|Edit\|MultiEdit` | `claude-status-hook`                     | Track status for write operations only             |
| **Stop**         | all                            | `notification.py` + `claude-status-hook` | Desktop notification + status update on completion |
| **SubagentStop** | all                            | `claude-status-hook`                     | Track when subagents finish                        |
| **Notification** | all                            | `notification.py` + `claude-status-hook` | System notifications + status                      |
| **PostToolUse**  | `Write\|Edit\|MultiEdit`       | `ts_lint.py`                             | Auto-lint TypeScript after edits                   |

### What's Different from Work

| Feature             | Home                 | Work       | Why                      |
| ------------------- | -------------------- | ---------- | ------------------------ |
| PreToolUse matcher  | Yes (write ops only) | Yes (same) | Reduces hook overhead    |
| Stop notification   | `notification.py`    | Removed    | Python overhead per-stop |
| SubagentStop        | Enabled              | Removed    | Not needed at work       |
| Notification hook   | Enabled              | Removed    | Extra overhead           |
| PostToolUse linting | Enabled              | Removed    | Node process per-edit    |

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

### Third-Party (2)

| Plugin                     | Purpose                               |
| -------------------------- | ------------------------------------- |
| `obsidian@obsidian-skills` | Obsidian markdown, bases, JSON canvas |
| `plannotator@plannotator`  | Plan review, annotation, and chat UI  |

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

## Quick Reference

```
Model: opus[1m] (1M context)
Thinking: always on
Voice: enabled
Plugins: 23 (8 official + 13 @kriscard + 2 third-party)
MCP servers: 2 (context7, browsermcp)
Hooks: full pipeline (status, notifications, linting)
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

| Setting      | Home (Max)               | Work (API)             |
| ------------ | ------------------------ | ---------------------- |
| Model        | `opus[1m]`               | `sonnet`               |
| Thinking     | Always on                | Off (per-task)         |
| Plugins      | 22                       | 7                      |
| MCP servers  | 3                        | project-only           |
| Hooks        | 5 events (full pipeline) | 2 events (status only) |
| Output style | Learning                 | Default                |
| Agent teams  | Enabled                  | Not set                |
| Deny rules   | Extended (disk + rm)     | Basic (env + locks)    |
| Ask rules    | git + browsermcp         | git + browsermcp       |
| Attribution  | Suppressed               | Not set                |
| Cost concern | None (unlimited)         | Per-token              |
