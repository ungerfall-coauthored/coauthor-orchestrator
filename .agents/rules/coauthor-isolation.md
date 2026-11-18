# Coauthor upstream isolation

This sandbox is GenAI-owned work on a **fork** under `ungerfall-coauthored`. The upstream account **`Ungerfall` must never receive AI-driven git changes**.

## Forbidden

- Opening pull requests into `Ungerfall/*`
- `git push` to any remote URL containing `github.com/Ungerfall/`
- Adding `Ungerfall/*` as a push remote (`git remote add` / `set-url` toward upstream for write)
- `gh pr create` with base repo `Ungerfall/*`

## Allowed

- Read upstream as reference (web, local read-only clone elsewhere)
- Push branches to `ungerfall-coauthored/<this-fork>`
- Commits on branches named `coauthor/*` (convention)

## Human promotion

Copying changes into `Ungerfall` is **manual** and **outside** this pipeline (cherry-pick, re-implement, or new human-authored commits).
