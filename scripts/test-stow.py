#!/usr/bin/env python3
"""Real Stow apply/restow against disposable authored/runtime fixtures."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class StowBoundaries(unittest.TestCase):
    def test_authored_files_link_but_runtime_does_not(self):
        authored = [".config/raycast/scripts/example.sh", ".config/spicetify/config-xpui.ini", ".config/tmux/tmux.conf"]
        runtime = [
            ".config/raycast/preferences.json", ".config/tmux/plugins/tpm/tpm",
            ".config/spicetify/Themes/example/README.md", ".config/spicetify/Extensions/example.js",
            ".config/karabiner/automatic_backups/example.json", ".config/gh/config.yml",
            ".claude/settings.json", ".claude/settings.json.example.bak",
            ".claude/hooks/__pycache__/example.pyc", "bin/__pycache__/example.pyc",
        ]
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp) / "repo"
            target = Path(tmp) / "target"
            repo.mkdir()
            target.mkdir()
            for name in ("dotfiles", ".stow-local-ignore"):
                shutil.copy2(ROOT / name, repo / name)
            for relative in authored + runtime:
                path = repo / "home" / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("fixture")
            sentinel = target / ".config/tmux/plugins/existing"
            sentinel.parent.mkdir(parents=True)
            sentinel.write_text("keep runtime")
            env = dict(os.environ, HOME=str(target))
            for _ in range(2):
                result = subprocess.run(["bash", str(repo / "dotfiles"), "sync", "--verbose"], env=env, check=True, capture_output=True, text=True)
                for relative in authored:
                    self.assertTrue((target / relative).is_symlink(), relative)
                for relative in runtime:
                    self.assertFalse((target / relative).exists(), relative + "\n" + result.stdout + result.stderr)
                self.assertEqual(sentinel.read_text(), "keep runtime")


if __name__ == "__main__":
    unittest.main()
