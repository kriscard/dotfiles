#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Yesterday's Git Activity
# @raycast.mode fullOutput
# @raycast.packageName Dev

# Optional parameters:
# @raycast.icon 📝

# Documentation:
# @raycast.description Show recent git commits for standup (last 2 days)

echo "## Recent Git Activity (Last 2 Days)"
echo ""

USER_EMAIL=$(git config user.email)
echo "Author: $USER_EMAIL"
echo ""

DIRS=(
  "$HOME/.dotfiles"
  "$HOME/Code/roofr-dev/roofr"
  "$HOME/projects/kriscard-claude-plugins"
  "$HOME/projects/christophercardoso.dev"
)

FOUND_COMMITS=false

for dir in "${DIRS[@]}"; do
  if [ -d "$dir" ]; then
    cd "$dir" 2>/dev/null || continue

    # Check if it's a git repo
    if git rev-parse --git-dir > /dev/null 2>&1; then
      commits=$(git log --oneline --since="2 days ago" --author="$USER_EMAIL" 2>/dev/null)

      if [ -n "$commits" ]; then
        FOUND_COMMITS=true
        echo "### $(basename $dir)"
        echo "$commits"
        echo ""
      fi
    fi
  fi
done

if [ "$FOUND_COMMITS" = false ]; then
  echo "No commits found in the last 2 days"
fi
