#!/usr/bin/env python3
"""Exercise the hardening CLI on real files while preserving unrelated settings."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).with_name("harden-claude-settings.py")


class ClaudeDefaults(unittest.TestCase):
    def test_check_apply_and_repeat_through_stow_link(self):
        execution_rules = [
            "Bash(docker compose exec *)", "Bash(docker run *)", "Bash(node *)",
            "Bash(nvim --headless *)", "Bash(luajit *)", "Bash(lua -e *)",
            "Bash(npm run build *)",
        ]
        original = {
            "enableAllProjectMcpServers": True,
            "enabledMcpjsonServers": ["context7"],
            "permissions": {
                "allow": execution_rules + ["Bash(git status)"],
                "ask": ["Bash(git commit *)"],
                "deny": ["Read(./.env)"],
            },
            "hooks": {"Notification": [{"hooks": [{"type": "command", "command": "custom-hook"}]}]},
            "model": "keep-this-model",
        }
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "settings.json"
            target.write_text(json.dumps(original))
            link = Path(tmp) / "stowed-settings.json"
            link.symlink_to(target)
            command = [sys.executable, str(SCRIPT), "--settings", str(link)]
            before = target.read_bytes()
            check = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(check.returncode, 1)
            self.assertEqual(target.read_bytes(), before)
            subprocess.run(command + ["--apply"], check=True, capture_output=True)
            self.assertTrue(link.is_symlink())
            result = json.loads(target.read_text())
            self.assertIs(result["enableAllProjectMcpServers"], False)
            self.assertEqual(result["enabledMcpjsonServers"], [])
            self.assertEqual(result["hooks"], original["hooks"])
            self.assertEqual(result["model"], original["model"])
            self.assertEqual(result["permissions"]["deny"], original["permissions"]["deny"])
            self.assertEqual(result["permissions"]["allow"], ["Bash(git status)"])
            self.assertTrue(set(execution_rules) <= set(result["permissions"]["ask"]))
            self.assertIn("Bash(git commit *)", result["permissions"]["ask"])
            backups = list(Path(tmp).glob("settings.json.*.bak"))
            self.assertEqual(len(backups), 1)
            self.assertEqual(backups[0].read_bytes(), before)
            self.assertEqual(backups[0].stat().st_mode & 0o777, 0o600)
            self.assertEqual(target.stat().st_mode & 0o777, 0o600)
            subprocess.run(command, check=True, capture_output=True)
            subprocess.run(command + ["--apply"], check=True, capture_output=True)
            self.assertEqual(len(list(Path(tmp).glob("settings.json.*.bak"))), 1)


if __name__ == "__main__":
    unittest.main()
