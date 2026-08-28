# Rust Reference

## Scope and Composition

Apply when the repository contains Rust code or a `Cargo.toml` manifest. Use repository conventions first; these are strict production defaults.

## Implementation Workflow

1. Define observable behavior, invariants, ownership, and error contract.
2. Inspect crate boundaries, callers, tests, and established APIs before selecting a design.
3. Validate untrusted values before side effects and model invalid states explicitly.
4. Implement the smallest coherent change with cancellation, cleanup, and concurrency ownership.
5. Add focused tests; measure before applying performance complexity.

## Architecture, Organization, and Naming

- Organize crates and modules around cohesive domain behavior. Keep I/O, framework adapters, and FFI at boundaries; keep core transformations pure and independently testable.
- Expose the smallest public API that expresses the domain. Keep fields private by default and document public behavior, errors, panics, and safety constraints.
- Name modules, functions, and variables with `snake_case`; types and traits with `PascalCase`; constants with `SCREAMING_SNAKE_CASE`. Use domain names, not mechanisms.
- Keep imports ordered as standard library, external crates, workspace or `crate`, then `super`. Avoid wildcard imports except intentional preludes and tests.
- Keep functions focused, immutable by default, and linearly readable. Use `let ... else` and early exits for terminal conditions; extract only meaningful operations.
- Do not add generic utilities, traits, builders, or abstractions until a real reuse or protected boundary justifies them.

### File Order

Use module boundaries rather than a large ordered file. In `lib.rs`, `main.rs`, and facade modules, declare modules and narrowly curated re-exports; do not create global `types.rs` or `utils.rs` dumping grounds. Within a domain module, use this order:

1. Inner or module documentation and attributes.
2. Imports: standard library, external crates, `crate`, then `super`.
3. Public constants and type aliases that belong to the domain contract.
4. Public structs, enums, traits, and error types.
5. Private constants and supporting types.
6. `impl` blocks: inherent constructors and public methods, trait implementations, then private methods.
7. Public free functions, then private helpers.
8. `#[cfg(test)] mod tests` at the bottom.

Order test code as imports, controlled test fixtures, then behavior-oriented tests. Keep public-boundary and module-private tests distinct when that distinction improves contract coverage.

## Types, State, and Data Flow

- Prefer borrowing in public APIs: accept `&str`, slices, and references unless ownership is required. Pass small `Copy` values by value; avoid clones unless the boundary requires ownership.
- Use newtypes for semantically distinct primitives and `Option` for absence rather than sentinels.
- Make invalid states difficult to represent with enums and validated constructors. Use type-state only when it simplifies a meaningful transition; prefer direct runtime validation for simple finite states.
- Keep side effects at system boundaries. Prefer static dispatch when types are known; introduce `dyn Trait` and boxing only for a genuine runtime-polymorphism boundary.

## Errors, Security, and Resource Lifecycle

- Return `Result` for fallible runtime operations and propagate with `?`, adding actionable context at application boundaries. Libraries use typed domain errors with `thiserror`; binaries may use `anyhow` for contextual aggregation.
- Do not introduce `panic!`, `unwrap`, or `expect` in shipping paths. Limit `expect` to proven invariants and state that invariant in its message.
- Retry only transient, idempotent operations with bounded exponential backoff, timeout, cancellation, and observability; never retry validation, authorization, or permanent errors.
- Keep secrets out of source, logs, errors, and debug output. Validate untrusted input at boundaries, apply size and time limits to external work, and preserve root causes without leaking sensitive data.
- Avoid `unsafe`; isolate necessary unsafe code behind a minimal safe API, document every invariant with `# Safety`, and test the boundary.
- Do not use interior mutability, reference counting, locks, or dynamic dispatch unless the ownership or runtime-polymorphism requirement is explicit. In async code, never block the runtime; bound concurrency and move CPU-bound work only after measuring need.

## Performance

- Optimize from profiles or demonstrated constraints, never speculation. Avoid unnecessary allocation and copying, preallocate known collection sizes, batch remote work, and prefer server-side operations that avoid client-side N+1 work.

## Testing

- Write focused tests for observable success, validation, and failure behavior. Test public behavior with integration tests and isolated deterministic logic with unit tests; mock or fake external services at their boundary.
- Use one behavior per descriptively named test. Add regression coverage for fixed defects and use snapshots only for complex, stable structured output.

## Quality Gates

Run repository-prescribed checks first. Otherwise run `cargo fmt --all --check`, `cargo clippy --workspace --all-targets --all-features -- -D warnings`, and `cargo test --workspace --all-features`; build and check documentation when public API or documentation changes. Treat new warnings, unchecked TODOs, unnecessary suppressions, hidden clones, undocumented contracts, and unmeasured performance claims as incomplete work.
