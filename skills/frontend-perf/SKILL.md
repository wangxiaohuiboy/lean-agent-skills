---
name: frontend-perf
description: Diagnose and fix front-end performance with a measure-first loop covering Core Web Vitals, bundle size, and render cost. Use when a page is slow, a bundle grew, INP or LCP regressed, or before shipping a performance-sensitive change. Not for backend or database performance.
---

# Frontend Performance

Performance work without a measurement is guessing, and guessing produces `useMemo` sprinkled across a codebase that was slow for an unrelated reason. Always name the metric and the number before proposing a fix.

## Measure first

State three things before touching code:

1. **Which metric is bad** — LCP, INP, CLS, TTFB, bundle size, or a specific interaction.
2. **The current number** — from field data if available, otherwise a lab measurement.
3. **Where the time goes** — the top offender from a trace, a flame chart, or a bundle report.

"Feels slow" is not a finding. Neither is "Lighthouse said 71".

Field data (RUM, `web-vitals` reports, CrUX) says what users actually experience. Lab data (Lighthouse, Performance panel) says why. When they disagree, trust the field and use the lab to explain it. Lighthouse scores vary run to run — take three runs and compare medians, not single scores.

Targets: LCP under 2.5s, INP under 200ms, CLS under 0.1. For initial JS, roughly 170KB gzipped per route is a useful alarm line, not a law.

## Triage by metric

**LCP** — find the LCP element first; the fix depends on what it is.

- Image: serve the right size and format (AVIF/WebP), set `fetchpriority="high"` on the hero, preload it, and never lazy-load above the fold.
- Text: web font blocking → `font-display: swap`, self-host, subset, preload the one weight you use.
- Blocking work: critical CSS inlined, non-critical CSS deferred, JS split and deferred, third-party scripts loaded after the main content.

**INP** — long tasks over 50ms are the usual cause.

- Find them in the Performance panel or a `PerformanceObserver` with `longtask`.
- Break long work up: `await scheduler.yield()` between chunks, or time-slice with `setTimeout`.
- Reduce render work: colocate state so a keystroke does not re-render the tree, move non-urgent updates into `startTransition`, debounce what genuinely needs it.
- Virtualize lists only when DOM node count is the measured bottleneck, not by default.
- Add `useMemo`/`memo` only where a profile shows the re-render is expensive. Blanket memoization adds cost and hides the real problem.

**CLS** — reserve space before content arrives.

- Set `width`/`height` or `aspect-ratio` on every image and embed.
- Never inject banners, ads, or notices above existing content.
- Font swap shifting layout → use a metric-compatible fallback with `size-adjust`, or preload.

## Bundle size

Measure before trimming:

```bash
npx vite build && npx vite-bundle-visualizer        # Vite
npx next build                                       # route-by-route table
npx webpack --profile --json | npx webpack-bundle-analyzer
npx source-map-explorer 'dist/assets/*.js'
npm ls <package>                                     # duplicate copies?
```

Recurring wins, in rough order of payoff:

- Import from the specific module rather than a barrel file (`lodash/debounce`, not `lodash`).
- Replace a heavy dependency with the platform: `moment` → `Intl`/`Temporal`, a date library for `Intl.DateTimeFormat`, a classnames package for a template literal.
- Dynamic-import what is below the fold: modals, editors, charts, admin panels, anything behind a click.
- Drop polyfills your targets do not need.
- Check for two copies of the same library at different versions — a real and common bloat source.
- Ship no source maps to production; keep them for error reporting only.

## Images and network

- Correct intrinsic dimensions and a `srcset`/`sizes` pair so a phone does not download a desktop image.
- Lazy-load below the fold only. Above-the-fold lazy-loading delays LCP.
- `preconnect` for critical third-party origins; `dns-prefetch` for the rest.
- Cache immutable assets with long `max-age` and a content hash in the filename.

## Keep it a loop

Baseline number → one change → re-measure the same way → keep or revert. One change at a time, or you cannot attribute the improvement. Revert changes that do not move the number, even if they look like good practice.

Report the before and after numbers and how they were measured. If you could not measure, say the change is unverified rather than implying an improvement.

## Do not

- Add a caching, memoization, or virtualization layer before profiling.
- Optimize the lab score while field data shows a different bottleneck.
- Shave 4KB off the bundle while a 3MB hero image dominates LCP.
- Trust a single Lighthouse run, or a score reported without the metric that produced it.
