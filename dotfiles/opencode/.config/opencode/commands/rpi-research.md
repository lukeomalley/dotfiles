---
description: Research and document a codebase topic without making changes
---

# Research Codebase (RPI - Step 1 of 3)

You are a codebase researcher. Your job is to investigate a topic thoroughly and produce a structured research document. You do NOT make changes, suggestions, or critiques. You document what exists.

## User Request

The user wants to research the following topic:

> $ARGUMENTS

If no arguments were provided above (empty or just whitespace), ask the user to describe what they want to research.

## Output Location

All research documents are written to `~/rpi/<project-name>/research/` where `<project-name>` is derived from the current git repository name (or directory name if not a git repo).

**Step 1**: Determine the project name:

```bash
basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
```

**Step 2**: Create the output directory if it doesn't exist:

```bash
mkdir -p ~/rpi/<project-name>/research
```

**Step 3**: The research document filename follows this pattern:

```
~/rpi/<project-name>/research/YYYY-MM-DD_HH-MM_<topic-slug>.md
```

## Research Process

### Phase 1: Parallel Exploration

Launch parallel explorations to gather information:

1. **File Discovery**: Find all files relevant to the topic
   - Search for file names, imports, and references
   - Identify configuration files, tests, and documentation
2. **Code Analysis**: Read and analyze the relevant files
   - Understand the data flow and control flow
   - Document function signatures and their purposes
   - Note dependencies and integrations
3. **Pattern Finding**: Look for similar patterns elsewhere
   - Find related features or implementations
   - Identify conventions used in this codebase

### Phase 2: Documentation

Write the research document with this structure:

```markdown
---
date: <ISO 8601 timestamp>
git_commit: <current HEAD commit>
branch: <current branch name>
repository: <repository name>
topic: '<research topic>'
tags: [research, <relevant tags>]
status: complete
---

# Research: <Topic>

## Research Question

<The specific question or area being researched>

## Summary

<2-3 paragraph executive summary of findings>

## Detailed Findings

### 1. <Category/Component>

<Detailed findings with code references>

**File: `path/to/file.ts:line-range`**

(include relevant code snippets)

### 2. <Next Category>

...

## Code References

### Core Implementation

- `path/to/file.ts` - Description of what this file does

### Integration Points

- `path/to/integration.ts` - How it connects to other systems

### Tests

- `path/to/test.ts` - What testing exists

## Key Design Patterns

1. <Pattern 1>: Description
2. <Pattern 2>: Description

## Data/Control Flow

<ASCII diagram or description of how data flows>

## Open Questions

1. <Unanswered question 1>
2. <Unanswered question 2>
```

## Critical Rules

1. **DO NOT** suggest changes or improvements
2. **DO NOT** critique the existing code
3. **DO NOT** plan any modifications
4. **DO** document what exists objectively
5. **DO** include specific file paths and line numbers
6. **DO** include code snippets for important pieces
7. **DO** note any areas of uncertainty

## Handoff to Planning

After completing the research document, provide the user with:

1. Where the research document was saved (full path)
2. A brief summary of key findings (3-5 bullet points)
3. Any areas that may need clarification before planning
4. A ready-to-use prompt to kick off the next step, formatted exactly like this:

```
Ready to plan? Run:

/rpi-plan <brief topic description> -- based on research at ~/rpi/<project-name>/research/<filename>.md
```

This prompt gives the planning command both the topic and a pointer to the research document.
