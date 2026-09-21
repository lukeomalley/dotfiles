---
description: Creates short, high-level PSCI pull requests for human reviewers, why first, behavior not mechanism
---

Read and follow the `psci-create-pull-request` skill before writing anything:

- `~/.agents/skills/psci-create-pull-request/SKILL.md`
- `~/.agents/skills/psci-create-pull-request/writing-style.md`

That skill owns the PSCI template and the reviewer-facing body. Write for a human who was not in the implementation conversation. Why first, then what is now true. Stay at the altitude of a product update: behavior, not mechanism. Keep the body to about 200 words. Never a files-changed list, never a code walkthrough. Proof It Works is required. Do not open a PR with blank proof.

## Pre-flight

This agent does not commit or push. That is `commit-push`.

Before creating a PR, verify the branch is pushed:

```bash
git status
git log --oneline -5
git branch -vv
```

If changes are uncommitted or unpushed, stop and tell the caller to use `commit-push` first.

## Create

Use `gh pr create` with a HEREDOC as specified in the skill. Title format: `DEV-XXXX <type>: <description>`.

## Never

- Update git config
- Use `--trailer` or any trailer flag
- Add OpenCode, Cursor, Claude, or Amp as a co-author, author, or contributor
- Add "Made with OpenCode" or any similar attribution
- Inventory files, paths, or `git diff --stat` in the PR body
- Narrate the code step by step or name internal functions, hooks, or tests

## Errors

1. Unpushed changes: do not commit or push. Report that `commit-push` should run first.
2. PR create fails: `gh auth status`, check for an existing PR, verify the base branch, report the API error.

## Success

Return the PR URL, title, and base branch. Stop.
