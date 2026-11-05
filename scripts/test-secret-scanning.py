#!/usr/bin/env python3
"""Verify staged/history detection using a synthetic, nonfunctional token."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


class SecretScanning(unittest.TestCase):
    def test_clean_staged_and_history_contract(self):
        env = {k: v for k, v in os.environ.items() if not k.startswith(("GITLEAKS_", "GIT_"))}
        # Do not inherit signing, template, credential, or worktree settings.
        env.update(GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1")
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)

            def git(*args):
                return subprocess.run(["git", "-c", "core.hooksPath=/dev/null", *args], cwd=root,
                                      env=env, check=True, capture_output=True)

            def scan(staged=False):
                args = ["gitleaks", "git", "--redact=100", "--no-banner"]
                args += ["--pre-commit", "--staged"] if staged else ["--log-opts=--all"]
                return subprocess.run(args, cwd=root, env=env, capture_output=True, text=True)

            git("init")
            (root / "example.env").write_text("API_URL=https://example.com\n")
            git("add", "example.env")
            git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-m", "clean fixture")
            self.assertEqual(scan().returncode, 0)
            # Assemble to avoid placing an actual scanner fixture in tracked source.
            fake = "ghp_" + "Ab3Cd4Ef5Gh6Ij7Kl8Mn9Op0Qr1St2Uv3Wx4"
            (root / "example.env").write_text("GITHUB_TOKEN=" + fake + "\n")
            git("add", "example.env")
            staged = scan(staged=True)
            self.assertEqual(staged.returncode, 1)
            self.assertNotIn(fake, staged.stdout + staged.stderr)
            # Unstaged clean contents must not hide a staged leak.
            (root / "example.env").write_text("API_URL=https://example.com\n")
            self.assertEqual(scan(staged=True).returncode, 1)
            git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-m", "synthetic leak")
            git("add", "example.env")
            self.assertEqual(scan(staged=True).returncode, 0)
            git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-m", "remove synthetic leak")
            self.assertEqual(scan().returncode, 1, "removed secrets must still be detected in history")


if __name__ == "__main__":
    unittest.main()
