# Vue Reference

## Scope and Composition

Apply when editing Vue code. Also apply `typescript.md` when TypeScript is used and `frontend.md` for browser-facing work; those references own language rigor and general UI behavior.

## Implementation Workflow

1. Define the component contract, one owner for each mutable state, and rendering states.
2. Validate untrusted data and protect server-side mutations before wiring UI state.
3. Implement semantic structure, interactions, async cleanup, and stale-response protection.
4. Test state transitions and emitted events.
5. Profile before introducing Vue-specific performance mechanisms.

## Architecture, Organization, and Naming

- Use `<script setup lang="ts">`. Order SFC sections as `<script setup>`, `<template>`, then `<style scoped>`; order script declarations as imports, types, props/emits, state, computed values, effects, handlers, and exposed API.
- Name component files and identifiers in `PascalCase`; composables `useX`; directives `vX`; event handlers `onX`; booleans `is`, `has`, or `can`; and refs for their domain value, not their Vue wrapper.
- One SFC owns one UI concern. Extract a child for an independently testable interaction or a composable for reusable stateful behavior; never create generic utility composables or one-off template helpers.
- A composable has one explicit responsibility, accepts plain inputs or refs deliberately, returns the smallest named API, and owns cleanup for every effect. Do not hide navigation, network mutations, global-state writes, or DOM mutations behind ambiguous APIs.
- Declare props and defaults explicitly with TypeScript. Props are immutable: do not mutate or mirror them in local state. Declare every emitted event with typed `defineEmits` and domain event names.
- Keep styles local and scoped by default. Use design tokens and existing primitives; avoid selector nesting, `!important`, global element rules, and `:deep()` except at intentional integration boundaries.

### File Order

Order every SFC as `<script setup lang="ts">`, `<template>`, then `<style scoped>`.

- In `<script setup>`, order imports, types, props and defaults, typed emits, local state and refs, computed values, watchers or lifecycle effects with cleanup, event handlers, then necessary exposed API.
- In `<template>`, place the semantic root and primary content first, visible state branches in user order (loading, error or retry, empty, success), then secondary controls and content.
- In `<style scoped>`, place the component root, descendant roles in template order, explicit state variants, interactive states adjacent to their base control, mobile-first responsive overrides, then reduced-motion overrides.

Order test code as imports, mount or setup helpers, then rendered-state, emitted-event, interaction, async lifecycle, and accessibility tests.

## State and Reactivity

- Children request changes by emitting events and never mutate parent, store, or route state directly. Reserve `update:modelValue` for actual two-way bindings.
- Keep mutable state at the lowest common owner. Component state stays local; shared feature state belongs in a feature-scoped composable or store; route, server, and browser state remain at their boundaries.
- Prefer `ref` for replaceable values and `reactive` only for deliberate in-place object mutation. Preserve reactivity with `toRef` or `toRefs`; derive values with pure computed properties and never duplicate derived state.
- Use `watch` only for external side effects, never derivation. Watch the narrowest source, avoid `deep` and broad reactive-object watchers, clean up with `onWatcherCleanup`, and prevent stale responses from committing state.

## Errors, Security, and Lifecycle

- Treat client validation as UX only; protect server-side mutations. Never render untrusted content with `v-html`.
- Avoid direct DOM mutation unless a focused composable or directive owns its lifecycle cleanup. Preserve root causes without exposing secrets or sensitive data.

## UI and Framework Behavior

- Use stable domain keys for `v-for`; never use index keys except static lists. Do not combine `v-if` and `v-for` on one element. Use `v-if` for conditional creation and `v-show` only for frequently toggled inexpensive content.

## Performance

- Measure before optimizing. Use `v-once`, `v-memo`, async components, and `KeepAlive` only when profiling proves the benefit exceeds lifecycle complexity.

## Testing

- Test rendered states, user-visible behavior, accessibility, and emitted payloads—not implementation details. Test composables through their public API, including cleanup, cancellation, and stale-response behavior.
- Cover changed loading, empty, error, permission, retry, keyboard, sanitization, URL validation, SSR, and hydration paths where applicable.

## Quality Gates

Run formatter, lint, typecheck, component tests, relevant end-to-end tests, and user-facing validation. Fix every introduced warning and inspect the final diff; no applicable failed or skipped gate permits a completion claim.
