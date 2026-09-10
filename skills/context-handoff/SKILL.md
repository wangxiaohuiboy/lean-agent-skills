---
name: context-handoff
description: Compress a long working session into a resumable brief so a fresh thread, another person, or a later session can continue without re-reading the conversation. Use when context is running low, work pauses mid-task, or a task should move to a new thread.
---

# Context Handoff

A handoff brief exists so the next session does **not** need the transcript. Write it dense, factual, and short — target 300-400 words. Pointers replace content.

## Format

```markdown
## Goal
<one sentence, plus the acceptance criterion: how we know it is done>

## State
- Done: <what landed, with file paths or a commit sha>
- In progress: <exactly where it stopped, path:line>
- Not started: <the remainder, in order>

## Decisions
- <decision> — <the constraint that forced it>. Only decisions that constrain
  future work. Drop anything reversible without cost.

## Tried and failed
- <approach> — <why it failed>. This section is the highest-value part of the
  brief. It is what stops the next session from repeating the work.

## Next action
<the exact next command or edit, specific enough to run without thinking>
```

Add these two sections only when they apply:

```markdown
## Landmines
- <something that looks correct but is not: a flaky test, a generated file that
  must not be edited, a migration already applied to staging, a cached build>

## Unverified
- <claim that was never actually checked, stated so the next session does not
  inherit false confidence>
```

## Rules

- **Pointers, not payloads.** `src/api/retry.ts:44`, not the function body. `git diff 4f2a9c1`, not the diff.
- **Exact identifiers.** Branch name, commit sha, env var name, port, migration id, feature flag spelling. Descriptions get misremembered; identifiers do not.
- **State failures.** A brief that omits the dead ends is a trap.
- **No narrative.** No "first I looked at..., then I decided to...". Only what the next session needs to act.
- **Mark unverified work as unverified.** Tests written but not run, a fix that compiles but was never exercised.
- **Name the files not to touch** when there are trap files, generated artifacts, or a slow command that should be avoided.

## Length discipline

If the brief exceeds a page, it is carrying detail that belongs in the repo — commit messages, code comments, or a notes file. Cut it back to pointers. A handoff that is too long gets skimmed, and the skimmed part is where the landmine was.

## Where to put it

Default to the conversation, so the user can paste it into the new thread. Write it to a file only when the user asks, and prefer that file's repo-appropriate location (for example a `NOTES.md` or the PR description) over an invented path.
