---
name: apply-best-practices
description: Apply production engineering best practices after identifying a repository's supported stack. Use when implementing, reviewing, or refactoring Go, Rust, TypeScript, React, Vue, or frontend code and no more specific repository instruction takes precedence.
---

# Apply Best Practices

## Role

Act as a senior software engineer responsible for production systems, security, and maintainable codebases. Optimize for correctness, clarity, explicit data flow, predictable failure behavior, and low cognitive load.

Treat project instructions, established local conventions, and executable checks as authoritative. This skill supplies defaults when they are absent; it does not replace repository-specific rules.

## Workflow

### 1. Establish context

Before changing code, inspect the applicable repository instructions, manifests, configuration, nearby code, tests, and validation scripts. Confirm the task's behavior, boundary, and affected stack.

Use evidence rather than assumptions. Ask a focused question only when the necessary decision cannot be resolved from the repository or request.

### 2. Select references

Load only the relevant reference files:

| Signal | Reference |
| --- | --- |
| `go.mod`, `.go` files | `references/go.md` |
| `Cargo.toml`, `.rs` files | `references/rust.md` |
| `tsconfig*.json`, TypeScript sources | `references/typescript.md` |
| React dependencies or `.tsx` files | `references/react.md` and `references/typescript.md` when TypeScript is used |
| Vue dependencies or `.vue` files | `references/vue.md` and `references/typescript.md` when TypeScript is used |
| Browser UI, framework components, HTML, CSS, or styling work | `references/frontend.md` |

For mixed stacks, apply every relevant reference, resolving conflicts in this order: explicit user requirement, repository rule, framework-specific reference, language reference, frontend reference, then this skill.

Do not apply a reference when its detection signal is absent. Bash has no reference in this skill yet; follow project instructions and the ecosystem's installed tooling instead.

### 3. Implement deliberately

Use this order: define the behavior, invariants, state ownership, and trust boundaries; inspect existing patterns; write or update focused tests; implement the smallest coherent change; validate every relevant state and failure path; run quality gates; inspect the final diff.

For browser-facing changes, use native semantic structure before framework mechanics, implement keyboard and focus behavior before visual polish, then verify responsive, localized, loading, empty, error, permission, and retry states.

- Validate external input at the boundary and preserve meaningful errors.
- Keep code organized by cohesive domain or feature, with explicit ownership and stable module boundaries. Prefer one concept per file and co-locate its focused tests and private helpers.
- Name files, modules, functions, types, components, state, and events for domain intent; reject generic `util`, `helper`, `manager`, `data`, or `handler` names.
- Treat code style and organization as correctness concerns: preserve established formatter and lint conventions; do not add abstractions, exports, layers, or indirection without demonstrable reuse or a boundary they protect.
- Treat warnings from compilers, linters, tests, and analyzers as actionable.
- Do not hide failures with broad catches, unsafe casts, suppressions, or disabling checks without an explicit, justified reason.
- Do not add comments unless they explain a non-obvious reason or constraint.

### 4. Validate

Resolve commands in this order: repository instructions; `mise` tasks; `just` recipes; Go Task (`task`); then the stack's native commands. Do not bypass an available project task runner for an equivalent native command.

Run quality gates in this order: formatter, lint, typecheck, targeted tests, the relevant full suite, production build or framework check, then browser and accessibility checks when applicable. If no documented command exists, identify the available tooling from manifests and configuration before choosing the narrowest appropriate checks.

Inspect the final diff. Correct failures introduced by the change. Do not report completion with a skipped or failing applicable gate; report unrelated pre-existing failures and unavailable validation separately.

## Completion

State the selected references, behavior and state cases verified, commands run with results, and material limitations. Do not claim validation that did not run.
