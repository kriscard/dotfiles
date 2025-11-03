# Claude Code Setup

This guide explains how to configure Claude Code with custom hooks and MCP server integrations for this dotfiles repository.

## Configuration File

Create or update `.claude/settings.json` with the following configuration:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "uv run ~/.dotfiles/.claude/hooks/notification.py"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "uv run ~/.dotfiles/.claude/hooks/notification.py"
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
  "enabledMcpjsonServers": [
    "mcp-obsidian",
    "playwright",
    "context7",
    "sequential-thinking",
    "browsermcp",
    "shadcn"
  ],
  "enableAllProjectMcpServers": true
}
```

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
