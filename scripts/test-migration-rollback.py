#!/usr/bin/env python3
"""Verify the real Stow rollback protocol in a disposable home, not the live one."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MigrationRollback(unittest.TestCase):
    def test_unstow_removes_mise_links_and_old_defaults_can_be_restored(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            old = home / ".tool-versions"
            original = b"nodejs 26.12.1\nruby 3.3.6\n"
            old.write_bytes(original)
            env = dict(os.environ, HOME=tmp)
            command = ["/bin/bash", str(ROOT / "dotfiles")]
            subprocess.run(command + ["sync"], cwd=ROOT, env=env, capture_output=True, check=True)
            targets = [home / ".config/mise/config.toml", home / "zsh/zsh.d/90-mise.zsh"]
            for target in targets:
                self.assertTrue(target.is_symlink())
                self.assertTrue(target.exists())
            retired = home / "tool-versions.saved"
            old.rename(retired)
            self.assertFalse(old.exists())

            # Unstow while the new package still exists, BEFORE checking out old code.
            subprocess.run(command + ["unstow", "--force"], cwd=ROOT, env=env, capture_output=True, check=True)
            for target in targets:
                self.assertFalse(os.path.lexists(target), "Rollback must not leave dangling migration links")
            self.assertTrue(retired.exists(), "Unstow must not delete the saved runtime declarations")
            retired.rename(old)
            self.assertEqual(old.read_bytes(), original)


if __name__ == "__main__":
    unittest.main()
