local M = {
  {
    "stevearc/conform.nvim",
    opts = {
      ---@type table<string, conform.FormatterUnit[]>
      formatters_by_ft = {
        toml = { "taplo" },
        php = { "pint" },
        nix = { { "alejandra", "nixfmt" } },
        markdown = { "injected", "prettier" },
        ["_"] = {
          "trim_whitespace",
        },
      },
      ---@type table<string, conform.FormatterConfig|fun(bufnr: integer): nil|conform.FormatterConfig>
      formatters = {
        ["nix-flake-fmt"] = {
          command = "nix",
          args = { "fmt", "$FILENAME" },
          condition = function(ctx)
            return vim.fs.find({ "flake.nix" }, { path = ctx.filename, upward = true })[1] ~= nil
          end,
          stdin = false,
          -- condition = function(ctx)
          --   return require("conform.util").root_file({ "flake.nix" })
          -- end,
          --           condition = function(ctx)
          -- return
          --           end
        },
        ---@diagnostic disable-next-line: missing-fields
        prettier = {
          condition = function(ctx)
            local eslint = require("lazyvim.util").lsp.get_clients({ name = "eslint", buf = ctx.buf })[1]
            if eslint == nil then
              return true
            end
            return not eslint.server_capabilities.documentFormattingProvider
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        nix = { "statix" },
      },
      linters = {
        shellcheck = {
          condition = function(ctx)
            return ctx.filename:find(".env$") == nil
          end,
        },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "prettier",
        "stylua",
        "shfmt",
      })
    end,
  },
}

return M
