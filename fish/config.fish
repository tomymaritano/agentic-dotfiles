# ~/.config/fish/config.fish

# --- Homebrew (arm64) ---
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
end

# --- User binaries (CLIs: claude, coderabbit/cr, grok, etc.) ---
# dotfiles/bin is prepended last so its `claude` wrapper wins over ~/.local/bin/claude.
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.grok/bin"
fish_add_path "$HOME/dotfiles/bin"

# --- Default editor ---
set -gx EDITOR nvim
set -gx VISUAL nvim

# Programs that open a shell read $SHELL. Neovim keeps &shell on zsh for :!
# and :terminal (fish is not POSIX); Snacks terminals use fish.
set -gx SHELL /opt/homebrew/bin/fish

# AWS CLI profile for this laptop (dev account). direnv can override it per repo.
# starship reads this and prints it in the prompt.
set -gx AWS_PROFILE psynth-dev

# --- Java (openjdk@21, keg-only) for the SonarLint language server ---
if test -d /opt/homebrew/opt/openjdk@21
    set -gx JAVA_HOME /opt/homebrew/opt/openjdk@21
    fish_add_path /opt/homebrew/opt/openjdk@21/bin
end

# --- Runtimes / mise ---
# mise manages node/python/go/… versions (replaces nvm). Global versions live in
# mise/config.toml (tracked). Per project: `mise use node@22`, `mise use python@3.12`.
# It's activated in the interactive block below.

# --- bat as the default pager ---
set -gx PAGER bat
# bat follows the terminal palette (which the `theme` command switches via Ghostty)
set -gx BAT_THEME ansi
# fzf colors — the `theme` command sets these (universal); default to kanagawa
set -q FZF_DEFAULT_OPTS
or set -gx FZF_DEFAULT_OPTS "--color=fg:#dcd7ba,bg:#1f1f28,hl:#7e9cd8,fg+:#dcd7ba,bg+:#2a2a37,hl+:#7fb4ca,border:#54546d,prompt:#e6c384,pointer:#d27e99,info:#727169,header:#98bb6c"

# --- Empty greeting when fish opens ---
set -g fish_greeting

# --- Interactive sessions only ---
if status is-interactive
    # Prompt: starship
    if type -q starship
        starship init fish | source
    end

    # zoxide: `z <part-of-path>` jumps to visited dirs; `zi` opens an fzf picker
    if type -q zoxide
        zoxide init fish | source
    end

    # fzf: Ctrl+T (files), Alt+C (cd). (Ctrl+R is taken over by atuin below.)
    if type -q fzf
        fzf --fish | source
    end

    # atuin: better shell history with fuzzy search on Ctrl+R (synced, per-dir
    # context). First run once: `atuin import auto` to seed from your old history.
    # Sourced after fzf so it wins the Ctrl+R binding.
    if type -q atuin
        atuin init fish | source
    end

    # direnv: auto-loads a directory's .envrc when you cd in (per-project env vars
    # / tool versions). Run `direnv allow` once per project to trust its .envrc.
    if type -q direnv
        direnv hook fish | source
    end

    # mise: node/python/go/… version manager (replaces nvm)
    if type -q mise
        mise activate fish | source
    end

    # --- Aliases ---
    alias v   nvim

    # eza: modern ls replacement (icons + git + tree)
    if type -q eza
        alias ls  "eza --icons --group-directories-first"
        alias ll  "eza -lah --icons --group-directories-first --git"
        alias lt  "eza --tree --level=2 --icons"
    else
        alias ll  "ls -lah"
    end

    # bat: cat with syntax highlighting
    if type -q bat
        alias cat bat
    end

    # git / gh shortcuts as abbreviations — they expand inline as you type, so
    # you see (and can edit) the real command before running it.
    abbr -a lg   lazygit
    abbr -a gs   'git status'
    abbr -a gd   'git diff'
    abbr -a ghd  'gh dash'
    abbr -a ghpr 'gh pr create --web'

    # tweets: `tweet "idea"` jots to ~/notes/tweets.md; `tweet` alone opens it.
    # Draft/post with Claude Code's /tweet command (see claude/commands/tweet.md).
    # `claude` is ~/dotfiles/bin/claude (ahead of the real binary): it injects
    # 1Password secrets via `op run` for both this shell and Neovim.

    # theme switcher (Ghostty + starship + nvim) — see functions/theme.fish
    complete -c theme -f -a "mocha tokyonight kanagawa rose-pine"

    # SonarQube (Docker) - dashboard at http://localhost:9000
    abbr -a sq-up   'docker start sonarqube'
    abbr -a sq-down 'docker stop sonarqube'
    abbr -a sq-logs 'docker logs -f sonarqube'

    # Claude Code engine running on xAI Grok, via claude-code-router (CCR).
    # Isolated profile (~/.claude-grok) so it never touches your personal `claude`,
    # and grok-4.3 shows up selectable in the /model picker. Needs XAI_API_KEY set.
    alias grokcode "op run --account my.1password.com --env-file=$HOME/dotfiles/op/secrets.env -- env CLAUDE_CONFIG_DIR=$HOME/.claude-grok ANTHROPIC_CUSTOM_MODEL_OPTION=grok-4.3 ccr code"
end
