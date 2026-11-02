# GitHub token scopes (ungerfall-coauthored)

The coauthor account PAT used with `gh auth login` must allow:

| Action | Scope / permission |
|--------|---------------------|
| Create `coauthor-orchestrator` | **Classic:** `repo` (or create repo in browser, then push with `repo` Contents) |
| Fork public `Ungerfall/*` | **Classic:** `public_repo` or full `repo` |
| Push to own forks | **Contents** read/write on repositories owned by `ungerfall-coauthored` |

Fine-grained PATs: enable **Contents** (read/write) and **Metadata** for repositories owned by this account; for forking, use a **classic PAT** with `public_repo` or `repo`, or create forks manually on github.com.

After updating the token:

```bash
gh auth login --hostname github.com --user ungerfall-coauthored
gh auth refresh -h github.com -s repo
```

Create the orchestrator repo in the browser if `gh repo create` returns 403:

1. New repository → name `coauthor-orchestrator` → private → create empty.
2. From this directory:

   ```bash
   git remote add origin https://github.com/ungerfall-coauthored/coauthor-orchestrator.git
   git push -u origin main
   gh repo edit --description "GenAI sandbox orchestrator. Divine rule #1: never PR or push to Ungerfall upstream—all AI work stays on ungerfall-coauthored forks."
   ```
