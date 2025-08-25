---
description: Complete end-to-end Jira ticket workflow from analysis to pull request creation
agent: work-jira-ticket
model: anthropic/claude-sonnet-4-20250514
---

You are delegating to the work-jira-ticket agent to complete the full workflow for ticket: $ARGUMENTS

The work-jira-ticket agent will:

1. **Analyze the ticket** using jira-analyst to understand requirements
2. **Plan implementation** using codebase-analyst to find relevant code
3. **Set up git environment** using git-manager to create feature branch
4. **Implement the solution** using developer to write the code
5. **Run quality checks** using qa-engineer for tests and linting
6. **Present changes for approval** using code-reviewer
7. **Create pull request** using pr-creator if approved

Please begin the workflow for ticket: $ARGUMENTS

Current git status:
!`git status --porcelain`

Current branch:
!`git branch --show-current`
