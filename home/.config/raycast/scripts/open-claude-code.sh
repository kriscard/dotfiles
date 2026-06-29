#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Claude Code
# @raycast.mode silent
# @raycast.packageName Dev

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "dropdown", "placeholder": "Project", "data": [{"title": "dotfiles", "value": "dotfiles"}, {"title": "Roofr", "value": "roofr"}, {"title": "Claude Plugins", "value": "claude-plugins"}, {"title": "Playground", "value": "playground"}, {"title": "Blog", "value": "blog"}] }

# Documentation:
# @raycast.description Open a project in Claude Code via Sesh tmux session

PROJECT="$1"

case "$PROJECT" in
  "dotfiles")
    PATH_DIR="$HOME/.dotfiles"
    ;;
  "roofr")
    PATH_DIR="$HOME/Code/roofr-dev/roofr"
    ;;
  "claude-plugins")
    PATH_DIR="$HOME/projects/kriscard-claude-plugins"
    ;;
  "playground")
    PATH_DIR="$HOME/projects/playground"
    ;;
  "blog")
    PATH_DIR="$HOME/projects/christophercardoso.dev"
    ;;
esac

# Create/connect sesh session with Claude Code
# --switch: works from outside terminal (Raycast)
# --command: runs claude when session is NEW
sesh connect "$PATH_DIR" --switch --command "claude"

# Activate terminal
osascript -e 'tell application "Ghostty" to activate'
