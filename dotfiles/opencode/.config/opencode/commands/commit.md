---
description: Create a conventional commit and push changes to origin
agent: commit-push
subtask: true
---

Review uncommitted changes, write a conventional commit message, and push to origin. $ARGUMENTS

Current git status:
!`git status --porcelain`

Current branch:
!`git branch --show-current`

Staged changes:
!`git diff --staged --stat`

Unstaged changes:
!`git diff --stat`
