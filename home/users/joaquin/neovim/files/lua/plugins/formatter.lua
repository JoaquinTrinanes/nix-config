vim.g.lazyvim_prettier_needs_config = false

local M = {
  {
    "stevearc/conform.nvim",
    optional = true,
    ---@module "conform.types"
    ---@type conform.setupOpts
    opts = {
      default_format_opts = {},
      formatters_by_ft = {
        lua = { "stylua" },
        php = { "pint" },
        blade = { "prettier" },
        ["_"] = {
          "trim_whitespace",
        },
      },
      formatters = {
        sqlfluff = { require_cwd = false },
        topiary_nu = {
          command = "topiary",
          args = { "format", "--language", "nu" },
        },
        biome = {
          -- transform biome into biome-check, but without hardcoding the filetypes
          args = { "check", "--write", "--stdin-file-path", "$FILENAME" },
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
        ---@cast formatters conform.FiletypeFormatterInternal[]
        if vim.islist(formatters) and vim.list_contains(formatters, "biome") then
          for i, formatter in ipairs(formatters) do
            if formatter == "biome" then
              opts.formatters_by_ft[ft][i] = "biome-check"
            end
          end
        end
      end

      for ft, formatters in pairs(opts.formatters_by_ft) do
        ---@cast formatters conform.FiletypeFormatterInternal[]
        if
          vim.islist(formatters)
          and vim.list_contains(formatters, "biome")
          and vim.list_contains(formatters, "prettier")
        then
          opts.formatters_by_ft[ft].stop_after_first = true
        end
      end
    end,
  },
}

return M
