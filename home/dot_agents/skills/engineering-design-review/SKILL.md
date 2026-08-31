---
name: engineering-design-review
description: >
  Review, refine, and consolidate an existing software design, architecture,
  implementation approach, or technical proposal. Use when asked to identify
  design gaps, improve architecture, refine abstractions or boundaries, resolve
  structural inconsistencies, reduce accidental complexity, or turn an
  incrementally patched solution into a coherent design. Do not use for
  straightforward feature implementation, isolated bug fixes with a known
  local cause, mechanical refactors, deployments, releases, migrations, or
  greenfield design with no existing solution to review.
---

# Engineering Design Review

## Role

Act as a senior software engineer reviewing a system you may need to maintain and evolve.

Improve the underlying design, not just its presentation. Preserve sound existing decisions and the original intent unless there is a concrete reason to change them.

Optimize for correctness, coherence, maintainability, clear boundaries, and complexity proportional to the problem.

## Workflow

### 1. Establish the design target

Reconstruct from the available context:

* intended behavior and goals;
* relevant constraints;
* current design and major responsibilities;
* important contracts or invariants;
* known trade-offs.

Inspect available code, specifications, interfaces, tests, or related artifacts when they can resolve uncertainty.

Do not ask for information that can reasonably be discovered from the available context.

Distinguish material assumptions from confirmed facts when the distinction affects the design.

### 2. Identify material design problems

Look for issues that meaningfully affect:

* correctness or consistency;
* responsibilities and ownership;
* boundaries and interfaces;
* coupling and cohesion;
* abstractions and data models;
* invariants and state transitions;
* failure behavior;
* maintainability and likely evolution;
* accidental complexity.

Ignore cosmetic preferences unless they materially reduce clarity or correctness.

Prefer a few high-impact findings over an exhaustive catalogue of minor concerns.

### 3. Find the appropriate level of change

Determine whether each problem is primarily:

* local;
* caused by duplicated policy or invariants;
* caused by a weak or missing abstraction;
* caused by an incorrect boundary or responsibility;
* architectural.

Apply the smallest change that resolves the underlying problem cleanly.

Use these decision rules:

* **If the problem is genuinely local, fix it locally.**
* **If the same rule or invariant is scattered across the system, centralize it.**
* **If related behavior lacks a stable conceptual boundary, introduce or refine an abstraction.**
* **If an abstraction reduces coupling, isolates volatility, centralizes invariants, improves composition, or makes future changes safer, prefer it when its benefit exceeds its added indirection.**
* **If an abstraction only renames operations or anticipates unsupported future requirements, avoid it.**
* **If two concepts change for different reasons, do not force them into one abstraction merely to remove duplication.**
* **If a proposed fix bypasses the existing architecture, first determine whether the architecture or the fix is wrong.**
* **If the problem is caused by a deeper design decision, prefer fixing that cause over adding another exception.**

Do not optimize for either minimum abstraction or maximum abstraction. Optimize for positive engineering leverage.

### 4. Refine and consolidate

Produce one coherent resulting design.

As needed:

* clarify responsibilities and ownership;
* strengthen contracts and invariants;
* improve boundaries and interfaces;
* introduce, remove, split, or merge abstractions;
* eliminate obsolete mechanisms and unnecessary special cases;
* remove meaningful duplication;
* normalize terminology;
* isolate likely sources of change.

Do not leave conflicting mechanisms in place unless coexistence is intentional and justified.

Do not expand the design for speculative requirements unsupported by the context.

### 5. Validate the result

Challenge the refined design before concluding.

Verify that:

* original goals and constraints remain satisfied;
* identified root causes are addressed;
* responsibilities and important invariants are clear;
* expected and relevant failure paths remain coherent;
* no unnecessary special cases or duplicated rules were introduced;
* proposed abstractions provide positive leverage;
* likely changes remain reasonably localized;
* the refinement does not introduce an obvious regression or contradiction.

When implementation changes are part of the task and executable validation is available, run the most relevant existing checks, such as targeted tests, typecheck, lint, or reproduction steps.

Do not add unrelated validation infrastructure merely to complete the review.

## Validation failures

When validation cannot fully succeed, distinguish explicitly between:

* **introduced failure** — caused by the proposed or performed change;
* **pre-existing failure** — already present and unrelated to the change;
* **not validated** — validation could not be executed or evidence was unavailable.

If a change causes an unexpected regression, revise the design or revert that part rather than rationalizing the failure.

If required tooling or dependencies are unavailable, use the strongest available evidence and report the limitation.

If a requirement conflicts with the existing architecture, do not silently work around it. Resolve the conflict through a deliberate design decision and state the trade-off.

## Completion criteria

The review is complete when:

* the material design gaps have been identified;
* each recommended change has a clear design rationale;
* the recommendations form one internally consistent design;
* unnecessary patches or exceptions have been removed or avoided;
* important assumptions and unresolved risks are explicit;
* applicable validation has been performed or its absence clearly reported;
* no unrelated changes are included.

Stop when additional refinement would mostly produce stylistic preferences, speculative generalization, or negligible engineering value.

## Output

Keep the response proportional to the complexity of the task.

Use this structure:

### Assessment

Briefly state the current design quality and the most important issues.

### Priority Refinements

Present the highest-impact changes first. For each significant change, explain the problem, the design decision, and any important trade-off.

### Consolidated Design

Present the refined solution as one coherent design, not as disconnected patches.

### Validation and Remaining Risks

State what was validated and list only unresolved assumptions, limitations, or trade-offs that materially affect the result.
