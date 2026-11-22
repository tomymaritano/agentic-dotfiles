#!/usr/bin/env bash
# bootstrap.sh — set up a fresh macOS machine from scratch. Safe to re-run.
#
#   curl -fsSL https://raw.githubusercontent.com/tomymaritano/agentic-dotfiles/main/bootstrap.sh | bash
#
set -euo pipefail

# 1) Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "· installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2) clone (or update) the repo
DOT="$HOME/dotfiles"
if [ -d "$DOT/.git" ]; then
  git -C "$DOT" pull --ff-only || true
else
  git clone https://github.com/tomymaritano/agentic-dotfiles.git "$DOT"
fi
cd "$DOT"

# 3) packages → symlinks → fish plugins → runtimes
brew bundle --file=Brewfile
./install.sh
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher' || true
fish -c 'fisher update' || true
mise install || true

cat <<'DONE'

✓ Base setup done. Remaining manual steps:
  • ./claude/install-templates.sh          community Claude Code agents/skills
  • gh extension install dlvhdr/gh-dash     PR/issue dashboard (ghd)
  • open nvim                               LazyVim + Mason install plugins/LSPs
  • 1Password → enable the SSH agent; add your key to GitHub; then set
    signingkey + `commit.gpgsign=true` in ~/.gitconfig.local
  • cp op/secrets.env.example op/secrets.env and set your op:// item paths
DONE
