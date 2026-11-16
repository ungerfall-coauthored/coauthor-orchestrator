# Agent wiring (IDE-agnostic source of truth)

Canonical files:

- [../AGENTS.md](../AGENTS.md) — start here
- [rules/](rules/) — always-on policies
- [../.agents/skills/](../.agents/skills/) — project-discoverable workflows (`coauthor`, etc.)
- [templates/](templates/) — scaffolds for fork sandboxes

Copilot CLI discovers project skills from `.agents/skills/`; keep skills there.

## Cursor

Optional symlinks from the repo root:

```bash
mkdir -p .cursor
ln -sf ../.agents/skills .cursor/skills
```

Or add `.agents/skills` to your user skill path in Cursor settings.

## Claude Code

Create `CLAUDE.md` at repo root (optional):

```markdown
Read AGENTS.md and follow agent/rules/*.md before making changes.
```

Symlink skills: `ln -sf ../.agents/skills .claude/skills`

## GitHub Copilot

Optional `.github/copilot-instructions.md`:

```markdown
Follow AGENTS.md and agent/rules/coauthor-isolation.md.
```

## Generic

Open the repo and point the agent at **AGENTS.md**.
