---
description: Review a GitHub pull request with two-pass analysis and validated comments
agent: pr-reviewer
subtask: true
---

Review GitHub pull request #$ARGUMENTS for code quality issues, potential defects, and best practices violations.

**CRITICAL REQUIREMENT:** All feedback MUST be posted as inline comments attached to specific lines of code using the `create_pull_request_review` MCP tool with a `comments` array. The review body should ONLY be a brief, high-level summary. NEVER put detailed feedback in the review body.

This command uses a two-pass review workflow:

1. Fetch the PR using GitHub MCP tools (`get_pull_request`, `get_pull_request_files`)
2. **Extract Jira ticket (DEV-XXXX) from PR title** and fetch ticket details via Atlassian MCP
3. **First pass:** Generate ALL potential issues with confidence scores, casting a wide net
4. **Second pass:** Validate each finding with parallel subagents that perform deep codebase research, library doc lookups, and data flow tracing. Each subagent returns APPROVE, REJECT, or REFINE.
5. Present surviving comments in a summary table with process stats (initial findings, rejection rate, confidence trajectories), expandable detail blocks, and recommended verdict
6. **Ask what you want to do** -- post all, post specific ones, adjust comments, or skip
7. Post selected comments as INLINE comments via `create_pull_request_review` MCP tool

**Jira Integration:** If the PR title starts with a Jira ticket (e.g., "DEV-1234 Add user auth"), the reviewer fetches ticket details to understand requirements and acceptance criteria.

Format: Conventional Comments with confidence trajectories (e.g., 90% -> 95%).

PR to review: $ARGUMENTS
