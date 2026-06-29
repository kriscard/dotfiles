#!/usr/bin/env python3

import sys
import json
import os
import urllib.request
import urllib.error
import argparse
import subprocess
from pathlib import Path

def load_env():
    """Load environment variables from .env file"""
    env_file = Path.home() / ".dotfiles" / ".env"
    if env_file.exists():
        with open(env_file) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    os.environ[key] = value

def is_terminal_focused():
    """Check if any terminal application has focus on macOS"""
    try:
        script = '''
        tell application "System Events"
            set frontApp to name of first application process whose frontmost is true
            return frontApp
        end tell
        '''
        result = subprocess.run(
            ['osascript', '-e', script],
            capture_output=True,
            text=True,
            timeout=2
        )

        if result.returncode == 0:
            front_app = result.stdout.strip().lower()
            terminal_apps = ['terminal', 'iterm', 'iterm2', 'kitty', 'ghostty', 'wezterm', 'alacritty']
            is_focused = any(app in front_app for app in terminal_apps)
            print(f"Front app: {front_app}, Terminal focused: {is_focused}", file=sys.stderr)
            return is_focused

        print(f"Could not detect front app: {result.stderr}", file=sys.stderr)
        return False

    except Exception as e:
        print(f"Focus detection failed: {e}", file=sys.stderr)
        return False

def send_notification(title, message, priority=3, tags=None, ntfy_topic=None):
    """Send a notification via ntfy.sh to both macOS and iPhone"""
    if not ntfy_topic:
        ntfy_topic = os.environ.get("NTFY_TOPIC")

    if not ntfy_topic:
        print("NTFY_TOPIC not set, skipping notification", file=sys.stderr)
        return

    try:
        url = f"https://ntfy.sh/{ntfy_topic}"

        # Build headers
        headers = {
            "Title": title,
            "Priority": str(priority),
        }

        if tags:
            headers["Tags"] = ",".join(tags)

        # Send POST request
        req = urllib.request.Request(
            url,
            data=message.encode("utf-8"),
            headers=headers,
            method="POST"
        )

        with urllib.request.urlopen(req, timeout=5) as response:
            if response.status == 200:
                print(f"Notification sent: {title}", file=sys.stderr)
            else:
                print(f"Unexpected status: {response.status}", file=sys.stderr)

    except urllib.error.URLError as e:
        print(f"Network error sending notification: {e}", file=sys.stderr)
    except Exception as e:
        print(f"Notification failed: {e}", file=sys.stderr)

def main():
    # Load environment variables from .env file
    load_env()

    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Send ntfy.sh notifications")
    parser.add_argument("--topic", help="ntfy.sh topic to send to")
    args = parser.parse_args()

    # Check if terminal is focused - skip notification if it is
    if is_terminal_focused():
        print("Terminal is focused, skipping notification", file=sys.stderr)
        return

    try:
        input_data = json.load(sys.stdin)
        hook_event = input_data.get("hook_event_name", "")
        notification_message = input_data.get("message", "")

        print(f"Hook event: {hook_event}", file=sys.stderr)
        print(f"Input data: {json.dumps(input_data)}", file=sys.stderr)

        # Handle Stop hook - operation finished
        if hook_event == "Stop":
            title = "Claude Code Complete"
            message = "Operation finished - ready for next task"
            priority = 3
            tags = ["white_check_mark", "robot"]

        # Handle Notification hook - awaiting response or permission
        elif hook_event == "Notification":
            # Check if this is an "awaiting response" notification
            if "awaiting" in notification_message.lower() or "waiting" in notification_message.lower():
                title = "Claude Code Awaiting Response"
                message = notification_message or "Input needed"
                priority = 4
                tags = ["question", "bell"]
            else:
                # Other notifications (permissions, etc.)
                title = "Claude Code Notification"
                message = notification_message or "Notification from Claude Code"
                priority = 3
                tags = ["bell", "robot"]

        else:
            # Unknown hook type
            print(f"Unknown hook event: {hook_event}", file=sys.stderr)
            return

        send_notification(title, message, priority, tags, ntfy_topic=args.topic)

    except json.JSONDecodeError as e:
        print(f"Failed to parse JSON input: {e}", file=sys.stderr)
    except Exception as e:
        print(f"Error processing hook: {e}", file=sys.stderr)

main()
