local classNameRegex = [[(?:(?:[cC]lass[nN]ames?)|(?:CLASSNAMES?))]] -- "[cC][lL][aA][sS][sS][nN][aA][mM][eE][sS]?"
local classNamePropNameRegex = "(?:" .. classNameRegex .. "|(?:enter|leave)(?:From|To)?)"
local quotedStringRegex = [[(?:["'`]([^"'`]*)["'`])]]

local M = {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = {
          prefix = "icons",
        },
      },
      inlay_hints = {
        enabled = true,
      },
      --- @type lspconfig.options
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space", "missing-fields" },
              },
            },
          },
        },
        nushell = {},
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              -- prevent locking cargo compilation
              ---@diagnostic disable-next-line: assign-type-mismatch
              checkOnSave = {
                extraArgs = { "--target-dir", "/tmp/rust-analyzer-check" },
              },
            },
          },
          -- keys = {
          --   {
          --     "<leader>cE",
          --     function()
          --       require("rust-tools").expand_macro.expand_macro()
          --     end,
          --     desc = "Expand Macro (Rust)",
          --   },
          -- },
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
        prismals = {},
        nil_ls = { mason = false },
        -- rnix = { mason = false },
      },
      setup = {
        eslint = function()
          require("lazyvim.util").lsp.on_attach(function(client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == "tsserver" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
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
  {
    "stevearc/conform.nvim",
    opts = {
      lsp_fallback = "always",
      ---@type table<string, conform.FormatterUnit[]>
      formatters_by_ft = {
        toml = { "taplo" },
        php = { "pint" },
        nix = { { "alejandra", "nixfmt" } },
        markdown = {
          -- "injected",
          "prettier",
        },
        -- ["_"] = {
        --   "trim_whitespace",
        -- },
      },
      ---@type table<string, conform.FormatterConfig|fun(bufnr: integer): nil|conform.FormatterConfig>
      formatters = {
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
    "williamboman/mason.nvim",
    opts = function(_, _opts)
      local opts = _opts
      opts.ensure_installed = opts.ensure_installed or {}

      vim.list_extend(opts.ensure_installed, {
        "taplo",
        "intelephense",
        "pyright",
      })
    end,
  },
  { "folke/noice.nvim", opts = { lsp = { hover = { silent = true } } } },
  {
    "LhKipp/nvim-nu",
    event = "BufRead",
    build = ":TSInstall nu",
    opts = {
      use_lsp_features = false,
      all_cmd_names = [[nu -c 'help commands | get name | str join (char newline)']],
    },
    config = true,
  },
  { "imsnif/kdl.vim", ft = { "kdl" } },
  { "prisma/vim-prisma", ft = { "prisma" } },
}

return M
