#!/usr/bin/env bash
# Usage: run-coauthor-task.sh <repo-name> <branch-slug> <task-summary> [-- bootstrap-only]
# Applies a minimal task commit for smoke tests / automation hooks.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

NAME="$(normalize_repo_name "${1:?repo}")"
BRANCH_SLUG="${2:?branch slug}"
TASK="${3:?task summary}"
MODE="${4:-}"

SANDBOX_ROOT="$(resolve_sandbox_root)"
SANDBOX="$SANDBOX_ROOT/$NAME"
BRANCH="coauthor/$BRANCH_SLUG"

"$SCRIPT_DIR/ensure-fork.sh" "$NAME"

# Bootstrap on first use
BOOTSTRAPPED="false"
if python3 "$SCRIPT_DIR/update_forks.py" is-bootstrapped \
  --orch-root "$ORCH_ROOT" --name "$NAME" 2>/dev/null; then
  BOOTSTRAPPED="true"
fi

if [[ "$BOOTSTRAPPED" != "true" || "$MODE" == "--bootstrap-only" ]]; then
  "$SCRIPT_DIR/bootstrap-agentic.sh" "$SANDBOX"
  git -C "$SANDBOX" checkout -B coauthor/bootstrap-agentic 2>/dev/null || git -C "$SANDBOX" checkout coauthor/bootstrap-agentic
  git -C "$SANDBOX" add AGENTS.md agent .github/copilot-instructions.md CLAUDE.md 2>/dev/null || true
  if ! git -C "$SANDBOX" diff --cached --quiet; then
    git -C "$SANDBOX" commit -m "chore(agent): initial agent instructions for sandbox"
    "$SCRIPT_DIR/preflight.sh" "$SANDBOX"
    git -C "$SANDBOX" push -u origin coauthor/bootstrap-agentic
  fi
  python3 "$SCRIPT_DIR/update_forks.py" mark-bootstrapped --orch-root "$ORCH_ROOT" --name "$NAME"
fi

if [[ "$MODE" == "--bootstrap-only" ]]; then
  echo "bootstrap-only complete"
  exit 0
fi

git -C "$SANDBOX" fetch origin
git -C "$SANDBOX" checkout -B "$BRANCH" origin/HEAD 2>/dev/null || git -C "$SANDBOX" checkout -B "$BRANCH"

MARKER="$SANDBOX/.coauthor-last-task.txt"
printf '%s\n' "$TASK" > "$MARKER"
git -C "$SANDBOX" add "$MARKER"
git -C "$SANDBOX" commit -m "coauthor: $TASK"
"$SCRIPT_DIR/preflight.sh" "$SANDBOX"
git -C "$SANDBOX" push -u origin "$BRANCH"

COMMIT="$(git -C "$SANDBOX" rev-parse HEAD)"
python3 "$SCRIPT_DIR/update_forks.py" update-task \
  --orch-root "$ORCH_ROOT" \
  --name "$NAME" \
  --branch "$BRANCH" \
  --commit "$COMMIT" \
  --task "$TASK"

echo "task pushed: $(fork_slug "$NAME") branch $BRANCH ($COMMIT)"
