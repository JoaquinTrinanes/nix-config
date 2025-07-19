local U = require("config.util")

local classNameRegex = "[cC][lL][aA][sS][sS][nN][aA][mM][eE][sS]?"
local classNamePropNameRegex = "(?:" .. classNameRegex .. "|(?:enter|leave)(?:From|To)?)"
local quotedStringRegex = [[(?:["'`]([^"'`]*)["'`])]]

U.lsp.on_attach(function(client, buffer)
  if not vim.api.nvim_buf_is_valid(buffer) then
    return
  end
  if client:supports_method("textDocument/inlayHint", buffer) then
    vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
  end
end)

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "LspAttach" },
    ---@class LspConfig
    ---@field servers table<string, ExtendedLspConfig>
    opts = {
      servers = {
        html = {},
        taplo = {},
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
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
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
                    .. [[\s*}]],
                  -- classNames(...)
                  { [[class[nN]ames\(([^)]*)\)]], quotedStringRegex },

                  { "cva\\(((?:[^()]|\\([^()]*\\))*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "cx\\(((?:[^()]|\\([^()]*\\))*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                },
              },
            },
          },
        },
        ["rust_analyzer"] = {},
        intelephense = {
          init_options = {
            globalStoragePath = vim.fn.expand("$XDG_DATA_HOME"),
            licenceKey = vim.fn.expand("$XDG_DATA_HOME/intelephense/licence.txt"),
          },
          settings = {
            intelephense = {
              files = {
                maxSize = 10000000,
              },
            },
            ["intelephense.files.maxSize"] = 10000000,
          },
        },
        nushell = {},
        marksman = {},
        -- Ideally, use only nixd. But it breaks with accents/special chars
        nil_ls = {
          settings = {
            ["nil"] = {
              nix = {
                formattings = { command = "nixfmt" },
                -- maxMemoryMB = 3584,
                flake = {
                  -- autoArchive = true,
                  -- autoEvalInputs = true,
                },
              },
            },
          },
        },
        nixd = {
          settings = {
            nixd = {
              nixpkgs = {
                expr = "import <nixpkgs> { }",
              },
              formatting = {
                command = { "nixfmt" },
              },
              options = {
                nixos = {
                  expr = string.format(
                    '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations."%s".options',
                    vim.fn.system("hostname")
                  ),
                },
                home_manager = {
                  expr = string.format(
                    '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."%s@%s".options',
                    vim.fn.expand("$USER"),
                    vim.fn.systemlist("hostname")[1]
                  ),
                },
                flake_parts = {
                  expr = '(builtins.getFlake ("git+file://" + toString ./.)).debug.options',
                },
                flake_parts_system = {
                  expr = '(builtins.getFlake ("git+file://" + toString ./.)).currentSystem.options',
                },
              },
            },
          },
        },
        bashls = {
          settings = {
            bashIde = { shellcheckPath = "" },
          },
        },
        ruff = {},
        r_language_server = {},
        biome = {},
        tinymist = {},
        -- vtsls = {},
      },
    },
    config = function(_, opts)
      for server, server_config in pairs(opts.servers) do
        U.lsp.config(server, server_config)
      end

      U.lsp.on_attach(require("config.lsp-keymaps").on_attach)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = function()
      local Keys = require("config.lsp-keymaps").get()
      -- stylua: ignore
      vim.list_extend(Keys, {
        { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
        { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
        { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
        { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
      })
    end,
  },
  -- {
  --   "mason-org/mason.nvim",
  --   opts = function(_, opts)
  --     opts.ensure_installed = opts.ensure_installed or {}
  --     if vim.g.nixPureMode then
  --       opts.ensure_installed = {}
  --       opts.automatic_installation = false
  --       return
  --     end
  --
  --     local servers_to_skip = {
  --       "marksman",
  --     }
  --
  --     opts.PATH = "append"
  --     opts.ensure_installed = vim.tbl_filter(function(server)
  --       return not vim.list_contains(servers_to_skip, server)
  --     end, opts.ensure_installed)
  --   end,
  -- },
}
