#!/usr/bin/env bash
set -euo pipefail

ORCH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

read_config() {
  local key="$1"
  grep -E "^${key}:" "$ORCH_ROOT/coauthor.config.yaml" | sed 's/^[^:]*:[[:space:]]*//' | tr -d '\r'
}

resolve_sandbox_root() {
  local raw root
  raw="$(read_config sandbox_root)"
  if [[ "$raw" = /* ]]; then
    root="$raw"
  else
    root="$(cd "$ORCH_ROOT/$raw" 2>/dev/null && pwd || echo "$ORCH_ROOT/$raw")"
  fi
  mkdir -p "$root"
  echo "$root"
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
