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
      flavour = "frappe",
      term_colors = true,
      custom_highlights = function(colors)
        return {
          LspSignatureActiveParameter = { style = { "bold" } },
          SpellBad = {
            sp = colors.subtext0,
          },
        }
      end,
    },
  },
}

return M
