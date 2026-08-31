---
name: refine-last-changes
description: Review and improve the most recent code changes using parallel read-only agents focused on simplicity, architecture, cognitive load, performance, and reuse. Use when refining staged, unstaged, untracked, committed, or explicitly scoped changes while preserving behavior and avoiding broad refactors.
---

# /simplify

Simplify the scoped code while preserving behavior. Use parallel read-only reviewers to identify focused improvements, then apply the smallest coherent set of fixes yourself.

Optimize for:

1. correctness;
2. low cognitive load;
3. clear architecture and ownership;
4. reuse;
5. performance.

Prefer code that is easy to understand locally. Do not introduce abstractions, indirection, or architectural layers unless they remove more complexity than they add.

## Scope

Select the scope in this order:

1. Explicit paths, symbols, diff, commit, or area provided after `/simplify`.
2. Otherwise, inspect all local changes:

```bash
git diff --no-color
git diff --cached --no-color
git ls-files --others --exclude-standard
```

3. Otherwise, use concrete files or changes mentioned in the conversation.
4. Otherwise, inspect the current commit:

```bash
git show --stat --patch --no-color HEAD
```

Read nearby code when needed to understand callers, boundaries, or existing patterns. Do not edit unrelated code.

Preserve all unrelated user changes.

## Parallel Review

Launch the following reviewers in parallel. They must use the same model as the parent agent and only report findings.

Reviewers must not edit files, run formatters, create branches or worktrees, or commit changes.

Pass the complete diff when practical. Otherwise, pass the scoped files, relevant hunks, changed symbols, and a concise scope summary.

Each finding must include:

* location;
* concrete problem;
* proposed change;
* expected benefit;
* confidence.

Do not report style preferences without a clear effect on comprehension, correctness, architecture, or performance.

### 1. Simplicity Reviewer

Look for:

* comments that merely restate the code;
* one-use helpers that obscure the flow;
* unnecessary wrappers, configuration objects, or generic abstractions;
* excessive nesting or fragmented control flow;
* redundant defensive checks;
* unnecessary nullable states;
* broad error handling;
* duplicated or derived state;
* avoidable casts, assertions, or broad types;
* dead, compatibility, or fallback code without evidence of need.

Preserve helpers that express domain concepts, isolate side effects, enforce invariants, or provide meaningful reuse.

### 2. Architecture and Cognitive Load Reviewer

Evaluate whether the changed code is easy to reason about and fits the existing architecture.

Look for:

* unclear module or function responsibilities;
* business rules placed in transport, UI, persistence, or infrastructure layers;
* dependencies pointing in the wrong direction;
* hidden coupling through globals, shared mutable state, callbacks, or side effects;
* duplicated policy across modules;
* abstractions that leak implementation details;
* functions that require too much context to understand;
* temporal coupling or order-dependent behavior;
* state with unclear ownership;
* names that conceal domain intent;
* changes that require editing many unrelated locations.

Prefer:

* explicit ownership;
* cohesive modules;
* narrow interfaces;
* linear control flow;
* visible invariants;
* domain-oriented names;
* dependencies on stable abstractions already used by the repository.

Recommend broad architectural changes only as skipped findings. Applied fixes must remain proportional to the original scope.

### 3. Performance Reviewer

Look for plausible issues in real execution paths:

* blocking operations in hot paths;
* repeated expensive computation, parsing, or allocation;
* N+1 I/O;
* independent operations executed sequentially;
* repeated collection traversal;
* quadratic string or collection construction;
* busy polling;
* unbounded concurrency;
* excessive logging in loops or hot paths.

Do not recommend caching or concurrency without considering invalidation, ordering, error handling, and resource limits.

### 4. Reuse Reviewer

Search the scoped code and relevant nearby modules for existing:

* helpers;
* types;
* validators;
* formatters;
* components;
* services;
* error-handling patterns;
* domain abstractions.

Reuse existing code only when its behavior, ownership, and dependency direction match the current need. Do not force reuse merely because similar code exists.

## Triage

Aggregate and deduplicate the findings. Verify each one directly against the code.

Apply a finding only when it:

* preserves observable behavior;
* has clear evidence;
* lowers cognitive load or net complexity;
* respects existing architectural boundaries;
* fits the selected scope;
* can be implemented safely as a focused change.

Skip findings that are speculative, stylistic, low-confidence, behavior-changing, or require a substantially broader refactor.

When two solutions are valid, prefer the one with:

* fewer concepts;
* fewer states;
* fewer dependencies;
* less indirection;
* clearer ownership;
* easier local reasoning.

## Fixing

Make the smallest coherent set of improvements.

Prefer:

* deleting unnecessary code;
* simplifying control flow;
* making invariants explicit;
* consolidating duplicated policy;
* using established repository patterns;
* narrowing types and interfaces;
* moving logic to the layer that owns it;
* reducing repeated work.

Avoid:

* unrelated renaming or formatting;
* speculative abstractions;
* new dependencies without strong justification;
* generic utilities created for one caller;
* public API changes;
* broad architectural rewrites;
* replacing familiar code with clever code.

## Validation

After editing:

1. Inspect the final diff for unrelated or accidental changes.
2. Confirm architectural boundaries and dependency direction did not worsen.
3. Run the narrowest relevant formatter check, lint, type check, and targeted tests.
4. Fix failures introduced by your changes.
5. Report checks that were unavailable and unrelated pre-existing failures.

## Final Response

### Simplified

Summarize the changes actually applied and how they reduced complexity, cognitive load, architectural friction, or runtime cost.

### Validation

List the checks run and their results.

### Skipped

List valuable findings not applied because they required more context, changed behavior, increased risk, or exceeded the selected scope.

Omit empty sections. Never present an unimplemented recommendation as completed work.
