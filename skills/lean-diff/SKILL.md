---
name: lean-diff
description: Solve a coding request with the smallest correct change. Use for features, bug fixes, and refactors when scope discipline matters, when the user asks for minimal code, or when prior attempts over-built the solution. Not for greenfield design work where a real architecture is the point.
---

# Lean Diff

The best code is the code that did not need to be written. Be efficient, not careless: a small diff you do not understand is not lean, it is a second bug.

## Read before you climb

The ladder below runs **after** you understand the problem, never instead of it. Read the code the task touches and trace the real flow end to end. Every rung you skip in understanding comes back as a wrong edit.

## The solution ladder

Stop at the first rung that holds:

1. **Does this need to exist at all?** A local script, a manual step, or the feature the user already has may cover it. Say so in one line and propose the smaller option.
2. **Does this repo already do it?** Reuse the existing helper, hook, or pattern. Grep before you write.
3. **Does the standard library do it?** `Intl`, `pathlib`, `URL`, `structuredClone`, `crypto.randomUUID` over a package.
4. **Does the platform do it?** Native `<dialog>`, CSS `clamp()`/`:has()`, `fetch`, file input, `AbortController`, database constraints over application code.
5. **Does an installed dependency do it?** Use what is already in the tree before adding anything.
6. **Can it be one line or a config change?** Do that.
7. **Only then** write the minimum code that works.

## Bug fix means root cause

A bug report names a symptom. Before patching:

1. Find every caller of the function you are about to touch — `rg -n 'functionName\('`.
2. Decide where the invariant actually belongs. One guard at the shared function is usually a smaller diff than one per caller.
3. Fix once, at the narrowest shared point that covers all real callers.

Patching only the path the report names leaves sibling callers broken — that is not a small diff, it is an unfinished one.

## Do not add

- Abstractions that were not requested; an interface with one implementation; a factory with one product.
- Configuration for a value that is used once.
- A dependency for one function.
- Boilerplate, scaffolding, or generated files nobody asked for.
- Error handling for states that cannot occur.
- Tests for trivial one-liners.
- A rewrite of working adjacent code. Leave the neighborhood as you found it.

## Do not skip

Laziness is about code volume, not rigor. These are never on the chopping block:

- Input validation at trust boundaries.
- Error handling that prevents data loss.
- Security, and accessibility.
- Behavior the user explicitly asked for.
- Correct handling of the real platform: clock drift, sensor calibration, partial failures, the network being absent.

When two standard-library approaches are the same size, pick the one that is correct at the edges. Lean means less code, not a flimsier algorithm.

## Mark deliberate shortcuts

When you knowingly take the cheaper option with a real ceiling — an O(n²) scan, a global lock, a naive heuristic, a hard-coded region — leave one line naming the ceiling and the upgrade path:

```js
// lean: global lock; fine below ~1k req/s. Upgrade: per-key sharded locks.
```

This is what separates a deliberate trade-off from an accident.

## Finish with one check

Non-trivial logic leaves **one** runnable check behind — the smallest thing that fails if the logic breaks. Prefer a single test in the repo's existing framework, or a tiny assert-based script when there is none. Do not introduce a test framework, fixtures, or a matrix of cases for a change this size. Trivial one-liners need no test.

## Report the shape of the change

Keep it to a few lines: what changed, what you deliberately did **not** do, and the one thing worth watching. If you skipped a plausible approach, name it in one clause so the user knows it was a decision rather than an oversight.

See `references/ladder-examples.md` for worked examples of each rung.
