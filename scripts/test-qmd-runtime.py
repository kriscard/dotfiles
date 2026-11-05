#!/usr/bin/env python3
"""Read-only QMD compatibility smoke test; requires an existing indexed vault.

Runs real QMD under mise Node 26 without inherited asdf paths or credentials.
It queries the database/models but does not rebuild indexes or embeddings.
"""
import json
import os
from pathlib import Path
import subprocess
import unittest

ENV = {
    "HOME": str(Path.home()),
    "PATH": "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin",
    "SHELL": "/bin/zsh",
}
PREFIX = ["/opt/homebrew/bin/mise", "exec", "node@26.12.1", "--"]


class QMDRuntime(unittest.TestCase):
    def invoke(self, *args):
        result = subprocess.run(
            PREFIX + list(args), cwd=Path.home(), env=ENV,
            capture_output=True, text=True, timeout=180,
        )
        self.assertEqual(result.returncode, 0, f"Command failed: {args[0]} (details withheld to protect vault content)")
        return result.stdout

    def test_runtime_and_package_are_mise_owned(self):
        lines = self.invoke("sh", "-c", "command -v node; command -v qmd; node --version; qmd --version").splitlines()
        install = Path.home() / ".local/share/mise/installs/node/26.12.1/bin"
        self.assertEqual(Path(lines[0]).resolve(), (install / "node").resolve())
        self.assertEqual(Path(lines[1]).resolve(), (install / "qmd").resolve())
        self.assertEqual(lines[2], "v26.12.1")
        self.assertTrue(lines[3].startswith("qmd 2.8.3"))

    def test_native_database_opens(self):
        self.invoke("qmd", "status")

    def test_keyword_search_reads_index(self):
        rows = json.loads(self.invoke("qmd", "search", "react", "--json", "-n", "1"))
        self.assertIsInstance(rows, list)
        self.assertGreater(len(rows), 0, "No React results; use an existing indexed vault for this smoke test")

    def test_semantic_retrieval_runs(self):
        rows = json.loads(self.invoke("qmd", "query", "react", "--json", "-n", "1"))
        self.assertIsInstance(rows, list)
        self.assertGreater(len(rows), 0, "No semantic results; indexed vault/models are prerequisites")


if __name__ == "__main__":
    unittest.main()
