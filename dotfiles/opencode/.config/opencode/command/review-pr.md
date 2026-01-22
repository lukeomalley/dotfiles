---
description: Review a GitHub pull request with confidence scoring and validated comments
agent: pr-reviewer
subtask: true
---

Review GitHub pull request #$ARGUMENTS for code quality issues, potential defects, and best practices violations.

**CRITICAL REQUIREMENT:** All feedback MUST be posted as inline comments attached to specific lines of code using the `create_pull_request_review` MCP tool with a `comments` array. The review body should ONLY be a brief, high-level summary (e.g., "Nice work on this! Found a couple things to address."). NEVER put detailed feedback in the review body - it MUST go in inline comments.

This command uses an enhanced review workflow with Jira integration:
1. Fetch the PR using GitHub MCP tools (`get_pull_request`, `get_pull_request_files`)
2. **Extract Jira ticket (DEV-XXXX) from PR title and fetch ticket details via Atlassian MCP**
3. Generate potential issues with confidence scores (0-100%), using Jira context to understand intent
4. Validate each comment with parallel subagent analysis
5. Present approved comments for your selection
6. Post selected comments as INLINE comments via `create_pull_request_review` MCP tool with a `comments` array
7. Include a brief, friendly summary in the review body (just 1-2 sentences)

**Jira Integration:** The PR title must start with a Jira ticket number (e.g., "DEV-1234 Add user authentication"). The reviewer will fetch the ticket details to understand requirements, acceptance criteria, and context for a more informed review.

Categories detected:
- Critical issues (security, crashes, data loss) - 90%+ confidence
- Bugs (logic errors, edge cases) - 70-90% confidence
- Performance issues - 60-85% confidence
- Code quality / maintainability concerns - 40-70% confidence
- Requirements alignment (Jira ticket mismatch) - 50-80% confidence
- Style nits - 30-50% confidence

Format: Conventional Comments with file:line references and confidence scores.

PR to review: $ARGUMENTS
