# Agent wiring (IDE-agnostic source of truth)

Canonical files:

- [../AGENTS.md](../AGENTS.md) — start here
- [rules/](rules/) — always-on policies
- [skills/](skills/) — workflows (`coauthor`, etc.)
- [templates/](templates/) — scaffolds for fork sandboxes

## Cursor

Optional symlinks from the repo root:

```bash
mkdir -p .cursor
ln -sf ../agent/skills .cursor/skills
```

Or add `agent/skills` to your user skill path in Cursor settings.

## Claude Code

Create `CLAUDE.md` at repo root (optional):

```markdown
Read AGENTS.md and follow agent/rules/*.md before making changes.
```

Symlink skills: `ln -sf agent/skills .claude/skills`

## GitHub Copilot

Optional `.github/copilot-instructions.md`:

```markdown
Follow AGENTS.md and agent/rules/coauthor-isolation.md.
```

## Generic

Open the repo and point the agent at **AGENTS.md**.
