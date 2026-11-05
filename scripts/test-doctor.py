#!/usr/bin/env python3
"""Exercise the real CLI against controlled external tool availability/results."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

CLI = Path(__file__).resolve().parents[1] / "dotfiles"


class Doctor(unittest.TestCase):
    def run_doctor(self, missing=(), brew_mode="healthy", shell="/bin/zsh"):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for name, target in {"dirname": "/usr/bin/dirname", "head": "/usr/bin/head", "sed": "/usr/bin/sed"}.items():
                (root / name).symlink_to(target)
            for name in ("git", "curl", "zsh", "stow"):
                if name not in missing:
                    tool = root / name
                    tool.write_text("#!/bin/sh\nexit 0\n")
                    tool.chmod(0o755)
            if "brew" not in missing:
                brew = root / "brew"
                brew.write_text('''#!/bin/sh
case "$1" in
--version) echo 'Homebrew test';;
outdated)
  case "$BREW_MODE" in
  outdated) echo 'example-package';;
  error) echo 'simulated metadata failure' >&2; exit 2;;
  esac;;
esac
''')
                brew.chmod(0o755)
            env = dict(os.environ, HOME=tmp, PATH=tmp, SHELL=shell, BREW_MODE=brew_mode)
            return subprocess.run(["/bin/bash", str(CLI), "doctor", "--verbose"], env=env, capture_output=True, text=True)

    def test_healthy(self):
        result = self.run_doctor()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("System health check passed", result.stdout)

    def test_missing_tools_are_aggregated_and_fail(self):
        result = self.run_doctor(missing=("git", "stow"))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git is not installed", result.stdout + result.stderr)
        self.assertIn("stow is not installed", result.stdout + result.stderr)
        self.assertNotIn("System health check passed", result.stdout)

    def test_brew_query_failure_is_not_healthy(self):
        result = self.run_doctor(brew_mode="error")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Could not check Homebrew", result.stdout + result.stderr)
        self.assertNotIn("All packages are up to date", result.stdout)

    def test_missing_brew_fails(self):
        self.assertNotEqual(self.run_doctor(missing=("brew",)).returncode, 0)

    def test_outdated_packages_and_other_shell_are_warnings(self):
        result = self.run_doctor(brew_mode="outdated", shell="/bin/bash")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("example-package", result.stdout)
        self.assertIn("Not using zsh", result.stdout)
        self.assertIn("warning", result.stdout.lower())

    def test_restore_is_not_advertised(self):
        help_result = subprocess.run(["/bin/bash", str(CLI), "help"], capture_output=True, text=True)
        self.assertNotIn("restore", help_result.stdout)
        result = subprocess.run(["/bin/bash", str(CLI), "restore"], capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unknown command", result.stderr)


if __name__ == "__main__":
    unittest.main()
