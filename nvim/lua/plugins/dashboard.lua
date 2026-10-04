-- Dashboard header: replace the default "LazyVim" logo with "hacklabdog"
-- (same figlet font — ANSI Shadow) and give it a per-theme accent color so it
-- contrasts nicely whichever theme is active. LazyVim's start screen is
-- snacks.nvim's dashboard; overriding preset.header swaps just the banner.

-- colorscheme (prefix) -> accent hex
local ACCENTS = {
  catppuccin = "#cba6f7", -- mauve
  tokyonight = "#82aaff", -- blue
  kanagawa = "#e6c384", -- gold
  ["rose%-pine"] = "#eb6f92", -- love / pink
}

local function set_header_accent()
  local cs = vim.g.colors_name or ""
  for prefix, color in pairs(ACCENTS) do
    if cs:match("^" .. prefix) then
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = color, bold = true })
      return
    end
  end
end

return {
  "folke/snacks.nvim",
  opts = {
    terminal = {
      -- Ghostty's shell. vim.o.shell stays zsh so :! remains POSIX.
      shell = "/opt/homebrew/bin/fish",
    },
    dashboard = {
      preset = {
        header = [[
██╗  ██╗ █████╗  ██████╗██╗  ██╗██╗      █████╗ ██████╗ ██████╗  ██████╗  ██████╗
██║  ██║██╔══██╗██╔════╝██║ ██╔╝██║     ██╔══██╗██╔══██╗██╔══██╗██╔═══██╗██╔════╝
███████║███████║██║     █████╔╝ ██║     ███████║██████╔╝██║  ██║██║   ██║██║  ███╗
██╔══██║██╔══██║██║     ██╔═██╗ ██║     ██╔══██║██╔══██╗██║  ██║██║   ██║██║   ██║
██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║██████╔╝██████╔╝╚██████╔╝╚██████╔╝
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝
]],
      },
    },
  },
  init = function()
    -- Re-apply on every theme switch, and once now for the current theme
    -- (whichever fires relative to startup, the banner is colored before the
    -- dashboard paints on VimEnter).
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("dashboard_header_accent", { clear = true }),
      callback = set_header_accent,
    })
    set_header_accent()
  end,
}
