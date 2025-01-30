-- Avoid conflicts with prettier
vim.g.lazyvim_prettier_needs_config = true

local M = {
  {
    "stevearc/conform.nvim",
    optional = true,
    ---@module "conform.types"
    ---@type conform.setupOpts
    opts = {
      default_format_opts = {
      },
      formatters_by_ft = {
        lua = { "stylua" },
        toml = { "taplo" },
        php = { "pint" },
        blade = { "prettier" },
        markdown = {
          -- "injected",
          "prettier",
        },
        ["_"] = {
          "trim_whitespace",
        },
      },
      formatters = {},
    },
  },
}

return M
