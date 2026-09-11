#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Herdr Projects
# @raycast.mode silent
# @raycast.packageName Dev

# Optional parameters:
# @raycast.icon 🐘
# @raycast.description Open the Herdr Plus project picker

set -euo pipefail

# Raycast does not inherit the interactive shell PATH, so check the user install first.
if [[ -x "$HOME/.local/bin/herdr" ]]; then
  HERDR_BIN="$HOME/.local/bin/herdr"
else
  HERDR_BIN="$(command -v herdr || true)"
fi

if [[ -z "$HERDR_BIN" && -x /opt/homebrew/bin/herdr ]]; then
  HERDR_BIN=/opt/homebrew/bin/herdr
fi

if [[ -z "$HERDR_BIN" ]]; then
  osascript -e 'display notification "herdr is not available on PATH" with title "Open Herdr Projects"'
  exit 1
fi

"$HERDR_BIN" plugin action invoke projects --plugin cloudmanic.herdr-plus >/dev/null
osascript -e 'tell application "Ghostty" to activate'
