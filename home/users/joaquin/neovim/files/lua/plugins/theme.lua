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
      flavour = "frappe",
      term_colors = true,
      custom_highlights = function()
        return {
          LspSignatureActiveParameter = { style = { "bold" } },
        }
      end,
    },
  },
}

return M
