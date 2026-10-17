#!/usr/bin/env bash
# claude/install-plumbline.sh — install my Plumbline plugin (design-review
# skills, https://github.com/tomymaritano/plumbline) into Claude Code and, if
# it's installed, Grok Build. Installed as a plugin from its own marketplace,
# not vendored: updates come from the plumbline repo, not from here.
#
# Safe to re-run: an existing install is updated instead of re-added.
set -euo pipefail

REPO="tomymaritano/plumbline"

echo "· Claude Code ..."
if claude plugin marketplace list 2>/dev/null | grep -q plumbline-plugins; then
  claude plugin marketplace update plumbline-plugins
else
  claude plugin marketplace add "$REPO"
fi
if claude plugin list 2>/dev/null | grep -q 'plumbline@plumbline-plugins'; then
  claude plugin update plumbline@plumbline-plugins
else
  claude plugin install -s user plumbline@plumbline-plugins
fi

if command -v grok >/dev/null 2>&1; then
  echo "· Grok Build ..."
  grok plugin marketplace add "$REPO" 2>/dev/null || true
  grok plugin install plumbline --trust 2>/dev/null || grok plugin update plumbline
else
  echo "· Grok Build not found, skipping (install: curl -fsSL https://x.ai/cli/install.sh | bash)"
fi

echo
echo "✓ plumbline installed. Restart Claude Code, then try:  /plumbline:red-flags <file>"
