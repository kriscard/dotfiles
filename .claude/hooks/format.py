#!/usr/bin/env python3

import json
import sys
import subprocess
from pathlib import Path

PRETTIER_EXTENSIONS = (
    ".ts", ".tsx", ".js", ".jsx",
    ".json", ".css", ".scss",
    ".html", ".md", ".yaml", ".yml",
)


def main():
    try:
        input_data = json.load(sys.stdin)
        file_path = input_data.get("tool_input", {}).get("file_path")

        if not file_path:
            sys.exit(0)

        if not file_path.endswith(PRETTIER_EXTENSIONS):
            sys.exit(0)

        if not Path(file_path).exists():
            sys.exit(0)

        try:
            original = Path(file_path).read_text()
            result = subprocess.run(
                ["prettierd", "--stdin-filepath", file_path],
                input=original,
                capture_output=True,
                text=True,
                timeout=10,
            )

            if result.returncode == 0 and result.stdout:
                Path(file_path).write_text(result.stdout)

        except (subprocess.TimeoutExpired, FileNotFoundError):
            sys.exit(0)

    except json.JSONDecodeError:
        sys.exit(1)
    except Exception as e:
        print(f"Error in format hook: {e}", file=sys.stderr)
        sys.exit(1)


main()
