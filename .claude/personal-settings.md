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
      "Bash(docker compose exec:*)",
      "Bash(docker run:*)",
      "Bash(gh pr view:*)",
      "Bash(gh run view:*)",
      "Bash(git branch:*)",
      "Bash(git checkout:*)",
      "Bash(git fetch:*)",
      "Bash(git rebase:*)",
      "Bash(git stash:*)",
      "Bash(git switch:*)",
      "Bash(mkdir:*)",
      "Bash(node:*)",
      "Bash(npm run build:*)",
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
      "Bash(mkfs.ext4 /dev/sda)",
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
      "mcp__browsermcp__*"
    ]
  },
  "model": "opus",
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": [
    "mcp-obsidian",
    "context7",
    "browsermcp"
  ],
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
    "essentials@kriscard": true,
    "developer-tools@kriscard": true,
    "testing@kriscard": true,
    "assistant@kriscard": true,
    "chromedev-tools@kriscard": true,
    "til@kriscard": true,
    "architecture@kriscard": true,
    "ideation@kriscard": true,
    "content@kriscard": true,
    "ai-development@kriscard": true,
    "neovim-advisor@kriscard": true,
    "dotfiles-optimizer@kriscard": true,
    "obsidian-second-brain@kriscard": true,
    "studio-startup@kriscard": true,
    "interactive-learning@kriscard": true
  },
  "extraKnownMarketplaces": {
    "claude-plugins-official": {
      "source": {
        "source": "github",
        "repo": "anthropics/claude-plugins-official"
      }
    }
  },
  "alwaysThinkingEnabled": true
}
```

---

## Settings Breakdown

### Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `"1"` | Enables multi-agent team coordination (experimental) |
| `ENABLE_TOOL_SEARCH` | `"auto"` | Defers MCP tool loading until needed (~47% context reduction) |

### Attribution

```json
"attribution": { "commit": "", "pr": "" }
```

Enforces the safety rule: **no AI attribution** in commits or PRs. Empty strings suppress any auto-generated attribution lines.

### Model & Thinking

- **Model**: `opus` - Most capable reasoning model (5x cost vs Sonnet, but unlimited on Max)
- **Extended thinking**: Always on - Better reasoning, deeper analysis, fewer errors

---

## Permission System

### Allow Rules

Broad auto-approve for common dev operations. Notable:
- All read-only tools (`Glob`, `Grep`, `LS`, `Read`) - no friction for exploration
- Git operations (branch, checkout, fetch, rebase, stash, switch) - but NOT `push` or `commit`
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
"ask": ["mcp__browsermcp__*"]
```

Browser automation requires confirmation. Prevents unexpected browser interactions during autonomous work.

---

## Hook Pipeline

5 hook events, each with specific purpose:

| Event | Matcher | Hook(s) | Purpose |
|-------|---------|---------|---------|
| **PreToolUse** | `Bash\|Write\|Edit\|MultiEdit` | `claude-status-hook` | Track status for write operations only |
| **Stop** | all | `notification.py` + `claude-status-hook` | Desktop notification + status update on completion |
| **SubagentStop** | all | `claude-status-hook` | Track when subagents finish |
| **Notification** | all | `notification.py` + `claude-status-hook` | System notifications + status |
| **PostToolUse** | `Write\|Edit\|MultiEdit` | `ts_lint.py` | Auto-lint TypeScript after edits |

### What's Different from Work

| Feature | Home | Work | Why |
|---------|------|------|-----|
| PreToolUse matcher | Yes (write ops only) | Yes (same) | Reduces hook overhead |
| Stop notification | `notification.py` | Removed | Python overhead per-stop |
| SubagentStop | Enabled | Removed | Not needed at work |
| Notification hook | Enabled | Removed | Extra overhead |
| PostToolUse linting | Enabled | Removed | Node process per-edit |

---

## Plugin Ecosystem (21 plugins)

### Official Plugins (5)

| Plugin | Purpose |
|--------|---------|
| `feature-dev` | Guided feature development workflow |
| `agent-sdk-dev` | Claude Agent SDK app creation |
| `learning-output-style` | Educational response mode |
| `plugin-dev` | Plugin creation and validation |
| `linear` | Linear issue tracker integration |

### Community Plugins (15 @kriscard)

| Plugin | Category | Purpose |
|--------|----------|---------|
| `essentials` | Core | Git commits, PRs, specs, search, deep thinking |
| `developer-tools` | Dev | Code review, debugging, TypeScript, frontend, Next.js |
| `testing` | QA | Unit, integration, E2E, automation testing |
| `assistant` | Workflow | Standup, weekly summary, context management, career |
| `chromedev-tools` | Browser | Page inspection, screenshots, performance traces |
| `til` | Learning | Today I Learned note creation |
| `architecture` | Design | Repo analysis, sprint planning, arch docs, ADRs |
| `ideation` | Planning | Brain dump to structured specs workflow |
| `content` | Writing | Blog posts, conference talks, technical docs |
| `ai-development` | AI/ML | Prompt engineering, RAG, agent orchestration |
| `neovim-advisor` | Editor | Plugin recommendations, LSP config, performance |
| `dotfiles-optimizer` | Config | Shell config optimization, audit |
| `obsidian-second-brain` | PKM | Vault management, PARA, OKRs, templates |
| `studio-startup` | Projects | New project/MVP guided workflow |
| `interactive-learning` | Education | Interactive learning sessions |

### Third-Party (1)

| Plugin | Purpose |
|--------|---------|
| `obsidian@obsidian-skills` | Obsidian markdown, bases, JSON canvas |

### Removed from Previous (3)

| Removed Plugin | Reason |
|----------------|--------|
| `hookify` | Superseded by native hook configuration |
| `explanatory-output-style` | Redundant with `learning-output-style` |
| `lua-lsp` | Rarely used, adds context overhead |

---

## MCP Server Configuration

### Enabled Servers (3)

| Server | Purpose | When Used |
|--------|---------|-----------|
| **mcp-obsidian** | Vault read/write/search | Fallback when Obsidian CLI unavailable |
| **context7** | Library documentation | Up-to-date framework/library docs |
| **browsermcp** | Browser automation | Interactive web testing (requires `ask` confirmation) |

### Removed from Previous (3)

| Removed Server | Reason |
|----------------|--------|
| `playwright` | Redundant with browsermcp for most tasks |
| `sequential-thinking` | Rarely used, extended thinking covers this |
| `shadcn` | Only needed for specific UI projects |

### CLI Over MCP

Prefer built-in tools and CLI over MCP where possible:
- **GitHub**: `gh` CLI commands
- **Web content**: `WebFetch` / `WebSearch` built-ins
- **Obsidian**: `obsidian` CLI first, MCP as fallback
- **Browser**: Only MCP when interaction needed (clicking, forms)

---

## Quick Reference

```
Model: opus
Thinking: always on
Plugins: 21 (5 official + 15 @kriscard + 1 third-party)
MCP servers: 3 (mcp-obsidian, context7, browsermcp)
Hooks: full pipeline (status, notifications, linting)
Style: learning (educational responses)
Teams: enabled (experimental)
Tool search: auto (deferred loading)
Attribution: suppressed (empty strings)
Status line: enabled
```

---

## Side-by-Side Comparison with Work

| Setting | Home (Max) | Work (API) |
|---------|------------|------------|
| Model | `opus` | `sonnet` |
| Thinking | Always on | Off (per-task) |
| Plugins | 21 | 7 |
| MCP servers | 3 | project-only |
| Hooks | 5 events (full pipeline) | 2 events (status only) |
| Output style | Learning | Default |
| Agent teams | Enabled | Not set |
| Deny rules | Extended (disk + rm) | Basic (env + locks) |
| Ask rules | browsermcp | None |
| Attribution | Suppressed | Not set |
| Cost concern | None (unlimited) | Per-token |
