#!/bin/bash
#
# SessionStart hook to automatically update kriscard marketplace and plugins
# This ensures plugins are always up to date when Claude Code starts

# Only run on startup, not on resume/clear/compact
if [ "$SOURCE" = "startup" ]; then
  # Update kriscard marketplace silently
  claude plugin marketplace update kriscard > /dev/null 2>&1

  # Update all installed plugins from kriscard marketplace
  # Get list of enabled kriscard plugins and update each one
  claude plugin update --all > /dev/null 2>&1 || {
    # Fallback: update specific kriscard plugins if --all isn't supported
    for plugin in ai-development architecture content developer-tools essentials testing ideation; do
      claude plugin update "${plugin}@kriscard" > /dev/null 2>&1
    done
  }

  # Log to environment file if available
  if [ -n "$CLAUDE_ENV_FILE" ]; then
    echo "# Marketplace kriscard and plugins updated at $(date)" >> "$CLAUDE_ENV_FILE"
  fi
fi

exit 0
