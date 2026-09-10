#!/usr/bin/env bash
# Install these skills into one or both agent skill directories.
#
#   ./scripts/install.sh                 # Codex and Claude Code, if present
#   ./scripts/install.sh --target codex  # Codex only
#   ./scripts/install.sh --target claude # Claude Code only
#   ./scripts/install.sh --link          # symlink instead of copy (for editing)
#   ./scripts/install.sh --dry-run
#
# Existing skills with the same name are moved aside, never deleted.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/skills"

TARGETS=""
MODE="copy"
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGETS="${2:?--target needs a value}"; shift 2 ;;
    --link) MODE="link"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

CODEX_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
CLAUDE_DIR="$HOME/.claude/skills"

dest_dirs() {
  case "${TARGETS:-auto}" in
    codex) printf '%s\n' "$CODEX_DIR" ;;
    claude) printf '%s\n' "$CLAUDE_DIR" ;;
    all) printf '%s\n%s\n' "$CODEX_DIR" "$CLAUDE_DIR" ;;
    auto)
      if [ -d "$(dirname "$CODEX_DIR")" ]; then printf '%s\n' "$CODEX_DIR"; fi
      if [ -d "$(dirname "$CLAUDE_DIR")" ]; then printf '%s\n' "$CLAUDE_DIR"; fi
      ;;
    *) echo "unknown --target: $TARGETS" >&2; exit 2 ;;
  esac
  return 0
}

DESTINATIONS="$(dest_dirs)"
if [ -z "$DESTINATIONS" ]; then
  echo "No skill directory found. Create one first, or pass --target codex|claude|all." >&2
  exit 1
fi

install_one() {
  src="$1"; dest_root="$2"; name="$(basename "$src")"; dest="$dest_root/$name"

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "would install $name -> $dest ($MODE)"
    return
  fi

  mkdir -p "$dest_root"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "  backed up existing $name -> $backup"
  fi

  if [ "$MODE" = "link" ]; then
    ln -s "$src" "$dest"
  else
    cp -R "$src" "$dest"
  fi
  echo "  installed $name -> $dest"
}

while IFS= read -r dest_root; do
  echo "$dest_root"
  for src in "$SKILLS_SRC"/*/; do
    [ -f "${src}SKILL.md" ] || continue
    install_one "${src%/}" "$dest_root"
  done
done <<EOF
$DESTINATIONS
EOF

echo
if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run only. Re-run without --dry-run to install."
else
  echo "Done. Restart your agent session so the skills are discovered."
fi
