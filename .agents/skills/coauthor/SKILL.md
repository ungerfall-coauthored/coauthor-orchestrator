---
name: coauthor
description: >-
  Run isolated AI tasks on Ungerfall repositories via ungerfall-coauthored forks,
  including bootstrap and autonomous PR review, fixes, and merge. Use when the
  user says /coauthor, coauthor task, or sandbox work on a fork.
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
4. **First work:** if [forks.yaml](../../../forks.yaml) lacks `agentic_bootstrapped: true` for this fork, create `coauthor/bootstrap-agentic` from the fork's current default branch, run [scripts/bootstrap-agentic.sh](../../../scripts/bootstrap-agentic.sh), commit, run preflight, push to the fork, and update `forks.yaml`. Include this bootstrap commit in the task PR if it is not already on the default branch. Do not mark the fork bootstrapped before a successful push.
5. **Task:** start `coauthor/<slug-from-intent>` from the current fork default branch, including any unmerged bootstrap commit. Implement `<intent>`, run appropriate checks, commit, run preflight, and push to the fork only. Preserve existing work and do not overwrite branches.
6. **PR and landing:** open a PR in the fork against its default branch, then follow **PR review and merge** below. This applies to every PR opened during the invocation, including a copied PR or bootstrap PR, not only the main task PR. Complete each PR's review and merge before opening the next one; when another task branch depends on a merged PR, base it on the updated fork branch.
7. **Update** [forks.yaml](../../../forks.yaml) with the final task branch, its final reviewed head commit, task summary, and timestamp. Report the PR URL and verified merge commit, or the exact blocker if it could not be merged.

## PR review and merge

Invoking `/coauthor` requests merging the fork-only PRs opened for that
invocation. Do not merge unrelated pre-existing PRs without a separate request.

Immediately after opening each PR, start one separate, full-capability subagent
to review that PR, fix its findings, and merge it. In Copilot CLI, use a
`general-purpose` subagent; a read-only review agent cannot complete this job.
Give it the fork slug, PR number, task intent, sandbox path, expected head and
base, preflight command, and all isolation rules. Do not create another PR for
its fixes or recursively delegate another reviewer. Wait for it to finish
before changing the same branch or proceeding to the next PR.

Instruct the subagent to:

1. Verify the active GitHub identity, fork repository, PR base and head, and
   sandbox remotes. Review the complete PR diff against its current base,
   including correctness, regressions, relevant security concerns, tests, and
   any applicable repository instructions. Use the applicable merge or stack
   skill before merging.
2. Fix actionable findings on the PR branch, preserving unrelated work. Run
   appropriate tests and checks, commit fixes with required trailers, run
   preflight, and push only to the fork. Re-review the final diff and repeat
   until no actionable findings remain; do not claim a clean review if blocked.
3. Wait for configured PR checks and repository requirements. Fix failures
   caused by the PR, then re-review and revalidate the final head. Verify the
   head and base have not changed since review; if either changes, review the
   new diff and checks again.
4. Merge only into the verified fork base, using a repository-permitted merge
   method and a head-SHA guard such as `gh pr merge --match-head-commit SHA`.
   Respect branch protection, required reviews, and merge queues; never use
   admin bypass or force-push. Preserve the task branch unless deletion is
   explicitly requested. Verify the PR is actually merged and return its URL,
   final head, merge commit, findings/fixes, checks, and any blocker.

If subagents are unavailable, required checks fail, permissions or protections
prevent merging, or safe progress needs human-owned resources or credentials,
stop and report the blocker. Do not silently substitute self-review, bypass
protections, or claim success while a merge is pending. Do not request secrets
in chat. If there are no configured PR checks, merge only after the applicable
local validation passes and all repository requirements are satisfied.

## Branch naming

Use `coauthor/<short-kebab-slug>` derived from intent (max ~40 chars).

## Commit messages

- Bootstrap: `chore(agent): initial agent instructions for sandbox`
- Task: `coauthor: <short summary of intent>`

## Upstream isolation

Also enforced in [agent/rules/coauthor-isolation.md](../../../agent/rules/coauthor-isolation.md).
