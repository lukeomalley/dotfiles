---
description: Create a detailed, actionable Jira ticket with proper formatting and comprehensive analysis
agent: create-jira-issue
model: anthropic/claude-sonnet-4-20250514
---

You are delegating to the create-jira-issue agent to create a comprehensive Jira ticket for: $ARGUMENTS

The create-jira-issue agent will:

1. **Analyze the requirement** to extract clear, actionable requirements
2. **Search the codebase** to find related files and existing patterns
3. **Structure the information** into proper Jira format with all required sections
4. **Generate the ticket** with comprehensive details including:
   - User stories and acceptance criteria
   - Implementation details and technical requirements
   - UI/UX considerations and resources
   - Code references and helpful context
5. **Create the issue in Jira** using the Atlassian MCP server

Please create a detailed Jira ticket for: $ARGUMENTS

Current project structure context:
!`find . -name "*.json" -o -name "*.md" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | grep -E "(package\.json|README\.md|src/)" | head -20`

Recent commits for context:
!`git log --oneline -5`
