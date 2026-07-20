#!/usr/bin/env python3

import json
import sys
import subprocess
from pathlib import Path


def main():
    try:
        # Read input data from stdin
        input_data = json.load(sys.stdin)

        tool_input = input_data.get("tool_input", {})

        # Get file path from tool input
        file_path = tool_input.get("file_path")
        if not file_path:
            sys.exit(0)

        # Only check TypeScript/JavaScript files
        if not file_path.endswith((".ts", ".tsx", ".js", ".jsx")):
            sys.exit(0)

        # Check if file exists
        if not Path(file_path).exists():
            sys.exit(0)

        # Use the project's own ESLint so the version matches its plugins.
        # (npx from a workspace root silently downloads latest ESLint, which
        # breaks against project configs pinned to an older major.)
        eslint_bin = None
        package_root = None
        for parent in Path(file_path).resolve().parents:
            candidate = parent / "node_modules" / ".bin" / "eslint"
            if candidate.exists():
                eslint_bin = str(candidate)
                package_root = str(parent)
                break

        if eslint_bin is None:
            sys.exit(0)

        # Run ESLint to check for errors and style violations. cwd must be
        # the package root: flat-config discovery is cwd-based in ESLint 9+.
        try:
            result = subprocess.run(
                [eslint_bin, file_path, "--format", "compact"],
                capture_output=True,
                text=True,
                timeout=30,
                cwd=package_root,
            )

            if result.returncode != 0 and (result.stdout or result.stderr):
                # Log the error for debugging
                log_file = Path(__file__).parent.parent / "eslint_errors.json"
                error_output = result.stdout or result.stderr
                error_entry = {
                    "file_path": file_path,
                    "errors": error_output,
                    "session_id": input_data.get("session_id"),
                }

                # Load existing errors or create new list
                if log_file.exists():
                    with open(log_file, "r") as f:
                        errors = json.load(f)
                else:
                    errors = []

                errors.append(error_entry)

                # Save errors
                with open(log_file, "w") as f:
                    json.dump(errors, f, indent=2)

                # Send error message to stderr for LLM to see
                print(f"ESLint errors found in {file_path}:", file=sys.stderr)
                print(error_output, file=sys.stderr)

                # Exit with code 2 to signal LLM to correct
                sys.exit(2)

        except subprocess.TimeoutExpired:
            print("ESLint check timed out", file=sys.stderr)
            sys.exit(0)
        except FileNotFoundError:
            # ESLint not available, skip check
            sys.exit(0)

    except json.JSONDecodeError as e:
        print(f"Error parsing JSON input: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error in eslint hook: {e}", file=sys.stderr)
        sys.exit(1)


main()
