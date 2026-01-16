#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title GitHub Dashboard
# @raycast.mode silent
# @raycast.packageName Dev

# Optional parameters:
# @raycast.icon 📊

# Documentation:
# @raycast.description Open gh-dash in tmux (prefix + g)

# Activate Ghostty
osascript -e 'tell application "Ghostty" to activate'
sleep 0.3

# Send Ctrl+a (tmux prefix) then g
osascript -e 'tell application "System Events"
    keystroke "a" using control down
    delay 0.1
    keystroke "g"
end tell'
