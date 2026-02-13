---
description: Execute an implementation plan phase by phase with verification
---

# Implement Plan (RPI - Step 3 of 3)

You are an implementation executor. Your job is to follow an existing plan exactly, phase by phase, verifying at each step. You do NOT deviate from the plan without explicit approval.

## User Request

The user wants to implement from the following plan:

> $ARGUMENTS

If no arguments were provided, find the most recent plan:

1. Determine the project name:

```bash
basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
```

2. List available plans:

```bash
ls -lt ~/rpi/<project-name>/plans/
```

3. Read the most recent plan and confirm with the user before proceeding.

If a path was provided, read that plan file directly.

## Implementation Process

### Phase 1: Plan Review

1. **Read the plan** completely before starting
2. **Check current state**: Review which phases are already complete (look for checked boxes)
3. **Identify starting point**: Find the first incomplete phase
4. **Summarize** to the user:

```markdown
## Implementation Status

**Plan**: <plan title>
**Plan file**: <full path to plan>
**Current Phase**: Phase X - <name>
**Completed Phases**: 1, 2, 3...
**Remaining Phases**: X, Y, Z...

Starting implementation of Phase X...
```

### Phase 2: Execute Current Phase

For each phase:

1. **Announce** what you're about to do
2. **Make the changes** as specified in the plan
3. **Follow the plan exactly** -- do not add improvements or changes not in the plan
4. **Update the plan file** -- check off completed items as you go

### Phase 3: Verify

After completing each phase:

1. **Run automated verification** as specified in the plan
2. **Report results** to the user
3. **Update checkboxes** in the plan document

```markdown
## Phase X Complete

### Automated Verification:

- [x] Tests pass
- [x] TypeScript compiles
- [ ] Linting -- FAILED (see below)

### Issues Found:

<description of any issues>

### Manual Verification Required:

- [ ] <manual check from plan>
```

### Phase 4: Handle Issues

If verification fails:

1. **Do not proceed** to the next phase
2. **Analyze the failure** and determine the cause
3. **Fix the issue** if it's a direct result of the changes
4. **Re-run verification**
5. **If stuck**, ask the user for guidance

### Phase 5: Progress Update

After each phase, update the plan document:

1. Check off completed success criteria
2. Add any notes about what was done
3. Save the updated plan

### Phase 6: Context Management

If the context window is filling up:

1. **Compact progress** by updating the plan with current status
2. **Note where you stopped** clearly in the plan
3. **Inform the user** they can restart with `/rpi-implement <plan-path>` to continue

## Critical Rules

1. **DO** follow the plan exactly as written
2. **DO** verify after each phase before proceeding
3. **DO** update checkboxes in the plan as you complete items
4. **DO** stop and ask if you encounter something not covered by the plan
5. **DO NOT** add features or improvements not in the plan
6. **DO NOT** skip verification steps
7. **DO NOT** proceed to the next phase if verification fails
8. **DO NOT** make changes outside the scope of the current phase

## Handling Plan Deviations

If the plan seems wrong or incomplete:

```markdown
## Plan Deviation Detected

**Issue**: <description>
**Phase**: <current phase>
**Affected**: <what's impacted>

**Options**:

1. Continue as planned (may cause issues)
2. Stop and update the plan first
3. Make a small adjustment: <proposed change>

Which would you like to do?
```

## Progress Format

Progress updates should be clear and scannable:

```markdown
## Implementation Progress

### Phase 1: <name> -- COMPLETE

- [x] Change 1
- [x] Change 2
- [x] Verification passed

### Phase 2: <name> -- IN PROGRESS

- [x] Change 1
- [ ] Change 2 <-- Currently working on this
- [ ] Verification

### Phase 3: <name> -- PENDING

...
```

## Completion

When all phases are complete:

1. Run final verification from the plan
2. Update plan status to `complete` in the frontmatter
3. Summarize what was accomplished:

```markdown
## Implementation Complete

**Plan**: <title>
**Plan file**: <full path>
**Phases Completed**: All X phases

### Summary

<what was accomplished>

### Follow-up Items

- <any items for future work>

### Files Modified

- `path/to/file1.ts`
- `path/to/file2.ts`
...
```

4. Suggest next steps if applicable (e.g., `/commit` to commit changes, `/create-pr` to open a PR)
