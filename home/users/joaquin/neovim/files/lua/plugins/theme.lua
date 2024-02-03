local M = {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
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
