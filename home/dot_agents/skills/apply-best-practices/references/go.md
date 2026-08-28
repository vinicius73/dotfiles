# Go Reference

## Scope and Composition

Apply when the repository contains Go code or a `go.mod` module. Use repository conventions first; these are strict production defaults.

## Implementation Workflow

1. Define observable behavior, invariants, error contract, and resource ownership.
2. Inspect callers, tests, and package conventions before selecting an API.
3. Validate inputs and failure paths before side effects.
4. Implement cancellation, timeout, cleanup, and concurrency ownership explicitly.
5. Add focused regression tests; refactor only when the result is simpler.

## Architecture, Organization, and Naming

- Organize by cohesive domain package, not technical layer. A package owns one concept; co-locate its files, tests, and unexported helpers.
- Use short lowercase noun package names. Never create `common`, `util`, `helpers`, or `base` packages, and avoid stuttering such as `user.User`.
- Keep `main` limited to configuration, dependency wiring, lifecycle, and process exit. Put application behavior in importable packages.
- Export the smallest API possible. Exported identifiers have stable semantics and doc comments beginning with their name; never export solely for tests.
- Prefer zero-value-safe types where practical. Constructors establish required invariants and return concrete types; return an interface only when callers need the abstraction.
- Define interfaces in the consuming package with the minimum required methods. Do not create interfaces preemptively or mirror concrete implementations.
- Name code by domain intent, not implementation. Use initialisms consistently (`ID`, `URL`, `HTTP`) and avoid abbreviations except conventional locals such as `ctx` and `err`.
- Keep functions single-purpose and linearly readable. Return early for invalid and terminal conditions; extract helpers only when they name a meaningful operation or simplify control flow.
- Let `gofmt` organize imports: standard library, blank line, then third-party or local packages. Alias only for a real collision.

### File Order

Keep each file cohesive; packages, not files, are the unit of encapsulation. Use this order when a file contains a complete domain concept:

1. Repository-required build constraints or license.
2. `package` declaration and imports.
3. Valuable compile-time interface assertions.
4. Exported constants and sentinel errors belonging to the file's contract.
5. Exported types with documentation, then constructors and exported functions or methods.
6. Unexported supporting types, implementations, and helpers near their sole caller where possible.

Order test files as imports, fixtures or fakes, then behavior-oriented tests. Use an external test package only to verify the true exported boundary.

## Types, State, and Data Flow

- Prefer explicit parameters and return values over hidden state. Do not use boolean flags or variadic configuration to change behavior; use an options struct only for genuinely optional, related settings.
- Keep mutable state owned by one clear component. Avoid mutable package globals and `init`; pass dependencies and policy explicitly.
- Use generics only when they clarify a repeated, type-safe operation. Prefer a simpler concrete API when generic constraints obscure behavior.

## Errors, Security, and Resource Lifecycle

- Accept `context.Context` first for request-scoped or cancellable work, propagate it to downstream I/O, and never store it in a struct.
- Handle every error. Add operation context and wrap with `%w`; branch with `errors.Is` or `errors.As`, never error strings. Use sentinel or typed errors only when callers must branch on them.
- Reject invalid values before side effects. Make retries, idempotency, limits, deadlines, and ownership explicit.
- Keep secrets and sensitive data out of source, logs, and returned errors. Bound untrusted request bodies, reads, writes, and concurrency.
- Configure HTTP client, server, dial, and TLS timeouts; defer closes immediately after successful acquisition.
- Never start a goroutine without an owner, cancellation path, error path, and completion or join behavior. Synchronize shared mutable state and test changed concurrent paths with the race detector.
- Avoid `panic` outside unrecoverable startup.

## Performance

- Measure before optimizing. Avoid unnecessary allocation and copying, preallocate known collection sizes, and batch remote work when it reduces round trips without weakening limits or failure handling.

## Testing

- Test observable behavior through public or package-level APIs, using table-driven cases when cases share setup and assertions.
- Test success, boundary, invalid-input, and failure behavior changed by the work. Assert errors with `errors.Is` or `errors.As`, not complete strings.
- Keep fixtures local, minimal, and deterministic. Use `t.TempDir`, `t.Cleanup`, injected clocks or randomness, and `httptest`; never rely on test order, wall-clock timing, network access, or package globals.
- Test unexported details only when package-level behavior cannot express the invariant. Avoid mocks unless the dependency boundary must be controlled; prefer small fakes owned by the consumer test.

## Quality Gates

Use repository commands first. Otherwise format changed Go files, run `go vet ./...`, then `go test ./...`; run `go test -race ./...` for changed concurrent code. No applicable failed or skipped gate permits a completion claim.
