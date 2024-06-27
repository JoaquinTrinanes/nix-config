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
        return {
          LspSignatureActiveParameter = { style = { "bold" } },
          SpellBad = {
            sp = colors.subtext0,
          },
          -- Colorblind-friendliness
          -- DiffAdd = {
          --   bg = "#acd6fc",
          -- },
          -- diffRemoved = {
          --   bg = "#e7a100",
          -- },
        }
      end,
    },
  },
}

return M
