local classNameRegex = [[(?:(class[nN]ames?)|(CLASSNAMES?))]] -- "[cC][lL][aA][sS][sS][nN][aA][mM][eE][sS]?"
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
      servers = {
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
          keys = {
            {
              "<leader>cE",
              function()
                require("rust-tools").expand_macro.expand_macro()
              end,
              desc = "Expand Macro (Rust)",
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
                  -- --classNames={...} prop
                  -- classNamePropNameRegex
                  --   .. [[\s*[:=]\s*]]
                  --   .. quotedStringRegex
                  --   .. [[\s*}]],
                  -- classNames(...)
                  { [[class[nN]ames\(([^)]*)\)]], quotedStringRegex },
                },
              },
            },
          },
        },
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
  { "folke/noice.nvim", opts = { lsp = { hover = { silent = true } } } },
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
  {
    "LhKipp/nvim-nu",
    dependencies = {
      -- {
      --   "zioroboco/nu-ls.nvim",
      --   ft = { "nu" },
      --   config = function()
      --     local ok, nls = pcall(require, "null-ls")
      --     if not ok then
      --       return
      --     end
      --     nls.register(require("nu-ls"))
      --   end,
      -- },
    },
    event = "BufRead",
    build = ":TSInstall nu",
    opts = {
      use_lsp_features = false,
      all_cmd_names = [[nu -c 'help commands | get name | str join (char newline)']],
    },
    config = true,
  },
  { "imsnif/kdl.vim", ft = { "kdl" } },
}

return M
