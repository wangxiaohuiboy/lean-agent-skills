# Worked examples

Each example shows the over-built answer, the rung that replaces it, and the trade-off.

## 1. "Add a date formatting helper"

Over-built: a `DateFormatter` class with locale config, a `formatters.ts` module, and unit tests.

Rung 3 (standard library):

```js
new Intl.DateTimeFormat(locale, { dateStyle: 'medium' }).format(date)
```

Trade-off: none worth mentioning. Delete the class.

## 2. "Debounce the search input"

Over-built: `npm i lodash` for one call site.

Rung 7 (minimum code) — five lines, no dependency, with the two details a naive debounce gets wrong:

```js
let timer
const debounced = (fn, ms = 250) => (...args) => {
  clearTimeout(timer)
  timer = setTimeout(() => fn(...args), ms)
}
```

Preserves the latest arguments and cancels the pending call. It does not implement `leading`/`trailing`/`cancel` — nobody asked for them.

## 3. "Add a retry to this fetch"

Over-built: a generic `withRetry` higher-order function with a strategy interface.

Rung 6 (can it be a few lines):

```js
// lean: fixed 3 attempts, no backoff jitter. Upgrade: exponential backoff if
// providers start rate-limiting.
async function fetchWithRetry(url, options, attempts = 3) {
  for (let i = 1; ; i++) {
    try { return await fetch(url, options) }
    catch (err) { if (i >= attempts) throw err }
  }
}
```

Note the deliberate-shortcut comment. That is the whole point: the ceiling is named, not hidden.

## 4. "Make this list scroll smoothly with 5,000 rows"

Over-built: rewrite the page with a virtualized table library and a state library.

First, measure. If profiling shows a re-render storm from a state update above the list, the fix is colocating the state (one-line move), not new dependencies. Add virtualization only if the DOM node count is genuinely the bottleneck.

## 5. Bug report: "saving a draft with an empty title crashes"

Over-built (and wrong): guard inside the `saveDraft` handler, next to the reported crash.

Root cause: `rg -n 'normalizeTitle\('` shows the same unguarded call in the autosave path and the API import path. The fix belongs in `normalizeTitle` itself — one guard, three callers fixed, smaller diff than three guards.

## 6. "Add a config option for the API base URL"

Over-built: a config module, env parsing, a defaults layer, validation, and a docs table.

Rung 5 (platform): the bundler already exposes env vars, and the build already defines `import.meta.env`. Read that value where it is used. If a second consumer ever appears, then extract it.

## Deciding between rungs 2 and 7

If the repo has a helper that is 80% right, prefer adapting the call over generalizing the helper. Generalizing an existing helper touches its other callers — a wider blast radius for the same outcome.

## When lean is wrong

Say so plainly when the request is genuinely architectural: a new service, a public API that must stay stable, a data migration, a security boundary. Those deserve structure. Lean applies to the 90% of day-to-day requests that do not need it.
