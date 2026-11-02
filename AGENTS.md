# Coauthor orchestrator

**Divine rule #1:** Never open PRs or push to `Ungerfall/*`. All GenAI git work stays on `ungerfall-coauthored` forks.

## Invoke

Use the portable skill at [agent/skills/coauthor/SKILL.md](agent/skills/coauthor/SKILL.md):

```text
/coauthor <repo> <intent>
```

Example: `/coauthor dotfiles add a note in README that this fork is a GenAI sandbox`

## Canonical config

| Path | Role |
|------|------|
| [agent/rules/coauthor-isolation.md](agent/rules/coauthor-isolation.md) | Isolation rules |
| [agent/skills/coauthor/SKILL.md](agent/skills/coauthor/SKILL.md) | Full workflow |
| [coauthor.config.yaml](coauthor.config.yaml) | Owners and sandbox paths |
| [forks.yaml](forks.yaml) | Fork registry |
| [scripts/](scripts/) | `ensure-fork.sh`, `preflight.sh`, `bootstrap-agentic.sh` |

## Sandboxes

Fork clones live under `../sandboxes/<repo-name>/` (see [coauthor.config.yaml](coauthor.config.yaml)).

## Human git setup

Two-account `gh` and git identity: [git.md](../../git.md) in the parent development folder (or your local copy).
