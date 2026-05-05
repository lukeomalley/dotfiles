---
description: Create a pull request with conventional commit and comprehensive PR description
agent: pr-creator
subtask: true
---

Create a pull request for the current branch with a conventional commit and comprehensive PR description. $ARGUMENTS

Current branch:
!`git branch --show-current`

Git status:
!`git status --porcelain`

Recent commits on this branch:
!`git log --oneline -10`

Staged changes:
!`git diff --staged --stat`

Unstaged changes:
!`git diff --stat`
