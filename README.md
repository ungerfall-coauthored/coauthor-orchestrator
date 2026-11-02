# coauthor-orchestrator

GenAI sandbox orchestrator for the **`ungerfall-coauthored`** GitHub account.

> **Divine rule #1:** Never PR or push to **`Ungerfall`** upstream. All AI work stays on **`ungerfall-coauthored`** forks. Human promotion to `Ungerfall` is manual and outside this repo.

## Quick start

1. Use the coauthor GitHub account: `gh auth switch --user ungerfall-coauthored`
2. Work from `~/development/ungerfall-coauthored/` (git identity via `includeIf`; see [git.md](../../git.md))
3. In any agent (Cursor, Claude Code, Copilot, etc.), read [AGENTS.md](AGENTS.md) or run **`/coauthor <repo> <intent>`** using [agent/skills/coauthor/SKILL.md](agent/skills/coauthor/SKILL.md)

## Scripts

```bash
./scripts/ensure-fork.sh dotfiles          # fork + clone if needed
./scripts/preflight.sh ../sandboxes/dotfiles
./scripts/bootstrap-agentic.sh ../sandboxes/dotfiles
```

## Registry

Tracked forks: [forks.yaml](forks.yaml)

## Publish orchestrator (one-time)

If `gh repo create` returns **403**, refresh the coauthor token ([docs/github-token-scopes.md](docs/github-token-scopes.md)), create an empty **`coauthor-orchestrator`** repo on GitHub, then:

```bash
git remote add origin https://github.com/ungerfall-coauthored/coauthor-orchestrator.git
git push -u origin main
gh repo edit ungerfall-coauthored/coauthor-orchestrator --description "GenAI sandbox orchestrator. Divine rule #1: never PR or push to Ungerfall upstream—all AI work stays on ungerfall-coauthored forks."
```

## First fork push

Forking requires **`repo`** or **`public_repo`** on the coauthor classic PAT. Then:

```bash
./scripts/run-coauthor-task.sh dotfiles my-task "your intent here"
```

## Agent-agnostic layout

Skills and rules live under [`agent/`](agent/). IDE-specific wiring: [agent/README.md](agent/README.md).
