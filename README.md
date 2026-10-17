# dotfiles



<img width="4688" height="2976" alt="image" src="https://github.com/user-attachments/assets/7dca5eed-33b1-455f-aff4-7452e725d813" />


[![lint](https://github.com/tomymaritano/dotfiles/actions/workflows/lint.yml/badge.svg)](https://github.com/tomymaritano/dotfiles/actions/workflows/lint.yml)
![platform](https://img.shields.io/badge/platform-macOS%20Apple%20Silicon-000000?logo=apple&logoColor=white)
![shell](https://img.shields.io/badge/shell-fish%204.x-4E9A06?logo=gnubash&logoColor=white)
![terminal](https://img.shields.io/badge/terminal-Ghostty-1E1E2E)
![editor](https://img.shields.io/badge/editor-Neovim%20·%20LazyVim-57A143?logo=neovim&logoColor=white)
![themes](https://img.shields.io/badge/themes-4%20·%20one--command%20switcher-e6c384)

My macOS (Apple Silicon) terminal setup: **Ghostty + fish + Neovim (LazyVim)**, themed with a **one-command switcher** — `theme <name>` restyles the terminal, prompt and editor together (**Kanagawa Wave** by default; also Catppuccin Mocha, TokyoNight, Rose Pine). Plus modern CLI tools, code-quality tooling (SonarLint + SonarQube), and AI assistants (Claude Code, Grok, CodeRabbit).

## Contents

- [Stack](#stack)
- [Requirements](#requirements)
- [Installation](#installation)
- [Themes](#themes)
- [Keybindings](#keybindings)
- [Per-tool notes](#per-tool-notes)
- [Code quality](#code-quality)
- [AI assistants](#ai-assistants)
- [Tasks (just)](#tasks)
- [Updating](#updating)
- [Uninstall](#uninstall)
- [Notes](#notes)

## Stack

```
Ghostty (terminal)  →  fish (shell)  →  Neovim / LazyVim (editor)
   `theme` switcher     starship prompt     LSP + Telescope + SonarLint
   JetBrains Nerd Font  zoxide · eza · bat  ripgrep · fd
   blur + transparency  fzf · atuin · mise  Mason · dap · neotest

   theme kanagawa | mocha | tokyonight | rose-pine   ← restyles all three
```

| Layer | Tool | What for |
|-------|------|----------|
| Terminal | [Ghostty](https://ghostty.org) | fast GPU terminal, Nerd Font, blur + transparency |
| Shell | [fish](https://fishshell.com) 4.x | interactive shell (default only in Ghostty; the system stays on zsh) |
| Prompt | [starship](https://starship.rs) | prompt with git, AWS profile, kube context, language, duration; palette follows the active theme |
| Editor | [Neovim](https://neovim.io) + [LazyVim](https://lazyvim.org) | LSP, completion, fuzzy find — a VSCode replacement |
| `cd` | [zoxide](https://github.com/ajeetdsouza/zoxide) | jump to frequent dirs (`z <name>`) |
| `ls` | [eza](https://eza.rocks) | listing with icons + git |
| `cat` | [bat](https://github.com/sharkdp/bat) | syntax highlighting |
| search | [ripgrep](https://github.com/BurntSushi/ripgrep) + [fd](https://github.com/sharkdp/fd) | fast; used by Telescope in nvim |
| history | [atuin](https://atuin.sh) | fuzzy `Ctrl+R` shell history, per-dir + synced |
| env | [direnv](https://direnv.net) | auto-load per-project env from `.envrc` |
| runtimes | [mise](https://mise.jdx.dev) | node/python/go/… versions (replaces nvm); global set in `mise/config.toml` |
| cluster | [k9s](https://k9scli.io) + [stern](https://github.com/stern/stern) | pod UI, and logs across pods. Need a kube context |
| git | [lazygit](https://github.com/jesseduffield/lazygit) + [delta](https://github.com/dandavison/delta) | git TUI (`lg`) + pretty diffs |
| tasks | [just](https://github.com/casey/just) | repo task runner (see [Tasks](#tasks)) |
| quality | SonarLint (nvim) + SonarQube (Docker) | see [Code quality](#code-quality) |

## Requirements

- **macOS on Apple Silicon** (Homebrew lives under `/opt/homebrew`).
- **[Homebrew](https://brew.sh)** — everything else is installed from the `Brewfile`.
- **git** and, for the SSH clone below, a GitHub SSH key (or clone over HTTPS).
- A **Nerd Font** — the `Brewfile` installs *JetBrainsMono Nerd Font*; Ghostty is
  already configured to use it. Other terminals need the font selected manually.
- **Docker** (Docker Desktop or OrbStack) — only for the SonarQube server + its MCP; the rest of the setup works without it.

## Installation

Fresh machine — one line does the base setup (Homebrew, clone, `brew bundle`,
symlinks, fish plugins, runtimes):

```bash
curl -fsSL https://raw.githubusercontent.com/tomymaritano/dotfiles/main/bootstrap.sh | bash
```

Or step by step:

```bash
git clone git@github.com:tomymaritano/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 1) Install everything from Homebrew
brew bundle --file=Brewfile

# 2) Symlink the configs into ~/.config (backs up anything existing)
./install.sh

# 3) fish plugins (fisher)
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
fish -c 'fisher update'   # installs what's in fish/fish_plugins

# 4) runtimes via mise (versions pinned in mise/config.toml)
mise install

# 5) Open nvim — LazyVim + Mason install plugins and the SonarLint language server
nvim

# 6) (optional) community Claude Code agents/skills, and the gh dashboard
./claude/install-templates.sh
gh extension install dlvhdr/gh-dash
```

`install.sh` symlinks each config into `~/.config` (and a few into `~`, like
`.gitconfig`) and **backs up** anything already there to `*.bak.<timestamp>` — so
it's safe to re-run and easy to undo (see [Uninstall](#uninstall)).

Optional: `./macos/defaults.sh` applies opinionated macOS system settings (fast
key repeat, Finder tweaks, screenshots → `~/Screenshots`). From then on, `just`
runs the common tasks (see [Tasks](#tasks)).

### First-run checklist (one-time, can't be scripted)

These are account logins / GUI toggles the bootstrap can't do for you:

- [ ] **1Password** — sign in, then *Settings → Developer → Use the SSH agent*.
- [ ] **Secrets** — `cp op/secrets.env.example op/secrets.env` and point the `op://` paths at your items.
- [ ] **GitHub signing key** — add your 1Password SSH key to GitHub as a **Signing** key, then enable signing in `~/.gitconfig.local` (see [git](#git-git--ssh--editorconfig)).
- [ ] **`gh auth login`** and **`claude`** login (their auth is local, not in the repo).
- [ ] **Claude Code extras** — `./claude/install-templates.sh` and `gh extension install dlvhdr/gh-dash`.
- [ ] **Neovim** — open `nvim` once so LazyVim + Mason install plugins and language servers.
- [ ] Open a **fresh terminal** so abbreviations, mise, atuin and the `claude` wrapper load.

## Themes

One command restyles the whole stack — terminal, prompt and editor — at once:

```fish
theme kanagawa     # Kanagawa Wave     (default)
theme mocha        # Catppuccin Mocha
theme tokyonight   # TokyoNight Moon
theme rose-pine    # Rose Pine Moon
```

### Gallery

The banner accent and starship prompt follow the active theme:

|  |  |
|:--:|:--:|
| ![Kanagawa Wave](https://img.shields.io/badge/Kanagawa%20Wave-default%20·%20gold-e6c384?style=for-the-badge&labelColor=1f1f28) | ![Catppuccin Mocha](https://img.shields.io/badge/Catppuccin%20Mocha-mauve-cba6f7?style=for-the-badge&labelColor=1e1e2e) |
| ![TokyoNight Moon](https://img.shields.io/badge/TokyoNight%20Moon-blue-82aaff?style=for-the-badge&labelColor=222436) | ![Rose Pine Moon](https://img.shields.io/badge/Rose%20Pine%20Moon-pink-eb6f92?style=for-the-badge&labelColor=232136) |

> **Screenshots:** drop one per theme here the same way as the header image —
> drag a PNG into a GitHub issue/comment to get a `user-attachments` URL, then
> replace a cell with `![kanagawa](URL)`.

### How switching maps

`theme` (defined in `fish/functions/theme.fish`) maps a short name to the
matching **Ghostty theme**, **starship palette** and **Neovim colorscheme**:

| `theme <name>` | Ghostty | starship palette | Neovim colorscheme | banner accent |
|----------------|---------|------------------|--------------------|---------------|
| `kanagawa`     | Kanagawa Wave    | `kanagawa`         | `kanagawa-wave`     | gold `#e6c384`  |
| `mocha`        | Catppuccin Mocha | `catppuccin_mocha` | `catppuccin-mocha`  | mauve `#cba6f7` |
| `tokyonight`   | TokyoNight Moon  | `tokyonight`       | `tokyonight-moon`   | blue `#82aaff`  |
| `rose-pine`    | Rose Pine Moon   | `rose_pine`        | `rose-pine-moon`    | pink `#eb6f92`  |

### How it applies after switching

- **starship** — instant, on the next prompt.
- **Ghostty** — reload with `Cmd+Shift+,` (or just open a new window).
- **Neovim** — restart nvim. To *preview* themes live without committing, use
  LazyVim's picker: `<leader>uC` (that preview is not persisted; `theme` is what sticks).
- **fzf / bat** — colors follow the theme too: `theme` sets `FZF_DEFAULT_OPTS` per theme, and `bat` uses `BAT_THEME=ansi` so it tracks the terminal palette. Applies to new shells.

### How it works internally

- Ghostty (`ghostty/config`) and starship (`starship.toml`) each have one line
  swapped in place (`theme = …` / `palette = "…"`).
- Neovim reads a tiny state file, `~/.config/nvim/theme.txt` (git-ignored), at
  startup — `nvim/lua/plugins/colorscheme.lua` maps its contents to a colorscheme,
  installs all four theme plugins, and colors the dashboard banner per theme.

To **add a theme**: add a `case` in `fish/functions/theme.fish`, a matching
`[palettes.<name>]` block in `starship.toml`, and an entry (plus its plugin +
accent color) in `nvim/lua/plugins/colorscheme.lua` / `nvim/lua/plugins/dashboard.lua`.

## Keybindings

`<leader>` is **space**. These are LazyVim defaults plus this repo's additions —
see [lazyvim.org/keymaps](https://www.lazyvim.org/keymaps) for the full list.

### Neovim — files & search

| Key | Action |
|-----|--------|
| `<leader><space>` | Find files (project root) |
| `<leader>ff` / `<leader>fr` | Find files / recent files |
| `<leader>/` | Live grep (search in project) |
| `<leader>,` | Switch buffer |
| `<leader>e` / `<leader>E` | File explorer (root / cwd) |

### Neovim — code & LSP

| Key | Action |
|-----|--------|
| `gd` `gr` `gI` `gy` | Go to definition / references / implementation / type |
| `K` | Hover docs |
| `<leader>ca` / `<leader>cr` | Code action / rename |
| `<leader>cf` | Format |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>cd` | Line diagnostics |

### Neovim — git, windows, UI

| Key | Action |
|-----|--------|
| `<leader>gg` | lazygit |
| `<leader>gb` | Blame line · `]h` / `[h` next/prev hunk |
| `<C-h/j/k/l>` | Move between windows |
| `<leader>\|` / `<leader>-` | Split vertical / horizontal |
| `<S-h>` / `<S-l>` | Previous / next buffer · `<leader>bd` close buffer |
| `<leader>uC` | Colorscheme picker (live preview) |
| `<leader>l` / `<leader>cm` | Lazy / Mason |

### Neovim — AI, tests, navigate

| Key | Action |
|-----|--------|
| `<leader>ac` / `<leader>af` | Toggle / focus **Claude Code** (claudecode.nvim) |
| `<leader>as` (visual) | Send selection to Claude · `<leader>ab` add buffer |
| `<leader>aa` / `<leader>ad` | Accept / reject Claude's diff |
| `<leader>H` · `<leader>1`…`5` | **Harpoon** add file · jump to pinned file |
| `<leader>t` group | **neotest** — run/debug tests · `<F5>` dap continue |
| `<C-d>` / `<C-u>`, `J` | Centered half-page jump, join keeping cursor *(custom)* |

> Custom motions (`<leader>p` paste-keep-yank, `<leader>d` blackhole-delete, `<leader>fD` open config) live in `nvim/lua/config/keymaps.lua`.

### fish — aliases & functions

| Command | What it does |
|---------|--------------|
| `v` | nvim |
| `lg` | lazygit |
| `ll` / `lt` | eza long / tree listing |
| `cat` | bat (syntax highlighting) |
| `gs` / `gd` | git status / git diff |
| `z <dir>` | zoxide jump to a frequent directory |
| `theme <name>` | [switch the whole-stack theme](#themes) |
| `sq-up` / `sq-down` / `sq-logs` | [SonarQube](#code-quality) container control |
| `grokcode` | Claude Code engine on Grok ([see below](#ai-assistants)) |
| `claude` | `~/dotfiles/bin/claude` — 1Password secrets via `op run`, for the shell and Neovim |
| `ghd` / `ghpr` | gh-dash PR/issue dashboard / open a PR |
| `mise use node@22` | set a runtime version (global or per project) |
| `tweet "idea"` | jot a tweet idea to `~/notes/tweets.md` |

## Per-tool notes

### Ghostty (`ghostty/config`)
- Font: `JetBrainsMono Nerd Font` (icons for LazyVim).
- Theme: set by the `theme` command (see [Themes](#themes)); the `theme = …` line uses Ghostty's exact, capitalized theme names.
- Translucent background: `background-opacity = 0.85` + `background-blur-radius = 20` (macOS blur).
- `command = /opt/homebrew/bin/fish` → fish only inside Ghostty; the system login shell stays zsh (friendlier with POSIX installers/tooling).
- Reload config: `Cmd+Shift+,`.

### fish (`fish/config.fish`)
- Loads Homebrew, sets `EDITOR=nvim` and `SHELL` to fish, exports `AWS_PROFILE=psynth-dev` (direnv can override it), adds Java (openjdk@21) to PATH for SonarLint.
- Puts `~/dotfiles/bin` first on `PATH` so `claude` is the 1Password wrapper, not the raw binary.
- Initializes starship, zoxide, fzf, **atuin** and **direnv** in interactive sessions only.
- **atuin** owns `Ctrl+R` (fuzzy history). Run `atuin import auto` once to seed it from your old history; `atuin login` is optional (only for cross-machine sync).
- **direnv**: drop an `.envrc` in a project and run `direnv allow` once — vars load/unload as you `cd` in and out.
- **mise** activates here too; runtimes (node/python/go/…) come from it, not nvm. Global versions live in `mise/config.toml`; per project: `mise use node@22`.
- Aliases & functions: see the [Keybindings cheatsheet](#keybindings).

### git (`git/`) + ssh + editorconfig
- `git/config` → `~/.gitconfig`: identity, sane defaults (`pull.rebase`, `push.autoSetupRemote`, `fetch.prune`), **delta** as the diff pager, aliases (`git s`, `git lg`, `git undo`, `git pushf`, …), and SSH signing wired to 1Password's `op-ssh-sign`.
- Machine-specific or secret bits (signing key, coderabbit id) live in `~/.gitconfig.local`, pulled in via `[include]` — **not tracked**.
- `ssh/config` → `~/.ssh/config`: routes auth through the **1Password SSH agent** (keys stay in 1Password, Touch ID to use); the on-disk key remains a fallback.
- **Turn on signed commits** (one-time): create an SSH key in 1Password (`op item create --category ssh-key`), add its public key to GitHub as a **Signing** key (Settings → SSH and GPG keys; *Authentication* type too only if you also want 1Password to handle `git push`), then set in `~/.gitconfig.local`:
  ```ini
  [user]
      signingkey = ssh-ed25519 AAAA…your key…
  [commit]
      gpgsign = true
  [gpg "ssh"]
      allowedSignersFile = ~/.config/git/allowed_signers
  ```
  and add `<your-email> ssh-ed25519 AAAA…` to `~/.config/git/allowed_signers` so `git log --show-signature` verifies locally.
- `git/ignore` → `~/.gitignore_global`; `editorconfig` → `~/.editorconfig`.

### Neovim (`nvim/`)
LazyVim base, personalized (not stock). The custom bits live in:
- `lua/config/` → `options.lua`, `keymaps.lua`, `autocmds.lua` (see [Keybindings](#keybindings)).
- `lua/plugins/`:
  - `colorscheme.lua` + `dashboard.lua` — themes & banner (see [Themes](#themes)).
  - `lang.lua` — LazyVim extras for TS/JS, Python, Go, Rust, Docker, JSON, YAML, Helm, Markdown + Prettier, ESLint and neotest (each: LSP + treesitter + formatter + test/debug adapter, via Mason). Fish has no LazyVim extra; treesitter + `fish_lsp` are configured there.
  - `editor.lua` — nvim-dap (debug), harpoon2 (pin/jump files), octo (GitHub PRs), treesitter-context.
  - `claudecode.lua` — Claude Code inside nvim under `<leader>a`.
  - `sonarlint.lua` — live SonarLint ([Code quality](#code-quality)).
- Runtimes (Go/Rust compilers, etc.) come from **mise**, not Mason — `mise use -g go@latest rust@stable`.
- Language plugin versions are pinned in the tracked `lazy-lock.json`; update with `:Lazy update` then commit it.

## Code quality

Two layers that act at different moments: **SonarLint** (live, in nvim) and
**SonarQube Server** (full analysis, in Docker).

**1. SonarLint in nvim (`nvim/lua/plugins/sonarlint.lua`)** — *live* linting as you type, like VSCode's SonarLint. Runs locally, no server.
- Requires `openjdk@21` (Java) and `sonarlint-language-server` (installed by Mason).
- Active for JS/TS/Python/HTML/CSS/XML.

**2. SonarQube Server in Docker** — *full* analysis with a dashboard and quality gates. Reproducible via the tracked compose file (`sonarqube/docker-compose.yml`):

```bash
docker compose -f sonarqube/docker-compose.yml up -d
```

- Dashboard: <http://localhost:9000> — initial login `admin` / `admin` (forces a change).
- To analyze a project: create the project in the dashboard → generate a token → from the repo root:

  ```bash
  sonar-scanner \
    -Dsonar.projectKey=my-project \
    -Dsonar.sources=. \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.token=YOUR_TOKEN
  ```

- Container control: `sq-up` / `sq-down` / `sq-logs`.

### Let the AI read your issues — SonarQube MCP

Claude Code can query your SonarQube **directly** through the official
[SonarQube MCP server](https://github.com/SonarSource/sonarqube-mcp-server)
(free, works with Community Build). Once wired, you can ask *"fix the SonarQube
issues in this file"* and Claude pulls the rules/issues itself — no copy-paste.

Configured **per user** (in `~/.claude.json`, **not** this repo) and reads a
token from the gitignored fish universal var `SONARQUBE_TOKEN`. One script does
the whole bridge — generate the token, store it, and register the MCP server:

```bash
sonarqube/setup-mcp.sh              # uses the default admin password
sonarqube/setup-mcp.sh 'my-pass'    # if you changed the SonarQube admin password
```

It runs `claude mcp add -s user sonarqube … sonarsource/sonarqube-mcp` under the
hood. Notes:

- `host.docker.internal:9000` is how the MCP container reaches SonarQube on the host.
- Launch `claude` from a shell that has `~/dotfiles/bin` on `PATH` (fish and the login zsh both do). The wrapper injects `${SONARQUBE_TOKEN}` from 1Password. Neovim's `<leader>ac` uses that same `claude`.
- Issues only show up once a project has been analyzed with `sonar-scanner` (above).
- Check status with `claude mcp list`; a `USER`-type token is required (the script uses it).

## AI assistants

Installed as global CLIs (their auth is local and **not** in this repo):
- **Claude Code** — `claude`
- **Grok** (xAI, native CLI) — `grok`
- **CodeRabbit** — `coderabbit` / `cr`

### Claude Code config (`claude/`)

Tracked here and symlinked into `~/.claude`:
- **`CLAUDE.md`** — global preferences applied in every project (environment, conventions, stack).
- **`commands/`** — slash commands *you* run: `/tweet`, `/commit`.
- **`agents/`** — subagents Claude delegates to: `reviewer` (correctness/security/reuse review).
- **`skills/`** — capabilities Claude auto-activates by description: `changelog` (release notes from git).
- **`voice.md`** — tweet voice guide used by `/tweet`.

Third-party components from [aitmpl.com](https://aitmpl.com) are **not** vendored — re-fetch them on a new machine with `./claude/install-templates.sh` (or `just claude-templates`): agents *ui-ux-designer, devops-engineer, test-engineer, deployment-engineer*; skills *senior-frontend, frontend-design, ui-ux-pro-max, senior-security, clean-code, react-best-practices*.

My own **[Plumbline](https://github.com/tomymaritano/plumbline)** plugin (design-review skills based on *A Philosophy of Software Design*) is installed as a plugin from its own marketplace, not vendored: run `./claude/install-plumbline.sh` (or `just plumbline`). It installs into Claude Code and, if `grok` is on the PATH, Grok Build too. Re-running it updates. Then use `/plumbline:red-flags`, `/plumbline:design-review`, `/plumbline:design-it-twice`, etc.

Inside Neovim, `claudecode.nvim` bridges to the `claude` CLI under `<leader>a` (see [Keybindings](#keybindings)). Snacks terminals (`Ctrl-/`, `<leader>ft`) run fish. `:!` stays on zsh.

### Claude Code running on Grok (`ccr/config.json`)

The Claude Code *engine* can run on xAI Grok via [claude-code-router](https://github.com/musistudio/claude-code-router) (CCR), a local proxy that translates Anthropic ⇄ OpenAI format. Run it with the `grokcode` alias:

```fish
grokcode   # = env CLAUDE_CONFIG_DIR=~/.claude-grok ANTHROPIC_CUSTOM_MODEL_OPTION=grok-4.3 ccr code
```

- **Isolated profile** (`~/.claude-grok`) so it never touches your personal `claude` account.
- `ANTHROPIC_CUSTOM_MODEL_OPTION=grok-4.3` makes Grok selectable in the `/model` picker (Claude Code rejects non-Claude names otherwise).
- Needs `XAI_API_KEY` set: `set -Ux XAI_API_KEY xai-...` (stored in gitignored `fish_variables`).
- `ccr/config.json` (in this repo) defines the providers/router; it has **no key** (uses `$XAI_API_KEY`). Copy it to `~/.claude-code-router/config.json`.
- The model lives at `~/.claude-code-router/config.json` `Router` block; `ccr ui` opens a web editor.
- Note: unofficial/unsupported by Anthropic; tool-use/agentic editing on Grok can be less reliable than native Claude.

### Tweets (build in public)

A workflow for drafting eng/product tweets without breaking flow:

1. **Capture** — `tweet "raw idea"` appends it to `~/notes/tweets.md` (`tweet` with no args opens the file). Fast, no context switch.
2. **Draft** — in Claude Code, `/tweet <idea>` writes tweet/thread options in a defined voice (`claude/voice.md`), pulling from the idea or your recent git activity. `/commit` writes commit messages. Both are tracked in `claude/commands/` and symlinked into `~/.claude/commands/`.
3. **Post** — via MCP (`x/setup-mcp.sh`):
   - `x-docs` (`https://docs.x.com/mcp`) — official X API docs search; no auth.
   - `x-twitter` — community poster ([Infatoshi/x-mcp](https://github.com/Infatoshi/x-mcp)) with `post_tweet`, `reply_to_tweet`, `quote_tweet`, `upload_media`, … Uses OAuth1 keys from an X app (Read+Write), kept in **1Password** and injected at launch by `op run` — no secrets on disk. Free tier ≈ 500 posts/month.

   Just launch `claude` (it's wrapped to inject the X secrets from 1Password via `op run`). Then `/tweet <idea>` → review → "post it". Set the `op://` paths in `op/secrets.env` (see `op/secrets.env.example`).

## Tasks

Common jobs are wrapped in a [`justfile`](https://github.com/casey/just) — run
`just` to list them:

| Recipe | What it does |
|--------|--------------|
| `just install` | symlink configs (`./install.sh`) |
| `just brew` | install/update from the `Brewfile` |
| `just update` | pull + re-link + brew + fish plugins |
| `just lint` | shellcheck + `stylua --check` (same as CI) |
| `just fmt` | auto-format the Lua config |
| `just macos` | apply `macos/defaults.sh` |
| `just sonar` | start SonarQube + wire the [MCP bridge](#let-the-ai-read-your-issues--sonarqube-mcp) |

Shell scripts and Lua are linted on every push by `.github/workflows/lint.yml`.

## Updating

```bash
just update    # git pull --rebase + ./install.sh + brew bundle + fisher update
```

Inside nvim: `:Lazy sync` to update plugins (commit the changed `lazy-lock.json`),
`:Mason` to manage language servers.

## Uninstall

`install.sh` never deletes — it moves anything it replaces to `*.bak.<timestamp>`.
To roll back, remove the symlinks and restore the most recent backups, e.g.:

```bash
cd ~/.config
rm starship.toml ghostty/config fish/config.fish nvim/init.lua nvim/lua fish/functions/theme.fish
# then restore the backups you want, for example:
mv starship.toml.bak.* starship.toml
```

(The `theme.fish` symlink is the only file this repo adds to `fish/functions/`;
fisher's own functions there are left untouched.)

## Notes

- macOS Apple Silicon (Homebrew under `/opt/homebrew`).
- No secrets in the repo: `auth.json`, `.env`, `fish_variables` and `op/secrets.env` are in `.gitignore`.
- **Secret scanning:** a global pre-commit hook (`git/hooks/pre-commit`, wired via `core.hooksPath`) runs **[gitleaks](https://github.com/gitleaks/gitleaks)** on staged changes and **blocks the commit** if it detects a key/token — a safety net so nothing sensitive ever reaches this public repo. Config + allowlists in `.gitleaks.toml`; bypass one commit with `git commit --no-verify`.
- **Secrets via 1Password:** API keys (X, xAI, SonarQube) live in 1Password, not on disk. `bin/claude` wraps the real binary with `op run --env-file=op/secrets.env` so the MCP servers get their tokens at runtime (plain launch if `op` or the env file is missing). `grokcode` does the same. Point `op/secrets.env` at your items via `op/secrets.env.example`.
- **Keyboard:** my Corne (QMK) keymap — combos, macros and custom OLEDs — lives in its own repo, [corne-keymap](https://github.com/tomymaritano/corne-keymap) (QMK external userspace), not here. The QMK CLI is `pipx install qmk` (Brewfile installs `pipx`).
- The active theme lives in tracked files (`ghostty/config`, `starship.toml`), so
  running `theme <x>` shows up as a diff on those two files — that's expected.
