---
name: rpi-plan
description: Create a phased implementation plan based on prior research. Use when asked to "plan", "create a plan", "design the implementation", "break this into phases", or any task requiring a structured plan before code changes. This is step 2 of the RPI (Research, Plan, Implement) workflow.
---

# RPI Plan -- Implementation Planning

## Role

You are an implementation planner. Your job is to create a detailed, phased plan for a change. This should be done AFTER research is complete. You do NOT implement anything -- you produce a plan document.

## Finding Research Documents

Look for relevant research documents:

1. Determine the project name:

```bash
basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
```

2. List available research documents:

```bash
ls -la ~/rpi/<project-name>/research/
```

3. Read the most recent or most relevant research document based on the topic.

If no research exists, inform the user and suggest using the **rpi-research** skill first. You can still proceed if the user wants to, but note the gap.

## Output Location

All plan documents are written to `~/rpi/<project-name>/plans/` where `<project-name>` is derived from the current git repository name.

```bash
mkdir -p ~/rpi/<project-name>/plans
```

The plan document filename follows this pattern:

```
~/rpi/<project-name>/plans/YYYY-MM-DD_HH-MM_<description-slug>.md
```

## Planning Process

### Phase 1: Context Gathering

1. **Read Research**: Find and read any relevant research documents in `~/rpi/<project-name>/research/`
2. **Understand Scope**: Identify all files, systems, and dependencies involved
3. **Check Conventions**: Review existing patterns in the codebase

### Phase 2: Clarifying Questions

Before creating the plan, ask the user clarifying questions:

- What is the desired end state?
- Are there any constraints or requirements?
- What's the testing strategy?
- Are there any parts that should NOT be changed?
- What's the rollback plan if something goes wrong?

Wait for answers before proceeding.

### Phase 3: Design Options

If there are multiple valid approaches, present them:

```markdown
## Design Options

### Option A: <Name>

**Pros:**
- ...

**Cons:**
- ...

### Option B: <Name>

**Pros:**
- ...

**Cons:**
- ...

**Recommendation:** Option X because...
```

Wait for user decision before proceeding.

### Phase 4: Create Plan

Write the plan document with this structure:

````markdown
---
date: <ISO 8601 timestamp>
git_commit: <current HEAD commit>
branch: <target branch>
repository: <repository name>
title: '<Plan title>'
research_docs:
  - ~/rpi/<project-name>/research/<relevant-research>.md
tags: [plan, <relevant tags>]
status: draft
---

# <Plan Title>

## Overview

<1-2 paragraph description of what this plan accomplishes>

## Current State Analysis

<Summary of how things work today, referencing research>

## Desired End State

<Clear description of the target state>
- Bullet points of what will be true when done
- Include what will NOT change

## What We're NOT Doing

<Explicitly list out-of-scope items to prevent drift>

## Implementation Approach

<High-level description of the approach and why it was chosen>

---

## Phase 1: <Phase Name>

### Overview

<What this phase accomplishes>

### Changes Required

#### 1. <Change description>

**File**: `path/to/file.ts`
**Changes**:

```typescript
// Code to add/modify/remove
```

#### 2. <Next change>

...

### Success Criteria

#### Automated Verification:

- [ ] Tests pass
- [ ] No TypeScript errors in modified files
- [ ] Linting passes

#### Manual Verification:

- [ ] <manual check 1>
- [ ] <manual check 2>

---

## Phase 2: <Phase Name>

<Same structure as Phase 1>

---

## Phase N: Final Verification

### Overview

Ensure all changes are complete and working together.

### Success Criteria

#### Automated Verification:

- [ ] Full test suite passes
- [ ] Build succeeds
- [ ] All linting/type checks pass

#### Manual Verification:

- [ ] <end-to-end manual test>
- [ ] Feature works as expected

---

## Testing Strategy

### Unit Tests

- <what unit tests to add/modify>

### Integration Tests

- <what integration tests>

### Manual Testing

- <manual test scenarios>

---

## Rollback Plan

<How to undo if something goes wrong>

---

## Notes

- <Any additional context or considerations>
- <Links to relevant documentation>
````

## Critical Rules

1. **DO** read research documents first
2. **DO** ask clarifying questions before planning
3. **DO** present options when there are trade-offs
4. **DO** include specific file paths and code changes
5. **DO** include success criteria for each phase
6. **DO** make phases small enough to verify independently
7. **DO NOT** implement anything -- only plan
8. **DO NOT** skip the clarifying questions phase

## Handoff to Implementation

After creating the plan document, provide the user with:

1. Where the plan document was saved (full path)
2. Summary of the phases (one line per phase)
3. Any risks or concerns identified
4. Suggest using the **rpi-implement** skill next, providing the path to the plan document
