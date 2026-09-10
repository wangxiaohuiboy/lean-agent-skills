---
name: frontend-craft
description: Build or review web UI that looks deliberate instead of machine-generated. Use when creating a page or component, restyling an existing screen, or when the user says the UI works but looks generic, templated, or like AI output. Not for pure logic or backend changes.
---

# Frontend Craft

Default model output converges on the same page: centered hero, gradient text, three identical cards, emoji icons, `border-radius: 12px` on everything. That look is recognizable and it reads as unfinished. Make choices instead.

## Lock the system before composing

Decide these first, then derive every value from them. No magic numbers scattered through markup.

- **Type scale** — three or four sizes, with a visible jump (ratio ~1.25 or more). A page where everything is 14-18px has no hierarchy.
- **Spacing scale** — one 4- or 8-based step series. Gaps come from the scale, not from `margin: 13px`.
- **Color** — one accent, a neutral ramp, and a semantic set (success/warning/danger). Body text and surfaces come from the ramp.
- **Radius and elevation** — at most two radii and one or two shadow tiers. Use elevation to mean "above", not to decorate.
- **Font stack** — choose deliberately. A distinctive display face for headings plus a readable body face beats system default everywhere.

`assets/tokens.css` has a starting point — copy it and adjust rather than inventing values inline.

## Anti-patterns that read as templated

Remove these unless there is a real reason for them:

- Purple-to-blue gradients on hero, buttons, and headings at once.
- Gradient-clipped heading text.
- Glassmorphism blur on a card that has nothing behind it.
- Three or four identical feature cards, each with an emoji as the icon.
- Emoji as the entire icon system.
- Everything centered; no alignment axis to scan.
- Shadow plus border plus large radius on every container.
- Placeholder copy left in a demo ("Lorem ipsum", "Feature One", "Item 1").
- Gray text at low opacity for secondary content, hurting contrast for the sake of hierarchy.
- Full-width sections with no layout idea beyond stacking blocks.

Pick at least one deliberate move instead: an asymmetric split, a real grid with intentional spans, one full-bleed moment, an oversized numeral or label, an editorial type pairing, a strong left alignment edge. Have a point of view and apply it consistently.

## Copy is part of the design

Write real labels, real empty states, and real error messages in the UI. "No invoices yet — the first one appears as soon as a client is billed" is design work. "No data" is not. If the user has not supplied copy, write plausible product copy rather than filler, and flag it as placeholder in your report.

## Build the states, not just the happy path

A component is not finished at the default state:

- **Loading** — a skeleton shaped like the content for content areas; a spinner only for short, unbounded actions; disable the trigger and keep it visible.
- **Empty** — explain what will appear and offer the one action that creates it.
- **Error** — say what failed, keep what the user typed, offer retry.
- **Disabled and busy** — visually distinct, still readable.
- **Overflow** — long titles, long names, no spaces, RTL text, and 0/1/1000 items.
- **Focus and hover** — visible, and not the only way to know a control is interactive.

## Motion earns its place

- Keep transitions in the 120-250ms range with an ease-out curve.
- Animate `transform` and `opacity`. Animating layout properties (`width`, `height`, `top`, `margin`) forces reflow and usually looks worse.
- Motion should communicate: entering, leaving, changing state, confirming. It should not decorate a static layout.
- Always honor `prefers-reduced-motion` — reduce to a state change with no travel.
- Nothing animates on a delay the user cannot skip, and nothing moves under the pointer.

## Responsive means the narrow case

Design the narrow layout first, then widen. Verify at 320px, not just at a tablet width. Use `clamp()` for fluid type, `min()`/`max()` for sizing, and container queries when a component is reused at different widths. Do not hide core functionality on small screens to make the desktop layout survive — restructure it.

## Verify by looking

Render the result and inspect a screenshot before claiming it is done, including the empty and error states. Compare against the intended hierarchy, not just "does it appear". If you cannot render it, say so explicitly rather than describing it as finished. For a full accessibility pass, use the `frontend-a11y` skill.
