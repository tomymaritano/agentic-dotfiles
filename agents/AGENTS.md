# Global preferences (Tomás)

Applies across all projects, for any agent that reads this file (Claude Code,
Codex, Grok Build). A project-level CLAUDE.md/AGENTS.md always overrides this.

## Environment
- macOS (Apple Silicon), shell is **fish** inside Ghostty. Homebrew at `/opt/homebrew`.
- Editor: Neovim (LazyVim). Dotfiles live at `~/dotfiles` (symlinked into `~/.config`).
- Runtimes via **mise** (not nvm/asdf). Node is already installed.
- Prefer the modern CLI tools when scripting: `rg` (not grep), `fd` (not find), `eza`, `bat`.

## How I like to work
- **Reply in Spanish** in conversation; keep code, comments, commit messages and docs in English.
- Be concise and direct. Lead with the answer, then the why. No filler.
- When you change something non-trivial, verify it actually works (run it) before saying it's done.
- Ask before destructive or outward-facing actions (deploys, deletes, pushes) unless I said go.

## Git
- Commit subject: imperative, ≤50 chars. Body explains the *why* when it isn't obvious.
- Don't commit or push unless I ask. Branch off main for non-trivial work.

## Stack I usually touch
- TypeScript/JavaScript, Python, and increasingly Go/Rust.
- Frontend + product work; I post build-in-public notes on X.
