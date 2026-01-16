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
    "testing@kriscard": true
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
}```

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
