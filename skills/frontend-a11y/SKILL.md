---
name: frontend-a11y
description: Audit and fix web accessibility to WCAG 2.2 AA with a practical, ordered pass over keyboard access, names and roles, focus, contrast, forms, and motion. Use when shipping UI, reviewing a component, or when a user reports that something cannot be reached or read. Not for native desktop or mobile app accessibility.
---

# Frontend Accessibility

Run the pass in this order — it is sorted by how often each item is the actual blocker.

## 1. Keyboard walkthrough

Complete every task using only Tab, Shift+Tab, Enter, Space, Escape, and arrows. This finds more real bugs than any automated tool.

- Every interactive element is reachable and operable.
- DOM order matches visual order. `tabindex` values above 0 are a bug, not a fix.
- No keyboard traps. Escape closes dialogs and menus; focus returns to what opened them.
- A skip link precedes long navigation.
- Custom widgets follow their expected keys: arrows inside a radio group, tabs, listbox, or menu.

## 2. Semantics before ARIA

Use the native element that already does the job: `button`, `a[href]`, `input`, `label`, `dialog`, `details`, `fieldset`. No ARIA is better than wrong ARIA.

- Never attach `onClick` to a `div` or `span` without a role, a `tabindex`, and key handling. Use a `button`.
- `aria-*` overrides rather than describes. Do not "fix" a `div` button with `role="button"` — replace the element.
- Do not add `aria-hidden="true"` to anything focusable.
- Landmarks (`main`, `nav`, `header`, `footer`) and one `h1` per view, with heading levels in order and no levels skipped for styling.

## 3. Accessible names

- Every control has a programmatic name. An icon-only button needs `aria-label`; a visible text label is better when there is space.
- Images: decorative → `alt=""`; meaningful → describe the function or content, not the file. Never "image of".
- Links say where they go: "View invoice 42", not "click here" or "read more". Screen reader users navigate by link list.
- `aria-label` on a control must start with the visible text, or voice control cannot find it. Prefer visible text over an aria override.

## 4. Focus

- Never `outline: none` without a visible replacement. Style `:focus-visible` so pointer users do not see rings but keyboard users always do.
- Move focus deliberately: into a dialog when it opens, to the new heading or main content on route change, back to the trigger on close.
- Target scroll-into-view with `tabindex="-1"`, never `tabindex="0"`.
- Use the native `<dialog>` element (or an established primitive) — it provides focus trapping, Escape, and inert background for free.

## 5. Forms and errors

- Every input has a `<label for>` tied to its `id`. A placeholder is not a label.
- Errors: state the problem and the fix in text, tie it with `aria-describedby`, keep the user's input, and place the message near the field.
- Validate on submit or blur, not on every keystroke.
- Mark required fields, and use `type`, `inputmode`, and `autocomplete` so mobile keyboards and password managers work.
- Group related controls with `fieldset`/`legend`. State that cannot be conveyed by color alone must have text or an icon with text.

## 6. Contrast and text

- Body text 4.5:1 minimum; large text (24px, or 19px bold), UI borders, icons, and focus indicators 3:1.
- Check placeholder, disabled, and secondary text too — these are the usual failures.
- Usable at 200% zoom and at 320px width without horizontal scrolling or clipped content.
- Never `user-scalable=no` or `maximum-scale=1`.
- Size text in `rem` and avoid fixed heights on text containers so user font scaling does not clip.

## 7. Motion and time

- Honor `prefers-reduced-motion`, with a real reduced state rather than a broken animation.
- Any auto-playing motion over 5 seconds can be paused or stopped.
- Nothing flashes more than three times per second.

## 8. Live regions

- `aria-live="polite"` for status updates, counts, and toasts that are not urgent.
- `aria-live="assertive"` (or `role="alert"`) only for errors that require interruption.
- The region must exist in the DOM before its content changes, or the announcement is missed.
- Do not wrap content that renders on page load — that fires on every visit.

## Verify, do not assume

Automated tools (axe, Lighthouse, Lighthouse CI) catch roughly a third of real issues. Use them as a floor, never as sign-off. Run the keyboard pass in section 1 on every audit, and spot-check with a screen reader when the flow is complex — VoiceOver on macOS (`Cmd+F5`, then the rotor with `Ctrl+Option+U`) or NVDA on Windows.

Report each finding as `path:line` + the WCAG criterion + the concrete fix. "Missing accessible name (WCAG 4.1.2) — add `aria-label="Close dialog"`" is actionable; "accessibility improvements needed" is not.

Pair with `frontend-craft` when the fix is a design decision rather than a defect — for example, when the only accessible label is too long for the layout.
