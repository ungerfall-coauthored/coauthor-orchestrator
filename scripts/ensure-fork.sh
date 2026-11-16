#!/usr/bin/env bash
# Usage: ensure-fork.sh <repo-name-or-slug>
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

ARG="${1:?repo name required}"
NAME="$(normalize_repo_name "$ARG")"
UP="$(upstream_slug "$NAME")"
FORK="$(fork_slug "$NAME")"
SANDBOX_ROOT="$(resolve_sandbox_root)"
SANDBOX="$SANDBOX_ROOT/$NAME"

require_coauthor_gh

if ! gh repo view "$UP" &>/dev/null; then
  echo "error: upstream not found or not visible: $UP" >&2
  exit 1
fi

if ! gh repo view "$FORK" &>/dev/null; then
  echo "forking $UP -> $FORK"
  gh repo fork "$UP" --clone=false
fi

mkdir -p "$SANDBOX_ROOT"
if [[ ! -d "$SANDBOX/.git" ]]; then
  echo "cloning $FORK -> $SANDBOX"
  gh repo clone "$FORK" "$SANDBOX" --no-upstream
else
  echo "sandbox exists: $SANDBOX"
  git -C "$SANDBOX" fetch origin
fi

python3 "$SCRIPT_DIR/update_forks.py" ensure \
  --orch-root "$ORCH_ROOT" \
  --name "$NAME" \
  --upstream "$UP" \
  --fork "$FORK" \
  --sandbox "$SANDBOX"

echo "ready: $SANDBOX"
