# lean-agent-skills

Seven agent skills for people who pay for tokens and care what the output looks like.

Four skills cut the cost of a coding session — less context read, less code written, fewer words returned. Three are front-end craft skills that push UI past the default generated look, measure real performance, and clear a WCAG AA pass.

Skills work in Codex, Claude Code, and any agent that reads `SKILL.md` files. Each one loads only its short description until it is actually used, so installing all seven costs almost nothing at rest.

[中文说明](README.zh-CN.md)

## What's inside

### Token-efficient work

| Skill | What it does | Fires when |
| --- | --- | --- |
| [`lean-context`](skills/lean-context) | Attaches a question to every file read, searches before reading, reads the narrowest range, batches independent lookups, and never re-reads | Orienting in a repo, tracing a bug, hunting a symbol |
| [`lean-diff`](skills/lean-diff) | A seven-rung solution ladder (YAGNI → reuse → stdlib → platform → existing dep → one line → minimum code), root-cause bug fixes, deliberate shortcuts marked with their ceiling | Any feature, fix, or refactor where scope discipline matters |
| [`lean-answer`](skills/lean-answer) | Answer first, no preamble or postamble, references instead of quoting, structure sized to content | When you ask for brevity, or many small requests in a row |
| [`context-handoff`](skills/context-handoff) | Compresses a long session into a resumable brief: goal, state, decisions, tried-and-failed, next action, landmines | Before a new thread, when context runs low, when handing off to a teammate |

### Front-end

| Skill | What it does | Fires when |
| --- | --- | --- |
| [`frontend-craft`](skills/frontend-craft) | Locks a design system before composing, lists the anti-patterns that read as machine-generated, and covers states, motion, and the narrow layout. Ships a starter `tokens.css` | Building or restyling a page or component |
| [`frontend-perf`](skills/frontend-perf) | Measure-first loop over LCP, INP, CLS, and bundle size, with the concrete fixes for each | A page feels slow, a bundle grew, a metric regressed |
| [`frontend-a11y`](skills/frontend-a11y) | An ordered WCAG 2.2 AA pass: keyboard, semantics, names, focus, forms, contrast, motion, live regions | Shipping UI, reviewing a component, a reported blocker |

## Install

### Codex

```bash
git clone https://github.com/wangxiaohuiboy/lean-agent-skills
./lean-agent-skills/scripts/install.sh --target codex
```

This copies each skill into `${CODEX_HOME:-~/.codex}/skills/`. Existing skills with the same name are moved aside with a timestamp, never deleted. Add `--link` to symlink instead of copy, so edits in the clone take effect immediately. Restart the session afterward.

### Claude Code

```bash
./lean-agent-skills/scripts/install.sh --target claude
```

Copies into `~/.claude/skills/`. Use `--link` the same way.

### Anywhere else

Copy a skill directory into wherever your agent discovers skills, or paste the body of a `SKILL.md` into your rules file. The skills are plain Markdown with `name` and `description` frontmatter, and each `references/` file is read only when the skill asks for it.

## Design notes

Skills are instructions an agent loads on demand, so they are held to the standard of the best code review comment: say the thing that is not obvious, cut the thing that is.

- **Nothing generic.** "Write clean code" and "test your work" change no decision. Everything in here is a rule with a specific trigger, a specific exception, or a specific number attached.
- **Disagree out loud.** `lean-diff` says when *not* to be lean. `frontend-perf` says when memoization is the wrong fix. A skill that only agrees is not doing work.
- **Cost scales with use.** The name and description are visible during skill selection. The body loads only on activation. Deep detail lives in `references/`, loaded only when that branch applies.
**Activation cost is small.** Each body is 700-1,250 tokens when the skill is active, and zero when it is not. The deep detail is in `references/`, which is read only when that branch applies.
- **Carve-outs are explicit.** Validation at trust boundaries, data-loss handling, security, accessibility, and real-hardware behavior are never the things you skip to save tokens.

### Credit

The solution ladder and the "mark deliberate shortcuts with their ceiling" idea are adapted from [Ponytail](https://github.com/DietrichGebert/ponytail) by Dietrich Gebert (MIT), which crystallized the lazy-senior-developer framing. The four token skills here reorganize that idea around where the tokens actually go — context read, code written, output returned, and session state carried forward — and add the front-end skills as a separate set.

## Contributing

A skill earns its place by changing a decision. If a rule would not change what an agent does, it belongs in a README, not a skill.

## License

MIT — see [LICENSE](LICENSE).
