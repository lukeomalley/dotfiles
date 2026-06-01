---
name: commit-and-push
description: Review uncommitted git changes, create a conventional commit, and push the current branch to origin. Use when the user asks to commit and push, save changes to git, or finish a git workflow without creating a pull request.
---

# Commit and Push

You are a fast, careful git workflow assistant. When this skill is invoked, user approval to commit and push is implied unless a risk check fails.

## Fast Path

Commit and push without asking for confirmation when all of these are true:

- The repository is on a normal branch, not detached HEAD.
- A remote named `origin` exists.
- Changes are cohesive and appear intentional.
- No suspicious secrets, credentials, local-only files, caches, or generated junk are being added.
- There are no merge conflicts, rebase states, or unresolved index entries.
- The push can be completed without force pushing.

If any condition fails, stop before committing or pushing, explain the issue, and ask the user how to proceed.

## Git State Checks

Start with:

```bash
git branch --show-current
git status --short --branch
git remote -v
git rev-parse --abbrev-ref --symbolic-full-name @{u}
```

If upstream lookup fails, continue with the workflow, but use `git push -u origin HEAD` after committing.

Do not block solely because the current branch is `main` or another default branch if the user explicitly invoked this skill. Do block if repo instructions prohibit direct pushes, the branch is protected, or the push is rejected.

## Review Changes

Use summary commands first:

```bash
git status --short
git diff --stat
git diff --name-status
git diff --staged --stat
git diff --staged --name-status
git ls-files --others --exclude-standard
```

Then inspect targeted diffs as needed:

```bash
git diff -- path/to/file
git diff --staged -- path/to/file
```

For untracked text files, inspect enough content to understand whether they should be committed.

## Risk Checks

Stop before staging if changes include likely accidental files, such as:

- `.env`, `.env.*`, credentials, tokens, private keys, certificates, or auth cookies.
- Large binary files not clearly intended.
- Logs, caches, coverage output, build artifacts, temp files, or editor swap files.
- Personal machine state that should not live in the repository.
- Unrelated changes that should be split into a separate commit.

Never commit secrets. Never update git config such as `user.name` or `user.email`.

## Commit Message

Write a Conventional Commit message:

```text
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

Use one of these types:

- `feat`: new feature
- `fix`: bug fix
- `docs`: documentation only
- `style`: formatting or whitespace only
- `refactor`: code change that is neither feature nor fix
- `perf`: performance improvement
- `test`: tests added or corrected
- `build`: build system or dependency changes
- `ci`: CI configuration
- `chore`: maintenance that does not modify source or tests

Rules:

- Use imperative mood: `add`, not `added`.
- Do not capitalize the first word of the description.
- Do not end the description with a period.
- Keep the subject under 72 characters.
- Avoid vague subjects like `chore: update files`.
- Use a body when the diff contains multiple meaningful changes.
- Mention checks only if they were actually run.
- For breaking changes, add `!` after type/scope and include a `BREAKING CHANGE:` footer.

Never add attribution, tool watermarks, AI authorship, or co-author trailers. Never use `git commit --trailer` or any trailer flag.

## Stage, Commit, Push

Stage intentionally. Use `git add -A` only when all uncommitted changes belong in the commit. Otherwise stage specific files.

Commit with the chosen message:

```bash
git commit -m "<subject>"
```

For commits that need a body:

```bash
git commit -m "<subject>" -m "<body>"
```

Push:

```bash
git push
```

If the branch has no upstream:

```bash
git push -u origin HEAD
```

Never force push without explicit user approval.

## Failure Handling

- If commit fails because there is nothing staged, re-check status and report clearly.
- If hooks fail, report the hook output and do not bypass hooks unless the user explicitly approves.
- If push fails because the branch is behind, stop and explain whether pull, rebase, or merge is appropriate.
- If push fails because the branch is protected, stop and explain that a PR or different branch is needed.

## Final Response

After success, report:

- Branch name
- Commit hash
- Commit message
- Push destination
- Any checks run or explicitly skipped
