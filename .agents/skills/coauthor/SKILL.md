---
name: coauthor
description: >-
  Run isolated AI tasks on Ungerfall repositories via ungerfall-coauthored forks,
  including first-use agent bootstrap. Use when the user says /coauthor,
  coauthor task, or sandbox work on a fork.
---
# Coauthor

Run GenAI work on **`ungerfall-coauthored`** forks only.

## Invocation

```text
/coauthor <repo> <intent>
```

- `<repo>`: short name (`dotfiles`) or `Ungerfall/dotfiles`
- `<intent>`: what to implement (free text)

## Preflight (hard stop)

1. `gh api user -q .login` must equal `fork_owner` from [coauthor.config.yaml](../../../coauthor.config.yaml) (`ungerfall-coauthored`). If not: `gh auth switch --user ungerfall-coauthored`.
2. **Forbidden:** `gh pr create` targeting `Ungerfall/*`; `git push` to `github.com/Ungerfall/`; adding upstream as a write remote.
3. Run [scripts/preflight.sh](../../../scripts/preflight.sh) on the sandbox path before push.

## Workflow

1. **Parse** repo → upstream `Ungerfall/<name>` (default owner from config).
2. **Ensure fork:** run [scripts/ensure-fork.sh](../../../scripts/ensure-fork.sh) `<name>`.
3. **Sandbox cwd:** `../sandboxes/<name>/` relative to orchestrator root.
4. **First work:** if [forks.yaml](../../../forks.yaml) lacks `agentic_bootstrapped: true` for this fork, run [scripts/bootstrap-agentic.sh](../../../scripts/bootstrap-agentic.sh) on the sandbox, commit on `coauthor/bootstrap-agentic`, push to fork, update `forks.yaml`.
5. **Task:** create branch `coauthor/<slug-from-intent>`, implement `<intent>`, commit, run preflight, push to fork only.
6. **Update** [forks.yaml](../../../forks.yaml): last branch, commit, task summary, timestamps.

## Branch naming

Use `coauthor/<short-kebab-slug>` derived from intent (max ~40 chars).

## Commit messages

- Bootstrap: `chore(agent): initial agent instructions for sandbox`
- Task: `coauthor: <short summary of intent>`

## Upstream isolation

Also enforced in [agent/rules/coauthor-isolation.md](../../../agent/rules/coauthor-isolation.md).
