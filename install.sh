#!/usr/bin/env bash
# install.sh — symlink the configs in this repo into ~/.config
# Usage: ./install.sh
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$HOME/.config"

mkdir -p "$CFG/ghostty" "$CFG/fish" "$CFG/nvim"

link() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%s)"
    echo "backup: $dst -> $dst.bak.*"
  fi
  ln -sfn "$src" "$dst"
  echo "link: $dst -> $src"
}

link "$DOT/ghostty/config"         "$CFG/ghostty/config"
link "$DOT/fish/config.fish"       "$CFG/fish/config.fish"
link "$DOT/fish/fish_plugins"      "$CFG/fish/fish_plugins"
link "$DOT/starship/starship.toml" "$CFG/starship.toml"

# home-level dotfiles (git + editorconfig + ssh)
link "$DOT/git/config"    "$HOME/.gitconfig"
link "$DOT/git/ignore"    "$HOME/.gitignore_global"
link "$DOT/editorconfig"  "$HOME/.editorconfig"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
link "$DOT/ssh/config"    "$HOME/.ssh/config"

# Login shell. Ghostty still launches fish; this file is what Terminal.app and
# scripts get. Backs up a pre-existing ~/.zshrc on first link.
link "$DOT/zsh/.zshrc"    "$HOME/.zshrc"

# machine-local git overrides / secrets, pulled in by ~/.gitconfig's [include].
# Never tracked. Seed an empty stub so git doesn't warn about a missing include.
[ -f "$HOME/.gitconfig.local" ] || printf '# machine-local git overrides (not tracked)\n' > "$HOME/.gitconfig.local"

# gitleaks pre-commit hook, applied to every repo (secret scanner). The hook
# itself no-ops if gitleaks isn't installed, so this never blocks a commit.
git config --file "$HOME/.gitconfig.local" core.hooksPath "$DOT/git/hooks"

# fish functions: link our files individually — fisher owns this directory
# and installs plugin functions (nvm.fish, fisher.fish) alongside ours.
mkdir -p "$CFG/fish/functions"
for fn in "$DOT"/fish/functions/*.fish; do
  link "$fn" "$CFG/fish/functions/$(basename "$fn")"
done

# nvim: link our own files. lazy-lock.json / lazyvim.json are tracked and
# linked too, so plugin versions + extras stay reproducible across machines
# (`:Lazy update` writes through the symlink into the repo — then commit it).
link "$DOT/nvim/init.lua"     "$CFG/nvim/init.lua"
link "$DOT/nvim/lua"          "$CFG/nvim/lua"
[ -f "$DOT/nvim/stylua.toml" ]    && link "$DOT/nvim/stylua.toml"     "$CFG/nvim/stylua.toml"
[ -f "$DOT/nvim/.neoconf.json" ]  && link "$DOT/nvim/.neoconf.json"   "$CFG/nvim/.neoconf.json"
[ -f "$DOT/nvim/lazy-lock.json" ] && link "$DOT/nvim/lazy-lock.json"  "$CFG/nvim/lazy-lock.json"
[ -f "$DOT/nvim/lazyvim.json" ]   && link "$DOT/nvim/lazyvim.json"    "$CFG/nvim/lazyvim.json"

# nvim theme state (runtime, not tracked): default to kanagawa if absent.
# The `theme` command rewrites this; nvim reads it at startup.
[ -f "$CFG/nvim/theme.txt" ] || echo "kanagawa" > "$CFG/nvim/theme.txt"

# mise: global runtime versions (node/python/…), tracked for reproducibility.
mkdir -p "$CFG/mise"
[ -f "$DOT/mise/config.toml" ] && link "$DOT/mise/config.toml" "$CFG/mise/config.toml"

# Claude Code: link our slash commands, subagents, voice guide and global memory.
# ~/.claude is otherwise managed by Claude Code, so link files individually.
mkdir -p "$HOME/.claude/commands" "$HOME/.claude/agents"
for cmd in "$DOT"/claude/commands/*.md; do
  [ -e "$cmd" ] && link "$cmd" "$HOME/.claude/commands/$(basename "$cmd")"
done
for agent in "$DOT"/claude/agents/*.md; do
  [ -e "$agent" ] && link "$agent" "$HOME/.claude/agents/$(basename "$agent")"
done
mkdir -p "$HOME/.claude/skills"
for skill in "$DOT"/claude/skills/*/; do
  [ -d "$skill" ] && link "${skill%/}" "$HOME/.claude/skills/$(basename "$skill")"
done
[ -f "$DOT/claude/voice.md" ]  && link "$DOT/claude/voice.md"  "$HOME/.claude/voice.md"
[ -f "$DOT/claude/CLAUDE.md" ] && link "$DOT/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

echo
echo "Done. Next:"
echo "  1) brew bundle --file=$DOT/Brewfile"
echo "  2) fisher install jorgebucaran/fisher  (then: fisher update)"
echo "  3) open nvim so LazyVim/Mason install plugins + sonarlint-language-server"
echo "  4) gh extension install dlvhdr/gh-dash   (PR/issue dashboard: 'ghd')"
echo "  5) ./claude/install-templates.sh          (community Claude Code agents/skills)"
