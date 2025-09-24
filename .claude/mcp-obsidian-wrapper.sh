#!/bin/bash

# Portable MCP Obsidian wrapper script
# Expands the home directory path and runs mcp-obsidian

# Use DOTFILES environment variable if available, otherwise default to ~/.dotfiles
DOTFILES_DIR="${DOTFILES:-$HOME/.dotfiles}"
OBSIDIAN_VAULT_PATH="$HOME/obsidian-vault-kriscard"
exec npx -y mcp-obsidian "$OBSIDIAN_VAULT_PATH"