# React Reference

## Scope and Composition

Apply when editing React or React-based framework code. Also apply `typescript.md` when TypeScript is used and `frontend.md` for browser-facing work; those references own language rigor and general UI behavior.

## Implementation Workflow

1. Define state ownership, rendering boundary, data contract, and user-visible states.
2. Prefer server rendering; introduce client components only for browser APIs, interactivity, or client-only state.
3. Validate and authorize mutations on the server before wiring UI state.
4. Implement effects, cleanup, and stale-result protection before performance optimization.
5. Test visible state transitions and interaction outcomes.

## Architecture, Organization, and Naming

- Keep components focused on one UI concern. Co-locate a component, focused tests, and private helpers; split independently testable interactions into child components or hooks.
- Use composition for meaningful variation. Do not accumulate boolean props, create generic components, or add abstractions without multiple clear consumers.
- Keep component declarations outside component bodies unless remounting is intentional. Use stable domain keys; never use list indexes for changing lists.
- Give components, props, callbacks, and hooks domain-oriented names. Hooks expose one explicit responsibility and a small named API; do not hide mutation, navigation, or I/O behind ambiguous names.

### File Order

Organize a component file around its primary component; do not move state, effects, or handlers out of their owner to satisfy mechanical ordering:

1. Framework directive such as `'use client'`, when required.
2. Imports following the TypeScript reference; place component-local styles according to repository convention.
3. Exported prop types and narrow public constants.
4. The main exported component.
5. Component-local private types and constants.
6. Private child components that are not independently reusable.
7. Focused hooks, event helpers, and formatting helpers after components, unless co-location with their sole consumer reads more clearly.

Order test code as imports, render or setup helpers, then user-observable tests ordered by state transition. Keep styles organized through the repository's established styling mechanism.

## State, Effects, and Data Flow

- Keep state local with one owner. Derive values during render; do not mirror derived state in effects or state variables.
- Use event handlers for user-triggered work. Use effects only to synchronize with external systems, with complete dependencies and cleanup, cancellation, or stale-result guards.
- Keep server and client boundaries explicit. Start independent data work concurrently, avoid client/server duplicate fetches, and minimize client JavaScript and server-to-client payloads.

## Errors, Security, and Lifecycle

- Treat client checks as UX only; validate and authorize every mutation on the server. Treat URLs, storage, API data, and rendered HTML as untrusted.
- Do not use dangerous HTML APIs without approved sanitization. Ensure effects unsubscribe, abort, or ignore stale work when their component lifecycle ends.

## Performance

- Measure before adding complexity. Memoize, lazy-load, virtualize, or split components only when profiling shows a user-visible benefit that exceeds the added lifecycle cost.

## Testing

- Test user-observable rendering, interactions, accessible outcomes, and state transitions rather than component or hook internals.
- Cover effect cleanup and request races, server/client boundary failures, loading, empty, error, retry, and failed-network behavior changed by the work.

## Quality Gates

Run formatter, lint, typecheck, unit and integration tests, production build, and available browser accessibility checks. For changed forms, dialogs, menus, navigation, or async flows, verify keyboard-only operation, focus management, loading/error/empty states, and failed-network behavior. Treat hydration warnings, accessibility violations, bundle regressions, and console errors as failures.
