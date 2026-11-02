#!/usr/bin/env bash
# Usage: bootstrap-agentic.sh <sandbox-path>
# Creates agent files only when missing. Does not overwrite existing AGENTS.md.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

SANDBOX="${1:?sandbox path required}"
TEMPLATES="$ORCH_ROOT/agent/templates"

if [[ ! -d "$SANDBOX/.git" ]]; then
  echo "error: not a git repo: $SANDBOX" >&2
  exit 1
fi

require_coauthor_gh

REPO_DESC="Sandbox fork for GenAI work (see agent/rules/coauthor-isolation.md)."
LAYOUT=""
CMDS="(none detected — add build/test commands here)"

if [[ -f "$SANDBOX/README.md" ]]; then
  REPO_DESC="See README.md. GenAI sandbox fork under ungerfall-coauthored."
fi

if [[ -f "$SANDBOX/package.json" ]]; then
  CMDS=$'- npm install\n- npm test (if defined)\n- npm run build (if defined)'
  LAYOUT="Node.js project (package.json at root)."
elif [[ -f "$SANDBOX/pyproject.toml" ]]; then
  CMDS=$'- pip install -e .\n- pytest (if configured)'
  LAYOUT="Python project (pyproject.toml at root)."
elif [[ -f "$SANDBOX/go.mod" ]]; then
  CMDS=$'- go test ./...\n- go build ./...'
  LAYOUT="Go module at root."
elif [[ -f "$SANDBOX/Cargo.toml" ]]; then
  CMDS=$'- cargo test\n- cargo build'
  LAYOUT="Rust crate at root."
else
  LAYOUT="Inspect repository root for source layout."
fi

mkdir -p "$SANDBOX/agent/rules" "$SANDBOX/agent/skills"

if [[ ! -f "$SANDBOX/agent/rules/coauthor-isolation.md" ]]; then
  cp "$TEMPLATES/coauthor-isolation.md" "$SANDBOX/agent/rules/coauthor-isolation.md"
  echo "added agent/rules/coauthor-isolation.md"
fi

if [[ ! -f "$SANDBOX/AGENTS.md" ]]; then
  python3 - "$TEMPLATES/AGENTS.stub.md" "$SANDBOX/AGENTS.md" "$REPO_DESC" "$LAYOUT" "$CMDS" <<'PY'
import sys
from pathlib import Path
stub, out, desc, layout, cmds = sys.argv[1:6]
text = Path(stub).read_text()
text = text.replace("{{REPO_DESCRIPTION}}", desc)
text = text.replace("{{LAYOUT_NOTES}}", layout)
text = text.replace("{{COMMANDS}}", cmds)
Path(out).write_text(text)
PY
  echo "added AGENTS.md"
else
  echo "skip AGENTS.md (already exists)"
fi

if [[ ! -f "$SANDBOX/.github/copilot-instructions.md" ]]; then
  mkdir -p "$SANDBOX/.github"
  printf '%s\n' 'Follow AGENTS.md and agent/rules/coauthor-isolation.md.' \
    > "$SANDBOX/.github/copilot-instructions.md"
  echo "added .github/copilot-instructions.md"
fi

if [[ ! -f "$SANDBOX/CLAUDE.md" ]]; then
  printf '%s\n' 'Read AGENTS.md and agent/rules/*.md before making changes.' \
    > "$SANDBOX/CLAUDE.md"
  echo "added CLAUDE.md"
fi

echo "bootstrap-agentic done (review git status in sandbox)"
