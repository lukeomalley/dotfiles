# Personal Amp Configuration

## Preferences

- Use conventional commits format for git commits
- Prefer TypeScript over JavaScript when creating new files
- NO emojis, unicode symbols, or em-dashes in any output

## Code Review Strategy

When performing code reviews, use a multi-layered Oracle approach for maximum accuracy:

### Oracle Usage

The Oracle (GPT-5.2) excels at complex reasoning and analysis. Use it for:
- Initial comprehensive code review analysis
- Validating individual review comments for accuracy
- Debugging complex issues
- Analyzing data flow and edge cases

### Subagent Strategy

For PR reviews, spawn subagents in parallel to validate each comment independently:
- Each subagent should use its own Oracle call for deep verification
- This creates a "two Oracle" validation where each comment is reviewed by:
  1. The initial Oracle (comprehensive analysis)
  2. A validation Oracle (focused verification)

### Library Research

When reviewing code that uses third-party libraries:
1. **Librarian**: Search the library's actual source code on GitHub
2. **Context7 MCP**: Fetch current documentation for the library
3. Verify assumptions about library behavior before flagging issues

### False Positive Prevention

- Start with broad analysis, then narrow down with validation
- Trace data flow from entry points to flagged code
- Check for upstream guards, validation, or error handling
- Lower confidence scores when context is uncertain
- Only post comments with high confidence (>= 50% after validation)

## MCP Servers

Available MCP servers for enhanced functionality:
- `github`: PR operations, file fetching, review posting
- `atlassian`: Jira ticket lookup for requirements context
- `context7`: Library documentation lookup
