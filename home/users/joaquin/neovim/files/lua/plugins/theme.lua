local M = {
  -- {
  --   "vimpostor/vim-lumen",
  --   enabled = false,
  --   lazy = false,
  --   -- config = function()
  --   --   vim.api.nvim_create_autocmd("User", {
  --   --     pattern = "LumenLight",
  --   --     callback = function()
  --   --       vim.print("Entered light mode")
  --   --     end,
  --   --   })
  --   --   vim.api.nvim_create_autocmd("User", {
  --   --     pattern = "LumenDark",
  --   --     callback = function()
  --   --       vim.print("Entered dark mode")
  --   --     end,
  --   --   })
  --   -- end,
  -- },
  { "folke/tokyonight.nvim", lazy = false, optional = true, enabled = false },
  {
    "catppuccin/nvim",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("catppuccin")
    end,
    -- optional = true,
    name = "catppuccin",
    opts = {
      integrations = {
        blink_cmp = true,
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
