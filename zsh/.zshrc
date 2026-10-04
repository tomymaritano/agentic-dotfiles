# Login shell stays zsh so POSIX installers keep working.
# Ghostty runs fish. Node and Python come from mise inside fish, not nvm/pyenv.

eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

# Claude wrapper (1Password) must win over the real binary in ~/.local/bin.
export PATH="$HOME/dotfiles/bin:$HOME/.local/bin:$PATH"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer >>>
