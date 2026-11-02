#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

require_coauthor_gh
REMOTE="https://github.com/$(fork_owner)/coauthor-orchestrator.git"
DESC="GenAI sandbox orchestrator. Divine rule #1: never PR or push to Ungerfall upstream—all AI work stays on ungerfall-coauthored forks."

cd "$ORCH_ROOT"
if ! git remote get-url origin &>/dev/null; then
  git remote add origin "$REMOTE"
fi

git push -u origin main
gh repo edit "$(fork_owner)/coauthor-orchestrator" --description "$DESC" 2>/dev/null || \
  echo "Set repo description manually in GitHub UI."

echo "published: $REMOTE"
