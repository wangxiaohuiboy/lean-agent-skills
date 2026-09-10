#!/usr/bin/env bash
# Self-check for scripts/install.sh: installs into a throwaway HOME and asserts
# the outcome. Run directly: bash tests/install_test.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$REPO_DIR/scripts/install.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "ok - $*"; }

expected_names() { ls "$REPO_DIR/skills"; }

# 1. --dry-run creates nothing
HOME="$WORK/home1" bash "$INSTALL" --target codex --dry-run >/dev/null
[ ! -e "$WORK/home1/.codex/skills" ] || fail "dry run created the target directory"
pass "dry run leaves the filesystem alone"

# 2. a plain install lands every skill with its SKILL.md
HOME="$WORK/home2" bash "$INSTALL" --target codex >/dev/null
count=0
while read -r name; do
  [ -f "$WORK/home2/.codex/skills/$name/SKILL.md" ] || fail "$name/SKILL.md missing after install"
  count=$((count + 1))
done < <(expected_names)
[ "$count" -gt 0 ] || fail "no skills found in the repo"
pass "installed $count skills with SKILL.md present"

# 3. references and assets travel with the skill
[ -f "$WORK/home2/.codex/skills/lean-context/references/commands.md" ] || fail "references/ was not copied"
[ -f "$WORK/home2/.codex/skills/frontend-craft/assets/tokens.css" ] || fail "assets/ was not copied"
pass "supporting references and assets are copied"

# 4. an existing skill is moved aside, not deleted
printf 'old\n' > "$WORK/home2/.codex/skills/lean-diff/SKILL.md"
HOME="$WORK/home2" bash "$INSTALL" --target codex >/dev/null
backups=$(find "$WORK/home2/.codex/skills" -maxdepth 1 -name 'lean-diff.bak.*' | wc -l | tr -d ' ')
[ "$backups" = "1" ] || fail "expected 1 timestamped backup, found $backups"
grep -q '^name: lean-diff$' "$WORK/home2/.codex/skills/lean-diff/SKILL.md" || fail "fresh copy missing after reinstall"
pass "existing skill backed up and replaced"

# 5. --link symlinks back to the repo, so edits show up live
HOME="$WORK/home3" bash "$INSTALL" --target codex --link >/dev/null
[ -L "$WORK/home3/.codex/skills/lean-diff" ] || fail "--link did not create a symlink"
grep -q '^name: lean-diff$' "$WORK/home3/.codex/skills/lean-diff/SKILL.md" || fail "symlink does not resolve to the repo copy"
pass "--link symlinks to the working tree"

# 6. auto-detection finds an existing agent directory
mkdir -p "$WORK/home4/.codex"
HOME="$WORK/home4" bash "$INSTALL" >/dev/null
[ -f "$WORK/home4/.codex/skills/lean-diff/SKILL.md" ] || fail "auto target did not install"
pass "auto-detects an existing Codex directory"

# 7. --target claude installs into ~/.claude/skills
HOME="$WORK/home5" bash "$INSTALL" --target claude >/dev/null
[ -f "$WORK/home5/.claude/skills/lean-diff/SKILL.md" ] || fail "--target claude did not install"
pass "--target claude installs into ~/.claude/skills"

echo "all install checks passed"
