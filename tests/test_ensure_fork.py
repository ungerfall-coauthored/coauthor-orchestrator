import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class EnsureForkTests(unittest.TestCase):
    def test_clone_does_not_add_upstream_remote(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "orchestrator"
            scripts = root / "scripts"
            scripts.mkdir(parents=True)
            for name in ("ensure-fork.sh", "lib.sh", "update_forks.py"):
                shutil.copy(ROOT / "scripts" / name, scripts / name)
            (root / "coauthor.config.yaml").write_text(
                "upstream_owner: Ungerfall\n"
                "fork_owner: ungerfall-coauthored\n"
                "sandbox_root: ../sandboxes\n"
            )
            (root / "forks.yaml").write_text("forks: []\n")
            bin_dir = Path(temp) / "bin"
            bin_dir.mkdir()
            gh = bin_dir / "gh"
            gh.write_text(
                "#!/usr/bin/env bash\n"
                "set -eu\n"
                'printf "%s\\n" "$*" >> "$GH_CALLS"\n'
                'if [[ "$1 $2" == "api user" ]]; then echo ungerfall-coauthored; fi\n'
                'if [[ "$1 $2" == "repo clone" ]]; then mkdir -p "$4/.git"; fi\n'
            )
            gh.chmod(0o755)
            calls = Path(temp) / "gh-calls"
            env = os.environ | {"PATH": f"{bin_dir}:{os.environ['PATH']}", "GH_CALLS": str(calls)}

            subprocess.run([str(scripts / "ensure-fork.sh"), "example"], env=env, check=True, capture_output=True, text=True)

            clone = next(line for line in calls.read_text().splitlines() if line.startswith("repo clone ")).split()
            self.assertEqual(clone[:3], ["repo", "clone", "ungerfall-coauthored/example"])
            self.assertEqual(Path(clone[3]).resolve(), Path(temp) / "sandboxes" / "example")
            self.assertEqual(clone[4:], ["--no-upstream"])


if __name__ == "__main__":
    unittest.main()
