# Brewfile — install everything with: brew bundle --file=Brewfile

# --- Terminal / shell / editor ---
cask "ghostty"                          # terminal emulator
brew "fish"                             # shell
brew "neovim"                           # editor
cask "font-jetbrains-mono-nerd-font"    # icon font (Nerd Font)

# --- Prompt + CLI tools ---
brew "starship"                         # prompt
brew "zoxide"                           # smarter cd
brew "eza"                              # modern ls
brew "bat"                              # cat with colors
brew "fzf"                              # fuzzy finder
brew "ripgrep"                          # fast grep (used by nvim/telescope)
brew "fd"                               # fast find
brew "lazygit"                          # git TUI
brew "git-delta"                        # pretty git diffs (git pager)
brew "atuin"                            # shell history: fuzzy Ctrl+R, synced
brew "direnv"                           # per-directory env (.envrc)

# --- Code quality ---
brew "openjdk@21"                       # Java runtime (for the SonarLint LS)
brew "sonar-scanner"                    # local analysis against SonarQube
# The SonarQube server runs in Docker, see README

# --- Dev tooling ---
brew "gh"                               # GitHub CLI (gh-dash extension: `ghd`)
brew "git"
brew "mise"                             # runtime version manager (node/python/…)
brew "k9s"                              # terminal UI for Kubernetes
brew "stern"                            # tail logs from multiple pods
brew "just"                             # command runner (see justfile)
brew "shellcheck"                       # shell linter (CI + `just lint`)
brew "stylua"                           # Lua formatter (nvim config)
brew "gitleaks"                         # secret scanner (pre-commit hook)
brew "pipx"                             # installs the QMK CLI: `pipx install qmk` (see corne-keymap repo)
