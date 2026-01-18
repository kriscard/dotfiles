# Claude Code Setup

This guide explains how to configure Claude Code with custom hooks and MCP server integrations for this dotfiles repository.

## Configuration File

Create or update `.claude/settings.json` with the following configuration:

````json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
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
    ]
  },
  "model": "opus",
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": [
    "mcp-obsidian",
    "playwright",
    "context7",
    "sequential-thinking",
    "browsermcp",
    "shadcn"
  ],
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          { "type": "command", "command": "~/.dotfiles/bin/claude-status-hook PreToolUse" }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "uv run ~/.dotfiles/.claude/hooks/notification.py" },
          { "type": "command", "command": "~/.dotfiles/bin/claude-status-hook Stop" }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          { "type": "command", "command": "~/.dotfiles/bin/claude-status-hook SubagentStop" }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          { "type": "command", "command": "uv run ~/.dotfiles/.claude/hooks/notification.py" },
          { "type": "command", "command": "~/.dotfiles/bin/claude-status-hook Notification" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          { "type": "command", "command": "uv run ~/.dotfiles/.claude/hooks/ts_lint.py" }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "~/.dotfiles/bin/claude-statusline"
  },
  "enabledPlugins": {
    "essentials@kriscard": true,
    "ideation@kriscard": true,
    "content@kriscard": true,
    "architecture@kriscard": true,
    "ai-development@kriscard": true,
    "developer-tools@kriscard": true,
    "testing@kriscard": true,
    "frontend-design@anthropic": true,
    "ralph-loop@anthropic": true,
    "agent-sdk-dev@anthropic": true,
    "hookify@anthropic": true,
    "superpowers@anthropic": true,
    "plugin-dev@anthropic": true,
    "explanatory-output-style@anthropic": true,
    "learning-output-style@anthropic": true,
    "lua-lsp@anthropic": true,
    "explanatory-output-style@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true,
    "agent-sdk-dev@claude-plugins-official": true,
    "hookify@claude-plugins-official": true,
    "learning-output-style@claude-plugins-official": true,
    "lua-lsp@claude-plugins-official": true,
    "assistant@kriscard": true,
    "studio-startup@kriscard": true
  },
  "extraKnownMarketplaces": {
    "kriscard": {
      "source": {
        "source": "github",
        "repo": "kriscard/kriscard-claude-plugins"
      }
    }
  },
  "alwaysThinkingEnabled": true
}
````

## Configuration Sections

### Hooks

Claude Code hooks allow you to run custom commands in response to specific events:

- **Stop**: Triggered when Claude Code stops processing
  - Sends a desktop notification via `notification.py`

- **Notification**: Triggered on notification events
  - Sends a desktop notification via `notification.py`

- **PostToolUse**: Triggered after specific tool usage
  - Runs TypeScript linting via `ts_lint.py` after Write, Edit, or MultiEdit operations
  - Helps maintain code quality automatically

### MCP Servers

MCP (Model Context Protocol) servers provide Claude Code with additional capabilities:

- **mcp-obsidian**: Integration with Obsidian notes
- **playwright**: Browser automation and testing
- **context7**: Library documentation access
- **sequential-thinking**: Enhanced reasoning capabilities
- **browsermcp**: Web browsing and navigation
- **shadcn**: shadcn/ui component integration

The `enableAllProjectMcpServers` setting automatically enables any MCP servers defined in project-specific configurations.

## Plugins

Claude Code supports plugins that extend functionality with specialized agents, skills, and workflows.

### Adding Custom Marketplaces

Before installing plugins, add the custom marketplaces to your Claude Code configuration:

```bash
# Add kriscard marketplace (personal plugins)
claude plugin marketplace add kriscard/kriscard-claude-plugins

# Add claude-plugins-official marketplace
claude plugin marketplace add anthropics/claude-plugins-official
```

### Installing Plugins

#### From kriscard Marketplace (Personal Workflow Tools)

```bash
claude plugin install essentials@kriscard           # Core workflow tools (commit, PR, search)
claude plugin install assistant@kriscard            # Staff Engineer workflow assistant
claude plugin install ideation@kriscard             # Brain dumps → structured specs
claude plugin install content@kriscard              # Blog posts & conference talks
claude plugin install architecture@kriscard         # System design & CTO advisor
claude plugin install ai-development@kriscard       # LLM/RAG & prompt engineering
claude plugin install developer-tools@kriscard      # Coding, debugging, frontend agents
claude plugin install testing@kriscard              # Unit, integration, E2E specialists
claude plugin install studio-startup@kriscard       # Project/startup orchestration
```

#### From claude-plugins-official Marketplace

```bash
claude plugin install feature-dev@claude-plugins-official           # Feature development workflow
claude plugin install agent-sdk-dev@claude-plugins-official         # Agent SDK tools
claude plugin install hookify@claude-plugins-official               # Hook creation & management
claude plugin install explanatory-output-style@claude-plugins-official  # Educational explanations
claude plugin install learning-output-style@claude-plugins-official     # Interactive learning mode
claude plugin install lua-lsp@claude-plugins-official               # Lua LSP integration
```

### Verifying Installed Plugins

```bash
# List all installed plugins
claude plugin list

# Check plugin status in Claude Code
/plugin
```

### Plugin Categories Overview

| Category | Plugins | Purpose |
|----------|---------|---------|
| **Core Workflow** | essentials, assistant | Git commits, PRs, task management |
| **Content Creation** | ideation, content | Specs, blog posts, talks |
| **Architecture** | architecture | System design, ADRs, C4 diagrams |
| **Development** | developer-tools, ai-development | Coding agents, LLM tools |
| **Testing** | testing | Unit, integration, E2E testing |
| **Output Styles** | explanatory, learning | Educational explanations |
| **Specialized** | hookify, studio-startup, feature-dev | Hooks, project setup, workflows |

## Requirements

- **uv**: Python package manager required for running hook scripts
  - Install via: `brew install uv`
- **Hook scripts**: Located in `~/.dotfiles/.claude/hooks/`
  - `notification.py`: Desktop notification handler
  - `ts_lint.py`: TypeScript linting automation

## Verification

After creating the configuration file:

1. Restart Claude Code or reload the configuration
2. Test hooks by performing file edits (should trigger TypeScript linting)
3. Verify MCP servers are available using the `/mcp` command in Claude Code
````
