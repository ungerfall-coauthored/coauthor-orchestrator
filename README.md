# coauthor-orchestrator

GenAI sandbox orchestrator for the **`ungerfall-coauthored`** GitHub account.

## Upstream isolation

Never open PRs to or push to **`Ungerfall`** upstream. AI work stays on **`ungerfall-coauthored`** forks; promotion to `Ungerfall` is a separate manual step outside this repo.

## Quick start

1. Use the coauthor GitHub account: `gh auth switch --user ungerfall-coauthored`
2. Work from `~/development/ungerfall-coauthored/` (git identity via `includeIf`; see [git.md](../../git.md))
3. In any agent (Cursor, Claude Code, Copilot, etc.), read [AGENTS.md](AGENTS.md) or run **`/coauthor <repo> <intent>`** using [.agents/skills/coauthor/SKILL.md](.agents/skills/coauthor/SKILL.md)

For each PR opened by `/coauthor`, a separate subagent reviews and fixes it,
then merges it into the fork after checks and repository requirements pass.
Unavailable subagents, required human approvals, credentials, or failed checks
are reported as blockers; upstream is never modified.

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
gh repo edit ungerfall-coauthored/coauthor-orchestrator --description "GenAI sandbox orchestrator. Upstream isolation: AI work stays on ungerfall-coauthored forks; no PRs or pushes to Ungerfall upstream."
```

## Smoke-test helper

Forking requires **`repo`** or **`public_repo`** on the coauthor classic PAT.
This helper only makes a marker commit and pushes it; it does not implement the
skill's PR review and merge workflow:

```bash
./scripts/run-coauthor-task.sh dotfiles my-task "your intent here"
```

## Agent-agnostic layout

Skills live under [`.agents/skills/`](.agents/skills/); rules and templates live under [`agent/`](agent/). IDE-specific wiring: [agent/README.md](agent/README.md).
