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
        terraform = { "tofu_fmt", "terraform_fmt", stop_after_first = true },
        nu = { "topiary_nu" },
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
  {
    -- disable LazyVim's LSP formatter. That's already handled by conform.nvim
    "my/formatter-resolver-override",
    event = "LazyFile",
    virtual = true,
    init = function()
      local format_util = require("lazyvim.util.format")

      local original_resolve = format_util.resolve

      format_util.resolve = function(...)
        local resolved = original_resolve(...)

        return vim
          .iter(resolved)
          :filter(function(formatter)
            return formatter.name ~= "LSP"
          end)
          :totable()
      end
    end,
  },
}

return M
