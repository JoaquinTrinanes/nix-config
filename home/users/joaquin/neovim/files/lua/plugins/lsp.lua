local classNameRegex = [[(?:(?:[cC]lass[nN]ames?)|(?:CLASSNAMES?))]] -- "[cC][lL][aA][sS][sS][nN][aA][mM][eE][sS]?"
local classNamePropNameRegex = "(?:" .. classNameRegex .. "|(?:enter|leave)(?:From|To)?)"
local quotedStringRegex = [[(?:["'`]([^"'`]*)["'`])]]

--- @param filename string
local is_dotenv = function(filename)
  local name = vim.fs.basename(filename)
  if name == nil then
    return false
  end

  return name == ".env" or name == ".envrc" or name:find("%.env%.[%w_.-]+") ~= nil -- name:find("^%.env%.%a+") == nil
end

local M = {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = {
          prefix = "icons",
        },
      },
      inlay_hints = { enabled = true },
      servers = {
        eslint = {
          settings = {
            rulesCustomizations = {
              { rule = "prettier/prettier", severity = "off" },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space", "missing-fields" },
              },
            },
          },
        },
        tailwindcss = {
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  -- classNames="...", classNames: "..."
                  classNamePropNameRegex
                    .. [[\s*[:=]\s*]]
                    .. quotedStringRegex,
                  -- classNames={...} prop
                  classNamePropNameRegex
                    .. [[\s*[:=]\s*]]
                    .. quotedStringRegex
                    -- {
                    .. [[\s*}]],
                  -- classNames(...)
                  { [[class[nN]ames\(([^)]*)\)]], quotedStringRegex },
                },
              },
            },
          },
        },
        intelephense = { settings = { ["intelephense.files.maxSize"] = 10000000 } },
        prismals = {},
        nil_ls = { mason = false },
        nushell = { mason = false },
        marksman = { mason = false },
        phpactor = {
          mason = false,
          enabled = false,
        },
      },
      setup = {},
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = {
          "shellcheck",
          -- "dotenv_linter",
        },
        nix = { "statix", "deadnix" },
      },
      linters = {
        dotenv_linter = {
          condition = function(ctx)
            return is_dotenv(ctx.filename)
          end,
        },
        shellcheck = {
          condition = function(ctx)
            return not is_dotenv(ctx.filename)
          end,
        },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      local servers_to_skip = {
        "marksman",
      }

      opts.ensure_installed = vim.tbl_filter(function(server)
        return not vim.list_contains(servers_to_skip, server)
      end, opts.ensure_installed)
      -- vim.list_extend(opts.ensure_installed, {
      --   "prettier",
      --   "stylua",
      --   "shfmt",
      -- })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      format = {
        -- lsp_fallback = "always",
        lsp_fallback = true,
      },
      ---@type table<string, conform.FormatterUnit[]>
      formatters_by_ft = {
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
      ---@type table<string, conform.FormatterConfig|fun(bufnr: integer): nil|conform.FormatterConfig>
      formatters = {},
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      lsp = { hover = { silent = true } },
    },
  },
  { "imsnif/kdl.vim", ft = { "kdl" } },
  { "prisma/vim-prisma", ft = { "prisma" } },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config["blade"] = {
        install_info = {
          url = "https://github.com/EmranMR/tree-sitter-blade",
          files = { "src/parser.c" },
          branch = "main",
        },
        filetype = "blade",
      }

      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "blade" })
      end
    end,
  },
}

return M
