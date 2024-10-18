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
        gitsigns = false,
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
