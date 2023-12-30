local M = {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "frappe",
      custom_highlights = function()
        return {
          LspSignatureActiveParameter = { style = { "bold" } },
        }
      end,
    },
  },
}

return M
