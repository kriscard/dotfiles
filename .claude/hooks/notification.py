#!/usr/bin/env python3

import subprocess
import sys
import json

def send_notification(title, message):
    """Send a macOS notification using basic osascript"""
    try:
        subprocess.run([
            'osascript',
            '-e',
            f'display notification "{message}" with title "{title}"'
        ], check=True)
    except Exception as e:
        print(f"Notification failed: {e}", file=sys.stderr)

def main():
    print("Notification hook triggered!", file=sys.stderr)
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name")
        print(f"Tool name: {tool_name}", file=sys.stderr)
    except:
        # Fallback if no JSON input (like from Stop hook)
        tool_name = None
        print("No JSON input received", file=sys.stderr)

    # Create notification title and message based on tool name
    if tool_name == 'Bash':
        title = "Command Executed"
        message = "Terminal command completed"
    elif tool_name == 'Edit':
        title = "File Modified"
        message = "File has been edited"
    elif tool_name == 'Write':
        title = "File Created"
        message = "New file has been written"
    elif tool_name == 'Read':
        title = "File Accessed"
        message = "File has been read"
    elif tool_name == 'Grep':
        title = "Search Complete"
        message = "Text search finished"
    elif tool_name == 'Glob':
        title = "Pattern Match"
        message = "File pattern search completed"
    elif tool_name == 'WebFetch':
        title = "Web Request"
        message = "Web content fetched"
    elif tool_name == 'Task':
        title = "Task Complete"
        message = "Background task finished"
    else:
        # Check if this is from a UserPromptSubmit or Stop hook (awaiting input)
        title = "Claude Code Ready"
        message = "Awaiting your input"
    
    send_notification(title, message)

main()
