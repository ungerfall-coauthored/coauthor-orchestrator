# Coauthor orchestrator

**Upstream isolation:** Never open PRs or push to `Ungerfall/*`. All GenAI git work stays on `ungerfall-coauthored` forks.

## Invoke

Use the portable skill at [.agents/skills/coauthor/SKILL.md](.agents/skills/coauthor/SKILL.md):

```text
/coauthor <repo> <intent>
```

Example: `/coauthor dotfiles add a note in README that this fork is a GenAI sandbox`

The skill opens fork-only PRs and delegates each PR's review, fixes, and merge
to a separate subagent. It reports blockers rather than bypassing protections.

## Validation and release gates

Follow the skill's **Integration and release gates** before any push, PR, or
merge affecting external-service behavior. Relevant live tests must exercise
the actual application client and pass; offline-only CI, skipped tests, missing
credentials, or unconfigured deployments do not satisfy this requirement.
Keep blocked work local. Verify hosted configuration before an automatic
release, and honor publication/deployment holds until explicit release approval.

## Canonical config

| Path | Role |
|------|------|
| [.agents/rules/coauthor-isolation.md](.agents/rules/coauthor-isolation.md) | Isolation rules |
| [.agents/skills/coauthor/SKILL.md](.agents/skills/coauthor/SKILL.md) | Full workflow |
| [coauthor.config.yaml](coauthor.config.yaml) | Owners and sandbox paths |
| [forks.yaml](forks.yaml) | Fork registry |
| [scripts/](scripts/) | `ensure-fork.sh`, `preflight.sh`, `bootstrap-agentic.sh` |

## Sandboxes

Fork clones live under `../sandboxes/<repo-name>/` (see [coauthor.config.yaml](coauthor.config.yaml)).

## Human git setup

Two-account `gh` and git identity: [git.md](../../git.md) in the parent development folder (or your local copy).
