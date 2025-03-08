local M = {
  {
    "LazyVim/LazyVim",
    optional = true,
    opts = {
      colorscheme = "catppuccin",
    },
  },
  -- { "vimpostor/vim-lumen" },
  { "folke/tokyonight.nvim", lazy = false, optional = true, enabled = false },
  {
    "catppuccin/nvim",
    priority = 1000,
    optional = true,
    name = "catppuccin",
    ---@module "catppuccin"
    ---@type CatppuccinOptions
    opts = {
      integrations = {
        gitsigns = false,
      },
      flavour = "auto", -- latte, frappe, macchiato, mocha
      background = {
        light = "latte",
        dark = "frappe",
      },
      term_colors = true,
      custom_highlights = function(colors)
        local U = require("catppuccin.utils.colors")

        return {
          LspSignatureActiveParameter = { style = { "bold" } },
          SpellBad = {
            sp = colors.subtext0,
          },
          Added = { fg = colors.blue },
          DiffAdd = { bg = U.darken(colors.blue, 0.18, colors.base) },
          -- diffAdded = { link = "Added" },

          Removed = { fg = colors.red },
          DiffDelete = { bg = U.darken(colors.red, 0.18, colors.base) },
          -- diffRemoved = { link = "Removed" },

          Changed = { fg = colors.yellow },
          -- diffChanged = { link = "Changed" },
          DiffChange = { bg = U.darken(colors.yellow, 0.07, colors.base) },
        }
      end,
    },
  },
}

return M
