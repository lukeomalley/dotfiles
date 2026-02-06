---
name: review-pr
description: Review a GitHub pull request and post inline comments
---

# PR Review with Oracle-Powered Analysis

Review GitHub pull request #$ARGUMENTS for code quality issues, potential defects, and best practices violations.

**CRITICAL:** All feedback MUST be posted as inline comments attached to specific lines using the `create_pull_request_review` MCP tool with a `comments` array. The review body should ONLY be a brief summary (1-2 sentences). NEVER put detailed feedback in the review body.

---

## Workflow Overview

1. **Phase 1: Context Gathering** - Fetch PR and Jira ticket details
2. **Phase 2: Oracle Initial Analysis** - Use Oracle for deep code review
3. **Phase 3: Parallel Oracle Validation** - Subagents validate each comment with their own Oracle
4. **Phase 4: User Approval** - Present proposal and wait for selection
5. **Phase 5: Post to GitHub** - Submit review with inline comments

---

## Phase 1: Context Gathering

### Step 1a: Fetch PR Information

Use GitHub MCP tools to gather PR context:

1. **Get PR metadata and diff** using `get_pull_request`:
   - `owner`: Repository owner
   - `repo`: Repository name
   - `pull_number`: The PR number from $ARGUMENTS

2. **Get changed files with patches** using `get_pull_request_files`:
   - Same owner, repo, pull_number parameters

### Step 1b: Extract and Fetch Jira Ticket

Extract Jira ticket from PR title (format: `DEV-XXXX` at the beginning).

Examples:
- `DEV-1234 Add user authentication` -> Extract `DEV-1234`
- `DEV-5678: Fix login bug` -> Extract `DEV-5678`

Fetch ticket details using `jira_get_issue` from the Atlassian MCP:
- `issue_key`: The extracted ticket key
- `fields`: "summary,description,status,issuetype,priority,labels,assignee"
- `comment_limit`: 5
- `expand`: "renderedFields"

**If no Jira ticket found:** Proceed without Jira context, note this in output.

---

## Phase 2: Oracle Initial Analysis

**Use the Oracle tool** to perform deep code review analysis. The Oracle excels at reviewing, debugging, and analyzing complex code.

Invoke the Oracle with a prompt like:

> You are an expert code reviewer. Analyze this pull request thoroughly and identify ALL potential issues.
>
> **PR Context:**
> - Title: [PR title]
> - Description: [PR description]
> - Jira Ticket: [ticket key and summary, or "None"]
> - Files Changed: [list of files]
>
> **Changed Files with Diffs:**
> [Include all file diffs here]
>
> **Your Task:**
> Review each changed file systematically and identify:
> 1. Security vulnerabilities (SQL injection, XSS, hardcoded secrets, auth issues)
> 2. Bugs and potential crashes (null references, type errors, edge cases)
> 3. Logic errors and incorrect behavior
> 4. Performance issues (N+1 queries, unnecessary loops, memory leaks)
> 5. Missing error handling for critical paths
> 6. Requirements misalignment with Jira ticket (if provided)
> 7. Code quality and maintainability concerns
> 8. Best practices violations
>
> **For EACH potential issue, provide:**
> - `file`: The file path
> - `line`: Line number in the diff (position for GitHub API)
> - `category`: Security / Bug / Logic / Performance / Error Handling / Requirements / Quality
> - `severity`: critical / high / medium / low
> - `confidence`: 0-100% based on certainty
> - `label`: Using Conventional Comments (issue, suggestion, nitpick, todo, question, thought, note)
> - `decorations`: (blocking), (non-blocking), (security), (performance) as appropriate
> - `summary`: One-line description
> - `explanation`: Detailed explanation of the issue
> - `suggestion`: How to fix it (if applicable)
> - `related_code`: Any related code paths that informed your analysis
>
> **Return as structured JSON array.**
> Only include issues with confidence >= 30%.
> Be thorough but avoid false positives - if you are uncertain, lower the confidence score.

### Confidence Calibration

The Oracle should use these guidelines for confidence scoring:

| Level | Criteria |
|-------|----------|
| 90-100% | Obvious bug, security issue, or crash - clear evidence in the code |
| 70-89% | Likely issue with supporting evidence from context |
| 50-69% | Potential issue, depends on runtime/context we cannot fully verify |
| 30-49% | Possible concern, might be intentional or handled elsewhere |
| 0-29% | Uncertain, needs human judgment (filtered out) |

### Library Context Enhancement

If the Oracle identifies issues involving third-party libraries or frameworks:

1. **Use the Librarian** to search the library's source code for relevant implementation details
2. **Use Context7 MCP** (`resolve_library_id` then `get_library_docs`) to fetch current documentation
3. Re-evaluate the issue with this additional context

Example: If reviewing code using a React hook incorrectly, ask the Librarian to find how that hook is implemented and documented.

---

## Phase 3: Parallel Oracle Validation

For each comment from the Oracle's initial analysis (confidence >= 30%), spawn a **dedicated subagent** that will use **its own Oracle call** for deep validation.

**Launch all subagent validators in parallel.** Tell each subagent:

> You are a specialized PR comment validator. Your job is to deeply verify whether a proposed code review comment is valid and should be posted.
>
> **Context:**
> - Repository: [owner/repo]
> - PR Branch: [branch name or SHA]
> - File: [file path]
> - Line Position: [position in diff]
>
> **Proposed Comment:**
> - Category: [category]
> - Severity: [severity]
> - Initial Confidence: [X%]
> - Summary: [summary]
> - Explanation: [explanation]
>
> **Code Snippet:**
> ```
> [relevant code from the diff]
> ```
>
> **Your Validation Process:**
>
> 1. **Fetch Full Context:**
>    - Get the FULL target file using `github_get_file_contents`
>    - Identify and fetch related files (imports, callers, middleware, utilities)
>    - Note the broader context of where this code sits
>
> 2. **Use YOUR Oracle to Analyze:**
>    Ask YOUR oracle to deeply analyze this specific concern:
>    
>    > Analyze whether this code review comment is valid:
>    > - Comment: [the proposed comment]
>    > - Full file context: [full file contents]
>    > - Related code: [imports, callers, etc.]
>    >
>    > Consider:
>    > - Is the issue actually present in the code?
>    > - Is it handled elsewhere (guards, middleware, error boundaries)?
>    > - Could the reviewer have misread the code?
>    > - What is the actual impact if this is a real issue?
>    > - Is the suggested fix appropriate?
>    >
>    > Return: VALID, INVALID, or NEEDS_REFINEMENT with detailed reasoning.
>
> 3. **If Third-Party Code Involved:**
>    - Use Librarian to search the library's actual implementation
>    - Use Context7 to fetch current documentation
>    - Verify assumptions about library behavior
>
> 4. **Trace Data Flow:**
>    - Follow the data from entry point to the flagged code
>    - Check for validation, sanitization, or error handling upstream
>    - Verify the concern applies given the actual data flow
>
> **Decision Criteria:**
>
> - **APPROVE** if: Issue is real, not handled elsewhere, would improve the code
> - **REJECT** if: False positive, handled elsewhere, reviewer misread the code, or nitpick not worth posting
> - **REFINE** if: Issue is real but comment could be more accurate or helpful
>
> **Return JSON:**
> ```json
> {
>   "verdict": "APPROVE" | "REJECT" | "REFINE",
>   "confidence_adjustment": -30 to +20,
>   "final_confidence": <calculated final confidence>,
>   "refined_comment": {
>     "label": "<label> [decorations]",
>     "summary": "<one-line summary>",
>     "body": "<full comment body in Conventional Comments format>"
>   },
>   "reasoning": "<detailed explanation citing specific files, line numbers, and code paths>",
>   "evidence": [
>     {"file": "path", "line": N, "finding": "what was found"}
>   ]
> }
> ```

### Aggregating Subagent Results

After all subagent validators complete:

1. **Collect all results**
2. **Filter to APPROVE and REFINE verdicts only**
3. **Apply confidence adjustments** - recalculate final confidence
4. **Filter again**: Only keep comments with final confidence >= 50%
5. **Use refined comments** where subagents provided improvements

---

## Conventional Comments Format

All final comments MUST use Conventional Comments format:

```
<label> [decorations]: <subject>

[discussion]
```

**Labels:**
| Label | Description | Blocking? |
|-------|-------------|-----------|
| `issue` | Highlights specific problems | Yes |
| `suggestion` | Proposes improvements | Varies |
| `nitpick` | Trivial preference-based requests | No |
| `todo` | Small but necessary changes | Yes |
| `question` | Asks for clarification | No |
| `thought` | Ideas that popped up | No |
| `note` | Something to take note of | No |

**Decorations:** `(non-blocking)`, `(blocking)`, `(security)`, `(performance)`

---

## Phase 4: Present Proposal and Wait for Approval

**DO NOT post to GitHub yet.** Present a condensed proposal:

```markdown
## PR Review Proposal: #<PR_NUMBER>

**Title:** <PR Title>
**Jira Ticket:** <DEV-XXXX> (or "None found")
**Ticket Summary:** <Brief summary from Jira>
**Files Changed:** <count> | **Additions:** +<count> | **Deletions:** -<count>

---

### Review Process Summary

- **Oracle Initial Findings:** <N> potential issues identified
- **Subagent Validations:** <N> comments validated in parallel
- **Final Approved Comments:** <N> (after filtering)
- **Rejection Rate:** <X%> (false positives filtered out)

---

### Proposed Comments (Validated by Oracle x2)

| # | File | Pos | Type | Confidence | Summary |
|---|------|-----|------|------------|---------|
| 1 | `src/utils.ts` | 42 | issue (blocking) | 95% | Null check missing |
| 2 | `src/api.ts` | 15 | suggestion | 72% | Could simplify |

<details>
<summary>Click to expand full comment details</summary>

**Comment #1** - `src/utils.ts:42`
- Initial Confidence: 90% -> Final: 95% (+5)
- Validation: APPROVED with enhancement
- Evidence: Traced from entry point, no upstream null check found

```
issue (blocking): This could throw if `user` is null.

Accessing `user.email` here will cause a TypeError when the user is not logged in.
We should add a guard clause before this line.
```

</details>

---

### Recommended Verdict: <APPROVE | REQUEST_CHANGES | COMMENT>

<1-2 sentence explanation based on issue severity>

---

**To proceed, tell me:**
- Which comments to post (e.g., "1, 2" or "all" or "all except 3")
- What verdict (approve / request changes / comment only)

Example: "Post all, request changes"
```

**STOP and wait for user response before proceeding.**

---

## Phase 5: Post to GitHub

After user approval, use `create_pull_request_review` MCP tool:

- `owner`: Repository owner
- `repo`: Repository name
- `pull_number`: The PR number
- `body`: Brief summary ONLY (e.g., "Nice work! Found a few things inline.")
- `event`: "APPROVE", "REQUEST_CHANGES", or "COMMENT"
- `comments`: Array of inline comments with:
  - `path`: File path relative to repo root
  - `position`: Line position IN THE DIFF (not file line number)
  - `body`: The comment text

### Understanding `position` vs line numbers

The `position` is the line number in the diff hunk, NOT the file:

```diff
@@ -10,6 +10,8 @@ function example() {
 const x = 1;       // position 1
 const y = 2;       // position 2
+ const z = 3;       // position 3
+ const w = 4;       // position 4
 return x + y;      // position 5
}
```

To comment on `const z = 3;`, use `position: 3`.

### Event Options

| Event | When to Use |
|-------|-------------|
| `APPROVE` | No blocking issues, PR ready to merge |
| `REQUEST_CHANGES` | Has blocking issues that must be fixed |
| `COMMENT` | Feedback only, no explicit approval |

### Confirmation Output

After posting, show:

```markdown
## Posted Review to #<PR_NUMBER>

**Verdict:** REQUEST_CHANGES

**Review Process:**
- Oracle analyzed <N> files, found <N> potential issues
- <N> subagents validated comments in parallel (each using Oracle)
- <N> comments posted (<X%> filtered as false positives)

**Inline Comments Posted:**
- [x] #1: `src/utils.ts` (pos 42) - Null check issue (95%)
- [x] #2: `src/api.ts` (pos 15) - Simplify suggestion (72%)

**Review Summary:**
> Nice work! Found a couple things we should address.

[View on GitHub](<PR_URL>)
```

---

## Writing Guidelines

### Tone

- Friendly and collaborative, like a supportive teammate
- Use "we" instead of "you"
- Be curious, not assumptive - ask questions when uncertain
- Make comments actionable with clear suggestions
- NO emojis, unicode symbols, or em-dashes
- NEVER mention AI, bots, automation, Oracle, or subagents

### Good Examples

```
issue (blocking): This could throw if `user` is null.

Accessing `user.email` here will cause a TypeError when the user is not logged in.
We should add a guard clause before this line.
```

```
suggestion (non-blocking): We could use `find()` instead of `filter()[0]`.

This would be more readable and slightly faster since it stops on first match.
```

---

## Important Rules

1. **Use Oracle for initial analysis** - The Oracle excels at thorough code review
2. **Each subagent uses its own Oracle** - Double-verification through independent Oracle calls
3. **Use Librarian for library context** - When third-party code is involved
4. **Use Context7 for documentation** - Verify library usage against current docs
5. **Propose first, post later** - Always show proposal and wait for approval
6. **Use inline comments** - Review body is summary only, all feedback in `comments` array
7. **Use diff positions** - The `position` field refers to line in diff, not file
8. **High confidence threshold** - Only post comments with final confidence >= 50%
9. **Be specific** - Include file paths and positions
10. **Be constructive** - Explain why and how to fix
11. **Stay focused** - Only review changes in the PR, not pre-existing code
12. **Be human** - Never mention Amp, AI, Oracle, subagents, or automation

---

PR to review: $ARGUMENTS
