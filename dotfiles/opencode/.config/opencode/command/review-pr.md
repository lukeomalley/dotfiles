---
description: Review a GitHub pull request with confidence scoring and validated comments
agent: pr-reviewer
subtask: true
---

Review GitHub pull request #$ARGUMENTS for code quality issues, potential defects, and best practices violations.

This command uses an enhanced review workflow:
1. Fetch the PR using gh CLI and analyze all changed files
2. Generate potential issues with confidence scores (0-100%)
3. Validate each comment with parallel subagent analysis
4. Present approved comments for your selection
5. Post selected comments to GitHub via gh api

Categories detected:
- Critical issues (security, crashes, data loss) - 90%+ confidence
- Bugs (logic errors, edge cases) - 70-90% confidence
- Performance issues - 60-85% confidence
- Code quality / maintainability concerns - 40-70% confidence
- Style nits - 30-50% confidence

Format: Conventional Comments with file:line references and confidence scores.

PR to review: $ARGUMENTS
