#!/bin/bash

# Portable MCP GitHub wrapper script
# Requires GITHUB_PERSONAL_ACCESS_TOKEN environment variable

# Load environment variables if .env file exists
DOTFILES_DIR="${DOTFILES:-$HOME/.dotfiles}"
if [ -f "$DOTFILES_DIR/.env" ]; then
    source "$DOTFILES_DIR/.env"
fi

if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    echo "Error: GITHUB_PERSONAL_ACCESS_TOKEN environment variable is required"
    echo "Please set GITHUB_PERSONAL_ACCESS_TOKEN in your .env file or environment"
    exit 1
fi

# Set the token for the GitHub MCP server (it expects GITHUB_TOKEN)
export GITHUB_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN"

exec npx -y github-mcp-server