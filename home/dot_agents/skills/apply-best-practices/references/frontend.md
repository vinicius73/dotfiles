# Frontend Reference

## Scope and Composition

Apply to every browser-facing UI change, including React, Vue, HTML, and CSS. This reference owns semantic HTML, accessibility, interaction, responsive behavior, browser-state requirements, and shared UI testing.

## Implementation Workflow

1. Define user goals, data ownership, trust boundaries, and every visible state.
2. Build native semantic structure before styling or custom interaction.
3. Implement keyboard and focus behavior before visual polish.
4. Handle responsive layout, zoom, localization, reduced motion, and failure states.
5. Measure bottlenecks before optimization and validate the complete interaction.

## Architecture, Organization, and Naming

- Organize by feature: co-locate a component, its styles, tests, and narrow private helpers. Keep page orchestration separate from reusable presentational primitives.
- Make information hierarchy explicit: one primary task per view, content ordered by user priority, and progressive disclosure for secondary actions. Never rely on position, color, or icon alone to communicate meaning.
- Name components for domain intent, props for behavior, CSS classes for the owning component and role, and state variants explicitly. Avoid visual names, ambiguous booleans, and modifier combinations that permit invalid states.
- Do not create generic components until behavior and API are proven reusable. Reuse established patterns for actions, menus, dialogs, selection, validation, loading, destructive confirmation, and notifications.
- Use design tokens for repeated color, typography, spacing, sizing, radius, shadow, z-index, and motion values. Use semantic tokens such as `--color-danger`, not raw palette values outside token definitions or intentional artwork.

### CSS and HTML File Order

Keep token, global, and component styles separate because they have different ownership:

- A token file contains cascade-layer declaration when used, primitive and semantic token definitions, alternate-theme overrides, and no component selectors.
- A global stylesheet contains required directives, cascade layers, reset or normalization, document and typography defaults, shared accessibility utilities, deliberate global layout primitives, then ordered global responsive overrides.
- A component stylesheet or CSS module contains the component root, descendant roles in markup order, explicit state variants, interactive states beside their base control, mobile-first overrides, then reduced-motion overrides.

Order HTML by the document outline and user task: doctype; `<html lang>`; a `<head>` containing encoding, viewport, title, metadata, preload or styles, and necessary deferred modules; then a `<body>` containing skip link, header and navigation, main with one visible `<h1>` and user-priority content, contextual aside, footer, and only required dialogs or live regions. Put deferred scripts before `</body>` when they do not belong in the head.

## State, Navigation, and Async UX

- Model initial, loading, success, empty, partial, error, retry, disabled/submitting, and permission-denied states where applicable. Prevent stale or out-of-order responses and duplicate submissions.
- Keep meaningful state in the URL when deep links, reloads, browser navigation, or sharing must preserve it. Parse and validate URL state at the browser boundary.
- Label fields, associate validation errors with controls, preserve input after recoverable failure, and focus the primary error when submission fails.
- Treat HTML, URLs, storage, API data, and third-party content as untrusted. Sanitize approved rich content before rendering and never construct unsafe navigation or markup from unvalidated data.

## Semantic HTML, Accessibility, and Interaction

- Use one visible `<h1>` and a logical heading hierarchy. Prefer real `<button>`, `<a>`, `<label>`, and form semantics; never add click handlers to non-interactive elements.
- Use ARIA only when native semantics cannot express the behavior. Every interactive control needs an accessible name, visible focus, logical tab order, and complete keyboard behavior.
- Move focus into newly opened dialogs, restore it when they close, and support `Esc` for dismissible overlays. Do not cause unexpected focus, scroll, color-only, motion-only, or hover-only feedback.
- Use meaningful alternative text for informative images and empty alternative text only for decorative ones. Reserve media and embed dimensions to prevent layout shift.

## Responsive Design and Visual Consistency

- Structure CSS mobile-first: base rules followed by ordered min-width breakpoints. Keep responsive overrides adjacent to base styles; use `grid`, `flex`, `minmax`, and `clamp` before breakpoint-specific branches.
- Support 200% zoom, narrow viewports, user font preferences, localization, sufficient contrast, and `prefers-reduced-motion`. Animate only when it improves comprehension and only compositor-friendly properties.

## Performance

- Prefer server-rendered or static data when sufficient. Defer non-critical code, virtualize genuinely large lists, and avoid expensive work during render or input.
- Measure Core Web Vitals before adding optimization complexity. Preserve correctness, accessibility, and state behavior when optimizing payloads, rendering, or network work.

## Testing

- Test observable behavior by role, label, and user-visible outcome; do not assert component internals, generated classes, or implementation-specific DOM structure.
- Cover keyboard operation, focus transitions, accessible names and roles, validation, async success and failure, disabled states, responsive overflow, and fixed-defect regressions.

## Quality Gates

Run formatter, lint, typecheck, focused UI tests, production build, and an automated accessibility scan when available. Perform a keyboard-only walkthrough at 200% zoom, narrow viewport, and reduced motion. Verify loading, error, empty, retry, permission, failed-network, and long or localized-content states. Do not mark work complete with an introduced accessibility, console, hydration, visual-overflow, or performance failure.
