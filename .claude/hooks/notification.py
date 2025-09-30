#!/usr/bin/env python3

import sys
import json
import os
import urllib.request
import urllib.error
import argparse

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
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Send ntfy.sh notifications")
    parser.add_argument("--topic", help="ntfy.sh topic to send to")
    args = parser.parse_args()

    print("Notification hook triggered!", file=sys.stderr)
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name")
        print(f"Tool name: {tool_name}", file=sys.stderr)
    except:
        # Fallback if no JSON input (like from Stop hook)
        tool_name = None
        print("No JSON input received", file=sys.stderr)

    # Create notification title, message, priority, and tags based on tool name
    if tool_name == 'Bash':
        title = "Command Executed"
        message = "Terminal command completed"
        priority = 3
        tags = ["computer", "terminal"]
    elif tool_name == 'Edit':
        title = "File Modified"
        message = "File has been edited"
        priority = 3
        tags = ["pencil", "file"]
    elif tool_name == 'Write':
        title = "File Created"
        message = "New file has been written"
        priority = 3
        tags = ["sparkles", "file"]
    elif tool_name == 'Read':
        title = "File Accessed"
        message = "File has been read"
        priority = 2
        tags = ["books", "file"]
    elif tool_name == 'Grep':
        title = "Search Complete"
        message = "Text search finished"
        priority = 3
        tags = ["mag", "search"]
    elif tool_name == 'Glob':
        title = "Pattern Match"
        message = "File pattern search completed"
        priority = 3
        tags = ["mag", "file"]
    elif tool_name == 'WebFetch':
        title = "Web Request"
        message = "Web content fetched"
        priority = 3
        tags = ["globe_with_meridians", "web"]
    elif tool_name == 'Task':
        title = "Task Complete"
        message = "Background task finished"
        priority = 4
        tags = ["white_check_mark", "task"]
    else:
        # Check if this is from a UserPromptSubmit or Stop hook (awaiting input)
        title = "Claude Code Ready"
        message = "Awaiting your input"
        priority = 3
        tags = ["bell", "ready"]

    send_notification(title, message, priority, tags, ntfy_topic=args.topic)

main()
