#!/bin/bash

update() {
	WIDTH="dynamic"
	if [ "$SELECTED" = "true" ]; then
		WIDTH="0"
	fi

	sketchybar --animate tanh 20 --set $NAME icon.highlight=$SELECTED label.width=$WIDTH
}

mouse_clicked() {
	# Use macOS native space switching via keyboard shortcut simulation
	# Note: Requires "Keyboard Shortcuts > Mission Control > Switch to Desktop X" enabled in System Settings
	if [ "$BUTTON" = "right" ]; then
		# Open Mission Control for space management (no yabai delete)
		open -a "Mission Control"
	else
		# Focus space using AppleScript to simulate ctrl+number
		osascript -e "tell application \"System Events\" to key code $((17 + SID)) using control down" 2>/dev/null || true
	fi
}

case "$SENDER" in
"mouse.clicked")
	mouse_clicked
	;;
*)
	update
	;;
esac
