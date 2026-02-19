#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Roofr New Worktree
# @raycast.mode compact
# @raycast.packageName Work

# Optional parameters:
# @raycast.icon 🌲
# @raycast.argument1 { "type": "text", "placeholder": "Branch name (e.g., feat/new-feature)" }

# Documentation:
# @raycast.description Create a new Roofr git worktree and open via sesh

BRANCH="$1"

if [ -z "$BRANCH" ]; then
  echo "Branch name required"
  exit 1
fi

cd ~/Code/roofr-dev/roofr || exit 1

# Fetch latest main and create worktree
git fetch origin main
git worktree add "$BRANCH" -b "$BRANCH" origin/main

if [ $? -eq 0 ]; then
  echo "Created worktree: $BRANCH"
  # Connect via sesh (--switch for Raycast)
  sesh connect "$BRANCH" --switch
  osascript -e 'tell application "Ghostty" to activate'
else
  echo "Failed to create worktree"
  exit 1
fi
