---
description: Create a pull request with conventional commit style title
agent: pr-creator
subtask: true
---

Create a pull request for the current branch. $ARGUMENTS

Current branch:
!`git branch --show-current`

Git status:
!`git status --porcelain`

Recent commits on this branch:
!`git log --oneline -10`

Staged diff stats:
!`git diff --cached --stat`
