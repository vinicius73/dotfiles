# TypeScript Reference

## Scope and Composition

Apply when the repository contains TypeScript sources or a `tsconfig` file. Use repository conventions first; these are strict production defaults. For browser work, also apply `frontend.md`; React and Vue add framework-specific rules.

## Implementation Workflow

1. Define the contract, invalid states, ownership, and recoverable error behavior.
2. Validate every untrusted value at its runtime boundary.
3. Model validated domain values and results with precise types.
4. Implement the happy path, then failures, cancellation, cleanup, and retries.
5. Add focused tests, run quality gates, and refactor only when the result is simpler.

## Architecture, Organization, and Naming

- Organize modules by domain or capability, not technical layer. Keep each module's public API in one explicit entry point; never import another module's internals.
- Use one concept per file. Co-locate focused tests and private helpers; split files when they own independent behavior or contracts.
- Name files with `kebab-case`; types, classes, and enums with `PascalCase`; functions, variables, parameters, and properties with `camelCase`; constants with `camelCase` unless externally mandated.
- Use domain names that state intent, such as `parseUserId` or `isRetryableError`, never `handleData`, `process`, `util`, `manager`, or `helper`.
- Export only named symbols. Default exports, barrel files that hide ownership, and re-exporting module internals are prohibited.
- Order imports: platform or runtime, third-party, workspace aliases, parent, sibling, then type-only imports. Separate groups with one blank line; use `import type` for type-only imports.
- Keep functions focused and linearly readable: validate first, return early for terminal cases, perform the happy path last, and isolate I/O at module boundaries.

### File Order

Keep one cohesive concept per module; do not combine unrelated contracts and implementations merely to follow this order:

1. Required file directives.
2. Imports in the prescribed group order.
3. Exported constants and validated literal sets.
4. Exported types or interfaces.
5. Exported functions or classes, so the public contract is visible before internals.
6. Private constants and types.
7. Private implementations and helpers, in call-flow order or adjacent to their only consumer.

Order test code as imports, controlled fixture builders or fakes, then observable-behavior tests. Never export internals only to test them.

## Types, State, and Data Flow

- Preserve strict compiler configuration. Enable `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `useUnknownInCatchVariables`, and `noImplicitOverride` when compatible; document a compatibility reason for any relaxation.
- Do not use `any`, `@ts-ignore`, `@ts-nocheck`, broad `as` casts, or non-null assertions. A narrow local assertion is permitted only after a runtime invariant check cannot be expressed in the type system.
- Treat HTTP payloads, environment variables, JSON, persistence records, queues, webhooks, and third-party SDK outputs as `unknown` until runtime validation succeeds.
- Model variants with discriminated unions and handle them exhaustively. Handle `undefined`, nullability, and array indexing explicitly.
- Prefer `type` for object shapes, unions, intersections, and derived types; use `interface` only for declaration merging or class implementation contracts. Do not use enums; use string unions or `as const` values.
- Pass dependencies explicitly when behavior varies by environment, time, randomness, I/O, or policy. Prefer returned values over mutation, callbacks, or output parameters; keep necessary mutation local and obvious.

## Errors, Security, and Resource Lifecycle

- Preserve meaningful error causes and represent expected failures explicitly. Do not hide failures with broad catches, empty handlers, or coercion to fallback values.
- Keep secrets and sensitive values out of source, logs, and errors. Validate external input at boundaries and own cleanup, cancellation, timeout, and bounded retry behavior where I/O begins.

## Performance

- Measure before optimizing. Avoid repeated parsing, allocation, rendering, or remote work in hot paths; batch independent work only when concurrency bounds and failure handling remain explicit.

## Testing

- Test observable behavior with Arrange–Act–Assert. Assert outputs and externally visible side effects, not private implementation details.
- Cover invalid input, boundaries, failures, cleanup, and regressions for changed contracts. Keep tests deterministic and dependencies controlled at their boundary.

## Quality Gates

Use repository commands first. Otherwise run formatter, lint, typecheck, targeted tests, the relevant full suite, and the build or framework check. Inspect the final diff; no applicable failed or skipped gate permits a completion claim.
