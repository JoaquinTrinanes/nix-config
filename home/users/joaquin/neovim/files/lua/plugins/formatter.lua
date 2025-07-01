---@type conform.FiletypeFormatter
local biomePrettierFormatters = { "prettier", "biome-check", stop_after_first = true }

local M = {
  {
    "stevearc/conform.nvim",
    optional = true,
    ---@module "conform.types"
    ---@type conform.setupOpts
    opts = {
      default_format_opts = {},
      formatters_by_ft = {
        astro = biomePrettierFormatters,
        css = biomePrettierFormatters,
        graphql = biomePrettierFormatters,
        html = biomePrettierFormatters,
        javascript = biomePrettierFormatters,
        javascriptreact = biomePrettierFormatters,
        json = biomePrettierFormatters,
        jsonc = biomePrettierFormatters,
        svelte = biomePrettierFormatters,
        typescript = biomePrettierFormatters,
        typescriptreact = biomePrettierFormatters,

        lua = { "stylua" },
        php = { "pint" },
        blade = { "prettier" },
        typst = { "typstyle" },
        ["_"] = {
          "trim_whitespace",
          lsp_format = "prefer",
        },
      },
      formatters = {
        sqlfluff = { require_cwd = false },
        prettier = { require_cwd = true },
        biome = { require_cwd = false },
        ["biome-check"] = { require_cwd = false },
        topiary_nu = {
          command = "topiary",
          args = { "format", "--language", "nu" },
        },
      },
    },
  },
}

return M
