---
name: lean-context
description: Explore an unfamiliar or large codebase while spending the fewest possible tokens. Use when locating a bug, tracing a flow, orienting in a repo, or when context is running low. Not needed once the target file is already known.
---

# Lean Context

Context is the scarcest resource in an agent loop. Every file you read stays in the window and is paid for on every subsequent turn. Spend reads like money.

## The one rule

**Attach a question to every read.** If you cannot state the question the read answers, do not read. "Let me see what this file does" is not a question. "Where does `--retry` get parsed?" is.

## Order of operations

Climb this ladder and stop at the first step that answers the question:

1. **Search** — `rg -n '<symbol>'` returns matching lines with line numbers. Usually this alone answers "where is X".
2. **Outline** — list the file's declarations without reading bodies (`rg -n '^(export |def |class |func |function |const )'` or a language-aware outline).
3. **Bracket the range** — read only the region that matters: `sed -n '120,180p' file`, `rg -n -A 20 -B 5 '<symbol>'`.
4. **Read the file** — only when you are about to rewrite it, or it is genuinely short (< ~200 lines). Check size first: `wc -l`.

Never jump to step 4 because it feels safer. A 40-line targeted read beats a 900-line file in both cost and attention.

## Batch, do not ping-pong

Independent lookups belong in **one** message as parallel tool calls. Five separate round trips cost five times the latency and repeatedly re-send the conversation prefix. Group greps, file listings, and `git log` calls together. Sequence only when one lookup's result determines the next.

## Cap the output

Raw output becomes context; trim it at the source:

- `rg --files | rg 'pattern'` — locate paths without content
- `rg -l` — file lists only, no matches
- `rg -c` — counts only
- `sed -n '1,80p'` — first 80 lines instead of `cat`
- `git diff --stat`, `git log --oneline -15` — shape before detail
- `| head -n 40` — cap any command whose output size you cannot predict

Read build output, lockfiles, minified bundles, generated migrations, and `node_modules` only when the failure is literally inside them, and then only the relevant lines.

## Do not re-read

Re-reading a file you already read, or that you just edited, is the most common waste in an agent loop. If you need a precise line, quote it from what you already have or read a narrow range. After an edit, trust the edit result rather than re-reading the file to confirm it applied.

## Compress as you go

Once you have found what matters, keep only the distilled form in your working memory: `path:line — what it does — why it matters`. Drop the raw dump. When you are about to make a change, you should be able to say where the fix goes and who calls it, from your notes, without re-reading.

## Know when to stop exploring

Stop when you can name (a) the location of the change and (b) the code that calls it. Do not survey the architecture, do not read the neighboring subsystems "for context", do not map the whole call graph. Broader understanding is only worth paying for when the task is actually broad — a refactor, a migration, a design decision.

## Anti-patterns

- Recursively reading every module an entry point imports.
- `cat` on a file you have not measured.
- Reading the test suite to learn a function's behavior instead of reading the function.
- Running a repo-wide `find` from a home directory or over `.git`.
- Asking an agent to "read the codebase and summarize it" instead of asking the specific question.

See `references/commands.md` for the concrete command set, including git archaeology and how to work without `rg`.
