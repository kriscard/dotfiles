# Claude Code Settings Guide

This document explains how to configure Claude Code for different environments (work vs personal) and why certain settings affect token consumption.

## Why Not Stow settings.json?

Claude Code's `~/.claude.json` and project `.claude/settings.json` files contain:
- Machine-specific paths and project references
- OAuth tokens and account information
- Usage statistics and session history
- Project-specific MCP server configurations

**Recommendation**: Do NOT symlink these files with Stow. Instead:
1. Use this document as a reference
2. Manually create settings on each machine
3. Keep environment-specific configurations separate

---

## Environment Differences

| Setting | Home (Max) | Work (API) |
|---------|------------|------------|
| Billing | Unlimited subscription | Per-token cost |
| Model default | `opus` | `sonnet` |
| Extended thinking | Always on | Off (enable per-task) |
| Plugins | All enabled | Minimal set |
| Output styles | Learning/explanatory | Default |
| Hooks | Full (notifications, linting) | Minimal (status only) |

---

## Work Settings (Token-Optimized)

Create this file at your work projects or in `~/.claude/settings.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "sonnet",
  "alwaysThinkingEnabled": false,
  "permissions": {
    "allow": [
      "Bash(docker compose *)",
      "Bash(docker run *)",
      "Bash(gh pr view *)",
      "Bash(gh run view *)",
      "Bash(git branch *)",
      "Bash(git checkout *)",
      "Bash(git fetch *)",
      "Bash(git rebase *)",
      "Bash(git stash *)",
      "Bash(git switch *)",
      "Bash(mkdir *)",
      "Bash(node *)",
      "Bash(npm run build *)",
      "Bash(npm run test *)",
      "Bash(npm run lint *)",
      "ExitPlanMode(*)",
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
      "Edit(./.env)",
      "Edit(./.env.*)",
      "Edit(./package-lock.json)",
      "Edit(./yarn.lock)",
      "Edit(./pnpm-lock.yaml)"
    ]
  },
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
            "command": "~/.dotfiles/bin/claude-status-hook Stop"
          }
        ]
      }
    ]
  },
  "enabledPlugins": {
    "essentials@kriscard": true,
    "developer-tools@kriscard": true,
    "testing@kriscard": true,
    "assistant@kriscard": true,
    "chromedev-tools@kriscard": true,
    "til@kriscard": true,
    "architecture@kriscard": true
  },
  "statusLine": {
    "type": "command",
    "command": "~/.dotfiles/bin/claude-statusline"
  },
  "enableAllProjectMcpServers": true
}
```

### What's Different from Home Settings

| Removed/Changed | Reason | Token Savings |
|-----------------|--------|---------------|
| `alwaysThinkingEnabled: false` | Extended thinking adds 50-200% output tokens | HIGH |
| `model: sonnet` instead of `opus` | Opus is 5x more expensive than Sonnet | HIGH |
| Removed `Notification` hooks | Python script overhead on every stop | LOW |
| Removed `SubagentStop` hooks | Unnecessary for status tracking | LOW |
| Removed `PostToolUse` ESLint hook | Spawns Node process on every edit | MEDIUM |
| Added `matcher` to PreToolUse | Only runs on write operations, not reads | MEDIUM |
| Reduced `enabledPlugins` | Fewer skill descriptions in context | MEDIUM |

---

## Home Settings (Full Features)

Your current settings at home are fine for Max subscription. Key features:
- `alwaysThinkingEnabled: true` - Better reasoning
- `model: opus` - Most capable model
- All plugins enabled - Full skill ecosystem
- Learning output style - Educational responses
- Full hooks - Notifications, linting, status

---

## Token-Saving Behaviors

### Do This

1. **Start fresh conversations** for new tasks
   - Context accumulates and costs tokens
   - After 10-15 exchanges, consider starting new

2. **Be specific in requests**
   - "Fix the null check in `src/auth.ts:42`" (specific)
   - vs "Something's wrong with authentication" (vague, requires exploration)

3. **Front-load context**
   - Provide all relevant info in first message
   - Reduces back-and-forth token accumulation

4. **Use haiku for exploration**
   - When searching codebase, specify `model: haiku` in Task agents
   - 10x cheaper than Sonnet for exploration

5. **Enable thinking only when needed**
   - Type "think harder" or "think step by step" for complex tasks
   - Don't leave it always on

### Avoid This

1. **Don't use `/learn` command at work** - Adds educational overhead
2. **Don't ask "explain everything"** - Be specific about what you need
3. **Don't run exploratory searches in main conversation** - Use Task agents
4. **Don't keep long conversations going** - Context grows expensive

---

## Setup Instructions

### Environment-Aware Launcher

Your dotfiles include `claude-work`, a wrapper that loads the right settings based on `CLAUDE_ENV`. The `ai` alias automatically uses it when `CLAUDE_ENV=work`:

```
~/.dotfiles/
├── bin/claude-work              # Wrapper script (copies profile, launches claude)
└── .claude/profiles/
    ├── settings-home.json      # Full features (Max subscription)
    └── settings-work.json      # Token-optimized (API billing, 7 essential plugins)
```

### Shell Aliases (already configured in 60-aliases.zsh)

```bash
cw              # Claude with work profile (token-optimized)
ch              # Claude with home profile (full features)
ai              # Conditional: claude-work if CLAUDE_ENV=work, else claude
claude-profile  # Show current profile
```

### At Work (New Machine)

1. **Install Claude Code**
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```

2. **Set environment variable** in your local shell config:
   ```bash
   # Copy the example and customize
   cp ~/.dotfiles/zsh/zsh.d/99-local.zsh.example ~/.dotfiles/zsh/zsh.d/99-local.zsh

   # Then add/uncomment:
   export CLAUDE_ENV="work"
   ```

   The `99-local.zsh` file is gitignored, so work-specific settings stay local.

3. **Sync dotfiles** (if using Stow):
   ```bash
   cd ~/.dotfiles && stow .
   ```
   This will symlink `bin/claude-work` and the profiles directory.

4. **Use the launcher**:
   ```bash
   claude-work          # Uses CLAUDE_ENV (work)
   # or
   cw                  # Explicitly use work profile
   ```

5. **Install required plugins** (if using custom plugins)
   ```bash
   claude plugin install essentials@kriscard
   claude plugin install developer-tools@kriscard
   claude plugin install testing@kriscard
   claude plugin install assistant@kriscard
   claude plugin install chromedev-tools@kriscard
   claude plugin install til@kriscard
   claude plugin install architecture@kriscard
   ```

### At Home (Personal Machine)

**No configuration needed!** The script defaults to `home` profile when `CLAUDE_ENV` is not set.

```bash
claude-work    # Defaults to home profile
ai            # Regular claude (also uses home by default)
ch            # Explicitly use home profile
```

### How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│  You run: cw (or claude-work with CLAUDE_ENV=work)               │
│                           ↓                                      │
│  Script checks: CLAUDE_ENV="${CLAUDE_ENV:-home}"                │
│                           ↓                                      │
│  Copies: profiles/settings-work.json → ~/.claude/settings.json  │
│                           ↓                                      │
│  Launches: claude with optimized settings                       │
└─────────────────────────────────────────────────────────────────┘
```

The settings file is only copied if it changed, so subsequent launches are fast.

---

## Status Line

The status line displays real-time session info at the bottom of Claude Code. It runs locally (no API cost).

### What It Shows

```
📁 project │ 🌿 main │ 📊 ██░░░░░░░░ 23% │ 🎵 Sonnet │ 💰 $0.42 │ 🎨 default
```

- **Project**: Current directory/project name
- **Branch**: Git branch
- **Context**: Visual progress bar of context window usage (color changes: white <40%, yellow <80%, red ≥80%)
- **Model**: Current model with icon (🎭 Opus, 🎵 Sonnet, 🍃 Haiku)
- **Cost**: Session cost in USD
- **Style**: Output style mode

### Configuration

Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.dotfiles/bin/claude-statusline"
  }
}
```

### Script Location

The script lives at `~/.dotfiles/bin/claude-statusline`. It:
- Reads JSON from stdin (provided by Claude Code)
- Extracts model, context %, cost, git branch
- Outputs ANSI-colored statusline

### Customization

Edit `bin/claude-statusline` to change:
- Icons (emoji or text)
- Colors (ANSI codes)
- Fields displayed
- Progress bar width/style

Or regenerate with `/statusline` command:
```
/statusline show model, context bar, and cost only
```

### Troubleshooting

If not visible:
1. Verify script is executable: `chmod +x ~/.dotfiles/bin/claude-statusline`
2. Test manually: `echo '{"model":{"display_name":"Sonnet"}}' | ~/.dotfiles/bin/claude-statusline`
3. Restart Claude Code after config changes

---

## Stow Strategy

### Files to Stow (symlink)
- `bin/claude-statusline` - Status line display script
- `bin/claude-status-hook` - Status tracking script
- `.claude/hooks/` - Hook scripts (notification.py, ts_lint.py)
- `.claude/CLAUDE.md` - Project instructions
- `.claude/work-settings.md` - This documentation

### Files to NOT Stow
- `~/.claude.json` - Global config with machine-specific data
- `.claude/settings.json` - Environment-specific settings
- `.claude/todos/` - Session-specific task lists
- `.claude/debug/` - Debug output
- `.claude/statsig/` - Analytics

### Stow Ignore Pattern

Add to your `.stow-local-ignore` or handle in stow command:
```
# Claude Code machine-specific files
\.claude/settings\.json
\.claude/todos
\.claude/debug
\.claude/statsig
```

---

## Quick Reference Card

### Work Environment
```
Model: sonnet
Thinking: off (use "think harder" when needed)
Plugins: essentials, developer-tools, testing, assistant, chromedev-tools, til, architecture
Hooks: status only (with matcher)
Style: default
Status line: enabled (shows project, branch, context %, model, cost)
```

### Home Environment
```
Model: opus
Thinking: always on
Plugins: all
Hooks: full (status, notifications, linting)
Style: learning
Status line: enabled (same script)
```

### Per-Task Model Override
In conversations, you can say:
- "Use haiku for this search" - Cheaper exploration
- "Think harder about this" - Enable extended thinking
- "Give me a quick answer" - Shorter responses

---

## Monitoring Token Usage

At work, monitor your usage:
1. Check Honeycomb dashboard for trends
2. Watch for 400 errors (wasted tokens on failed requests)
3. Track cost per session
4. Identify high-output-token sessions

Red flags:
- Sessions over $10-15
- Output tokens > 5x input tokens
- Many 400 "invalid request" errors
- Single conversations lasting 50+ exchanges
