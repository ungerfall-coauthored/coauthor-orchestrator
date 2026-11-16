#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

require_coauthor_gh
REMOTE="https://github.com/$(fork_owner)/coauthor-orchestrator.git"
DESC="GenAI sandbox orchestrator. Upstream isolation: AI work stays on ungerfall-coauthored forks; no PRs or pushes to Ungerfall upstream."

cd "$ORCH_ROOT"
if ! git remote get-url origin &>/dev/null; then
  git remote add origin "$REMOTE"
fi

git push -u origin main
gh repo edit "$(fork_owner)/coauthor-orchestrator" --description "$DESC" 2>/dev/null || \
  echo "Set repo description manually in GitHub UI."

echo "published: $REMOTE"
