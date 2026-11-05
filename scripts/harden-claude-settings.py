#!/usr/bin/env python3
"""Apply only the audited security defaults to a machine-local Claude settings file."""
import argparse
import copy
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import tempfile

EXECUTION_RULES = {
    "Bash(docker compose exec *)", "Bash(docker run *)", "Bash(node *)",
    "Bash(nvim --headless *)", "Bash(luajit *)", "Bash(lua -e *)",
    "Bash(npm run build *)",
}


def harden(settings):
    result = copy.deepcopy(settings)
    result["enableAllProjectMcpServers"] = False
    result["enabledMcpjsonServers"] = []
    permissions = result.setdefault("permissions", {})
    permissions["allow"] = [r for r in permissions.get("allow", []) if r not in EXECUTION_RULES]
    ask = permissions.setdefault("ask", [])
    for rule in sorted(EXECUTION_RULES):
        if rule not in ask:
            ask.append(rule)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--settings", type=Path, default=Path.home() / ".claude/settings.json")
    parser.add_argument("--apply", action="store_true", help="write changes after backing up the original")
    args = parser.parse_args()
    # Follow Stow links rather than replacing the link itself.
    path = args.settings.expanduser().resolve(strict=True)
    original = json.loads(path.read_text())
    updated = harden(original)
    if original == updated:
        print("PASS: audited Claude security defaults already applied")
        return 0
    if not args.apply:
        print("FAIL: project MCP activation or broad execution approvals need hardening")
        return 1

    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    backup = path.with_name(path.name + "." + stamp + ".bak")
    # Create backups privately, even if the source file is more permissive.
    with open(backup, "x", opener=lambda name, flags: os.open(name, flags, 0o600)) as dest:
        dest.write(path.read_text())
    fd, temporary = tempfile.mkstemp(prefix=".settings-", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as dest:
            json.dump(updated, dest, indent=2)
            dest.write("\n")
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    print(f"Applied audited defaults; original backed up at {backup}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
