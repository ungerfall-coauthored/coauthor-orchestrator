import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class BootstrapAgenticTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name)
        self.sandbox = root / "sandbox"
        (self.sandbox / ".git").mkdir(parents=True)
        bin_dir = root / "bin"
        bin_dir.mkdir()
        gh = bin_dir / "gh"
        gh.write_text(
            "#!/bin/sh\n"
            '[ "$*" = "api user -q .login" ] || exit 1\n'
            "echo ungerfall-coauthored\n"
        )
        gh.chmod(0o755)
        self.env = os.environ | {"PATH": f"{bin_dir}:{os.environ['PATH']}"}

    def bootstrap(self):
        subprocess.run(
            [str(ROOT / "scripts" / "bootstrap-agentic.sh"), str(self.sandbox)],
            env=self.env, check=True, capture_output=True, text=True,
        )

    def test_scaffold_uses_hidden_layout_and_explicit_rule_references(self):
        self.bootstrap()

        rule = ".agents/rules/coauthor-isolation.md"
        self.assertEqual(
            (ROOT / ".agents" / "templates" / "coauthor-isolation.md").read_bytes(),
            (self.sandbox / rule).read_bytes(),
        )
        self.assertTrue((self.sandbox / ".agents" / "skills").is_dir())
        self.assertFalse((self.sandbox / "agent").exists())
        for entrypoint, reference in (
            ("AGENTS.md", rule),
            (".github/copilot-instructions.md", rule),
            ("CLAUDE.md", ".agents/rules/*.md"),
        ):
            with self.subTest(entrypoint=entrypoint):
                self.assertIn(reference, (self.sandbox / entrypoint).read_text())

    def test_bootstrap_preserves_existing_instructions_rules_and_skills(self):
        existing = {
            "AGENTS.md": "Custom repository instructions\n",
            "CLAUDE.md": "Custom Claude instructions\n",
            ".github/copilot-instructions.md": "Custom Copilot instructions\n",
            ".agents/rules/coauthor-isolation.md": "Custom isolation policy\n",
            ".agents/skills/custom/SKILL.md": "Custom skill\n",
        }
        for name, content in existing.items():
            path = self.sandbox / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content)

        self.bootstrap()
        self.bootstrap()

        actual = {
            path.relative_to(self.sandbox).as_posix(): path.read_text()
            for path in self.sandbox.rglob("*") if path.is_file()
        }
        self.assertEqual(existing, actual)
        self.assertFalse((self.sandbox / "agent").exists())


if __name__ == "__main__":
    unittest.main()
