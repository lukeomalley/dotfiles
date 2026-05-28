---
description: Commit and push changes with a conventional commit message
agent: commit-push
subtask: true
---

Commit and push the current changes. Use the ticket number and context from $ARGUMENTS if provided.

Current branch:
!`git branch --show-current`

Current status:
!`git status --porcelain`

Recent commits for style reference:
!`git log --oneline -5`
