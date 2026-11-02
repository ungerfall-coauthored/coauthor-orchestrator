#!/usr/bin/env bash
set -euo pipefail

ORCH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

read_config() {
  local key="$1"
  grep -E "^${key}:" "$ORCH_ROOT/coauthor.config.yaml" | sed 's/^[^:]*:[[:space:]]*//' | tr -d '\r'
}

resolve_sandbox_root() {
  local raw
  raw="$(read_config sandbox_root)"
  if [[ "$raw" = /* ]]; then
    echo "$raw"
  else
    echo "$(cd "$ORCH_ROOT/$raw" && pwd)"
  fi
}

upstream_owner() { read_config upstream_owner; }
fork_owner() { read_config fork_owner; }

require_coauthor_gh() {
  local want got
  want="$(fork_owner)"
  got="$(gh api user -q .login 2>/dev/null || true)"
  if [[ "$got" != "$want" ]]; then
    echo "error: active gh user is '$got', need '$want' (gh auth switch --user $want)" >&2
    exit 1
  fi
}

normalize_repo_name() {
  local arg="$1"
  if [[ "$arg" == */* ]]; then
    echo "${arg##*/}"
  else
    echo "$arg"
  fi
}

upstream_slug() {
  local name="$1"
  echo "$(upstream_owner)/$name"
}

fork_slug() {
  local name="$1"
  echo "$(fork_owner)/$name"
}
