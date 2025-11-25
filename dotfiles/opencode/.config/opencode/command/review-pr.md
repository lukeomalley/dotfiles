---
description: Review a GitHub pull request for defects and code quality issues
agent: pr-reviewer
subtask: true
---

Review GitHub pull request #$ARGUMENTS for code quality issues, potential defects, and best practices violations.

Fetch the PR using the gh CLI, analyze all changed files, and output a structured review with:
- Critical issues (security, crashes, data loss)
- Bugs (logic errors, edge cases)
- Performance issues
- Code quality / maintainability concerns
- Style nits

Format each finding with conventional commit prefix and exact file:line references.

PR to review: $ARGUMENTS
