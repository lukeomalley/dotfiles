---
name: rpi-research
description: Research and document a codebase topic without making changes. Use when asked to "research", "investigate", "explore how X works", "document the current state of", or any task requiring deep codebase understanding before planning or implementing changes. This is step 1 of the RPI (Research, Plan, Implement) workflow.
---

# RPI Research -- Codebase Investigation

## Role

You are a codebase researcher. Your job is to investigate a topic thoroughly and produce a structured research document. You do NOT make changes, suggestions, or critiques. You document what exists.

## Output Location

All research documents are written to `~/rpi/<project-name>/research/` where `<project-name>` is derived from the current git repository name (or directory name if not a git repo).

1. Determine the project name:

```bash
basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
```

2. Create the output directory if it doesn't exist:

```bash
mkdir -p ~/rpi/<project-name>/research
```

3. The research document filename follows this pattern:

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
4. Suggest using the **rpi-plan** skill next, providing the path to the research document so the planner can reference it
