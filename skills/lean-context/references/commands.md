# Command reference

## Locate

| Goal | Command |
| --- | --- |
| Files matching a name | `rg --files \| rg 'invoice'` |
| Which files mention a symbol | `rg -l 'resolveConfig'` |
| Line numbers, no context | `rg -n 'resolveConfig'` |
| Match with context | `rg -n -B 5 -A 20 'resolveConfig'` |
| Whole-word, avoid false hits | `rg -n -w 'retry'` |
| Types only, skip strings/comments | `rg -n -t py 'def resolve'` |
| Count matches per file | `rg -c 'TODO'` |
| Exclude noise | `rg -n 'x' -g '!**/*.min.js' -g '!dist/**'` |
| Search only tracked files | `git grep -n 'symbol'` |

Search from the narrowest directory that could contain the answer, not the repo root.

## Read a slice

```bash
wc -l src/server.ts                 # size before reading
sed -n '120,180p' src/server.ts     # a range
head -n 60 src/server.ts            # the top
tail -n 40 logs/build.txt           # the bottom (errors live here)
rg -n -A 25 'function handleRequest' src/server.ts   # one function
```

Language-aware outline when available: `ctags -x --_xformat='%n %K %S' file`, `npx ts-morph`-style scripts, or `rg -n '^\s*(export\s+)?(async\s+)?(function|class|const|interface|type|def|func)\b' file`.

## Git archaeology without reading everything

```bash
git log --oneline -15 -- path/to/file     # its recent history
git log -S 'removedSymbol' --oneline      # when a string appeared or vanished
git blame -L 120,140 path/to/file         # who last touched these lines
git log -1 --stat <sha>                   # what a commit touched
git diff --stat main...HEAD               # shape of a branch
git show <sha> -- path/to/file            # one file from one commit
```

Prefer `-S`/`-G` pickaxe searches over browsing history. Prefer `git diff --stat` over an untrimmed `git diff`.

## Without `rg`

```bash
grep -rn --exclude-dir={node_modules,.git,dist,build} 'symbol' .
grep -rn -w 'retry' src/ | head -n 40
find . -name '*.ts' -not -path '*/node_modules/*' | head -n 50
```

## Output caps

Append one of these to any command whose output you cannot bound:

```bash
| head -n 40
| tail -n 40
| wc -l
| cut -c1-200
```

## Tool-call batching

Good — one message, four independent lookups:

```
rg -n 'parseArgs' src/
rg --files src/ | rg 'config'
git log --oneline -10 -- src/config.ts
wc -l src/config.ts
```

Bad — same information, four round trips, each one re-sending the whole conversation prefix.
