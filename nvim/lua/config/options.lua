-- Options loaded before lazy.nvim. LazyVim already sets a lot (relativenumber,
-- clipboard=unnamedplus, ignorecase/smartcase, termguicolors, …); this only adds
-- the extras on top. Full defaults: https://www.lazyvim.org/configuration/general

local opt = vim.opt

opt.scrolloff = 8 -- keep 8 lines of context above/below the cursor (LazyVim: 4)
opt.colorcolumn = "80,120" -- soft guides at 80 and 120 columns
opt.wrap = false -- no line wrap by default…
opt.linebreak = true -- …but if wrap is toggled on, break at word boundaries
opt.splitkeep = "screen" -- keep text on screen stable when opening splits
opt.confirm = true -- ask to save instead of failing on :q with unsaved changes

-- fish exports SHELL=fish. That would make :! and system() run through fish,
-- which breaks POSIX snippets. Keep those on zsh. Interactive terminals use
-- fish via Snacks (see lua/plugins/dashboard.lua).
opt.shell = "/bin/zsh"
