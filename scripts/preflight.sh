#!/usr/bin/env bash
# Usage: preflight.sh <sandbox-path>
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

SANDBOX="${1:?sandbox path required}"
require_coauthor_gh

if [[ ! -d "$SANDBOX/.git" ]]; then
  echo "error: not a git repo: $SANDBOX" >&2
  exit 1
fi

FORBIDDEN_OWNER="$(upstream_owner)"
while IFS= read -r url; do
  [[ -z "$url" ]] && continue
  if [[ "$url" == *"github.com/${FORBIDDEN_OWNER}/"* ]]; then
    echo "error: remote URL points at forbidden upstream: $url" >&2
    exit 1
  fi
done < <(git -C "$SANDBOX" remote -v | awk '{print $2}' | sort -u)

want="$(fork_owner)"
if ! git -C "$SANDBOX" remote get-url origin 2>/dev/null | grep -q "github.com/${want}/"; then
  echo "error: origin must be ${want}/* fork" >&2
  git -C "$SANDBOX" remote -v >&2 || true
  exit 1
fi

echo "preflight ok: $SANDBOX"
