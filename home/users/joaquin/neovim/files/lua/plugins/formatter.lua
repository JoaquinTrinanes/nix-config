vim.g.lazyvim_prettier_needs_config = true

local M = {
  {
    "stevearc/conform.nvim",
    optional = true,
    ---@module "conform.types"
    ---@type conform.setupOpts
    opts = {
      default_format_opts = {},
      formatters_by_ft = {
        html = { "prettier", "biome-check", stop_after_first = true },
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
  {
    "stevearc/conform.nvim",
    ---@module "conform.types"
    ---@param opts conform.setupOpts
    opts = function(_, opts)
      for ft, formatters in pairs(opts.formatters_by_ft) do
        if type(formatters) == "table" then
          for i, formatter in ipairs(formatters) do
            if formatter == "biome" then
              opts.formatters_by_ft[ft][i] = "biome-check"
              if vim.list_contains(formatters, "prettier") and opts.formatters_by_ft[ft].stop_after_first == nil then
                opts.formatters_by_ft[ft].stop_after_first = true
              end
              break
            end
          end
        end
      end
    end,
  },
}

return M
