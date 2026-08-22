---
name: simplify
description: >-
  Simplify agent-generated or overbuilt code by removing unnecessary bloat and
  making it read like prose. Language-agnostic. Use when asked to simplify,
  clean up, de-bloat, make more readable, refine recently written code, or
  reduce complexity without changing behavior.
---

# Simplify

Take working code (especially agent-generated code) and make it smaller, clearer, and easier to read. Preserve behavior. Prefer deletion and renaming over adding abstraction.

Code should read like English. A reader should understand intent from names and structure alone, without comments that restate what the code already says.

## Workflow

1. **Scope**: Identify the files or functions to simplify. Prefer the recent agent-written change unless the user specifies otherwise.
2. **Preserve behavior**: Do not change outputs, side effects, error semantics, or public APIs unless the user asks. Prefer mechanical clarity edits first.
3. **Cut bloat**: Remove dead code, unused params, speculative abstractions, and ceremony that does not earn its keep.
4. **Rename for intent**: Replace abbreviations and vague names with full, explicit names.
5. **Restructure for reading**: Separate concerns, name intermediates, prefer explicit control flow over cleverness.
6. **Match the project**: Keep the project's existing style, idioms, and tooling. Do not impose a foreign style guide.
7. **Verify**: Run the relevant tests/linters, or say what you could not run.

## What to remove

Agent output often accumulates weight. Delete or collapse:

- Unused variables, imports, helpers, feature flags, and parameters
- Wrappers that only pass through to another function
- Premature abstractions for a single call site ("Manager", "Handler", "Utils", "Helper" that do one thing)
- Config/options objects with one caller and mostly default fields
- Defensive checks for impossible states at internal boundaries
- Redundant null/error handling that duplicates the caller's responsibility
- Comments that narrate the code (`// increment counter`, `// return result`)
- Types, interfaces, or generics that exist only to support imagined future variants
- Indirection added "for testability" when a simpler seam already exists
- Nested conditionals that can be guard clauses or early returns

If deleting an abstraction requires threading the same logic through many call sites, keep it. Simplify is not "inline everything."

## Naming

### Variables: say what it is, fully

Spell out what the value holds. Abbreviations force a mental lookup table.

```
# Yes
predictedAsteroidPositions
reachableAsteroidIds
currentAsteroidId

# No
preds
cands
rid
```

### Functions: say what it does

The name should make a docstring feel redundant.

```
# Yes
predictPositionAtNextStep()
computeAsteroidJumpScore()
isValidJumpTarget()

# No
forecast()
score()
check()
```

### Booleans: read as decisions

Prefer positive names that work in conditionals: `isActive`, `hasPermission`, `mustJump`. Avoid `isNotInvalid`, `flag`, `status`.

### Constants: describe what they control

Name the rule, not just the value. Group related constants with a shared prefix or suffix so they read as a family.

```
VELOCITY_SCORE_WEIGHT
BOUNDS_MARGIN_EMERGENCY
MIN_OBSERVATIONS_BEFORE_JUMP
```

## Structure

### Named intermediates in formulas

Give each component its own name. The final expression should read like the math or business rule.

```
# Yes
positionScore = predictedY
velocityScore = velocityY
longevityScore = min(stepsAlive, LONGEVITY_CAP_STEPS)
topExitBonus = exitsTop ? TOP_EXIT_SCORE_BONUS : 0

return positionScore
  + VELOCITY_SCORE_WEIGHT * velocityScore
  + LONGEVITY_SCORE_WEIGHT * longevityScore
  + topExitBonus

# No
score = predictedY + VELOCITY_SCORE_WEIGHT * velocityY
score += LONGEVITY_SCORE_WEIGHT * min(stepsAlive, LONGEVITY_CAP_STEPS)
if exitsTop { score += TOP_EXIT_SCORE_BONUS }
return score
```

### Separate filtering from selection

Filter into a collection, then select from it. Do not interleave filter / score / track-best in one loop unless performance clearly requires it.

```
# Yes
reachableIds = filter(candidates, isValidJumpTarget)
if reachableIds is empty { return null }
return maxBy(reachableIds, computeJumpScore)

# No
bestId = null
bestScore = -inf
for id in candidates {
  if !isValid(id) { continue }
  s = score(id)
  if s > bestScore { bestScore = s; bestId = id }
}
return bestId
```

### Explicit control flow over cleverness

- Prefer a plain loop when a comprehension/chain buries a multi-argument filter or side effect.
- Prefer explicit `if` / `else` when a boolean expression hides a decision.
- Prefer guard clauses and early returns over deep nesting.
- One function, one job. If you need "and" to describe it, split it.

```
# Yes
shouldStay = shouldStayOnAsteroid(currentAsteroidId)
if shouldStay { return null }
mustJump = true

# No
mustJump = shouldStayOnAsteroid(currentAsteroidId) == false
```

### Derive values instead of threading them

If a value is fully determined by another parameter, compute it inside the function instead of passing both.

```
# Yes
isValidJumpTarget(..., isEmergency) {
  margin = isEmergency ? BOUNDS_MARGIN_EMERGENCY : BOUNDS_MARGIN_NORMAL
  ...
}

# No
isValidJumpTarget(..., margin, minObservations, isEmergency)
```

### Use the language's clear idioms

Prefer standard library operations that state intent (`maxBy`, `any`, `all`, `map`, `filter`, `find`) when they are simpler than hand-rolled loops. Switch to an explicit loop when the idiom gets dense or hard to debug.

## Comments and docs

- Rewrite unclear code instead of explaining it.
- Keep comments that explain *why*, constraints, or non-obvious tradeoffs.
- Remove comments that restate the next line.
- Do not add large docstring templates to obvious helpers.
- Document public APIs only when the contract is not obvious from the signature and name.

## Project fit

- Follow the repository's naming, formatting, and lint rules when they conflict with these preferences.
- Do not introduce new dependencies, frameworks, or file-splitting campaigns unless simplification clearly requires it.
- Keep diffs focused. A simplify pass should be easy to review.

## Checklist

Before finishing:

- [ ] Behavior and public API unchanged (unless asked)
- [ ] Dead code, unused params, and pass-through wrappers removed
- [ ] Names read as prose; abbreviations expanded
- [ ] Formulas use named intermediates
- [ ] Filter/select and other steps are separated when that clarifies intent
- [ ] Control flow is explicit; nesting is shallow
- [ ] No new abstraction unless it removes more complexity than it adds
- [ ] Project style preserved; tests/linters considered

## Summary

| Preference | Why |
|---|---|
| Delete before abstracting | Less code to trust and read |
| Long explicit names | No mental lookup table |
| Named formula components | Reads like the rule being computed |
| Filter then select | Each step has one job |
| Explicit control flow | Intent is stated, not decoded |
| Derived parameters | Fewer args, less misuse |
| Language idioms when clearer | Declarative intent over ceremony |
| Comments for why only | Noise hides real information |
