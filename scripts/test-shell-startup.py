#!/usr/bin/env python3
"""Exercise real Zsh startup in a disposable home; never load personal secrets."""
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ShellStartup(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.home = Path(self.temp.name)
        for name in (".zshrc", ".zshenv", "zsh"):
            (self.home / name).symlink_to(ROOT / "home" / name)
        shims = self.home / ".local/share/mise/shims"
        shims.mkdir(parents=True)
        node = shims / "node"
        node.write_text("#!/bin/sh\nprintf 'mise-node-fixture\\n'\n")
        node.chmod(0o755)
        self.env = {
            "HOME": str(self.home), "ZDOTDIR": str(self.home), "SHELL": "/bin/zsh",
            "PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
            "TERM": "xterm-256color",
        }

    def tearDown(self):
        self.temp.cleanup()

    def shell(self, flag, command):
        return subprocess.run(["/bin/zsh", flag, command], cwd=self.home, env=self.env,
                              capture_output=True, text=True, timeout=45)

    def test_noninteractive_shell_keeps_mise_priority(self):
        result = self.shell("-c", "command -v node; node")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), [str(self.home / ".local/share/mise/shims/node"), "mise-node-fixture"])

    def test_startup_does_not_spawn_brew_shellenv(self):
        result = self.shell("-xc", "true")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("brew shellenv", result.stderr)

    def test_profiler_emits_function_table(self):
        result = self.shell("-ic", "zsh-profile")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Detailed breakdown", result.stdout)
        self.assertIn("calls", result.stdout)
        self.assertNotIn("command not found: zprof", result.stderr)

    def test_sysinfo_does_not_invoke_fetch_tools(self):
        tools = self.home / "bin"
        tools.mkdir()
        for name in ("neofetch", "fastfetch"):
            script = tools / name
            script.write_text("#!/bin/sh\nprintf 'unexpected-fetch-call\\n'\nexit 91\n")
            script.chmod(0o755)
        result = self.shell("-ic", "sysinfo")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("System Information:", result.stdout)
        self.assertNotIn("unexpected-fetch-call", result.stdout)


if __name__ == "__main__":
    unittest.main()
