local M = {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      integrations = {
        native_lsp = {
          underlines = {
            errors = { "undercurl" },
            -- hints = { "underline" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            -- information = { "underline" },
            information = { "undercurl" },
          },
        },
      },
      flavour = "auto", -- latte, frappe, macchiato, mocha
      background = { -- :h background
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
          DiffAdd = { bg = U.darken(colors.blue, 0.18, colors.base) },
          -- DiffDelete = { bg = U.darken(colors.red, 0.18, colors.base) },
          -- DiffChange = { bg = U.darken(colors.blue, 0.07, colors.base) },
        }
      end,
    },
  },
}

return M
