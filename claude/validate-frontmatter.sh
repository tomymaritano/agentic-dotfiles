#!/usr/bin/env bash
# claude/validate-frontmatter.sh — check that every command/agent/skill has
# the YAML frontmatter its type needs, so a malformed file fails here instead
# of silently misbehaving (or not loading) inside a real Claude Code session.
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

# Print the block between the first two '---' lines (the frontmatter body),
# or fail if the file doesn't open with '---'.
frontmatter() {
  awk '
    NR==1 && $0 != "---" { exit 1 }
    NR==1 { started=1; next }
    started && $0 == "---" { exit 0 }
    started { print }
  ' "$1"
}

check() {
  local file="$1"
  shift
  local fm
  if ! fm=$(frontmatter "$file"); then
    echo "✗ $file: missing frontmatter (must start with ---)"
    fail=1
    return
  fi
  for key in "$@"; do
    if ! grep -qE "^${key}:" <<<"$fm"; then
      echo "✗ $file: missing '${key}:' in frontmatter"
      fail=1
    fi
  done
}

for f in "$DOT"/claude/commands/*.md; do
  [ -e "$f" ] && check "$f" description
done

for f in "$DOT"/claude/agents/*.md; do
  [ -e "$f" ] && check "$f" name description tools
done

for f in "$DOT"/claude/skills/*/SKILL.md; do
  [ -e "$f" ] && check "$f" name description
done

if [ "$fail" -eq 0 ]; then
  echo "✓ claude/ frontmatter OK"
else
  exit 1
fi
