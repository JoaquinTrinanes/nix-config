local classNameRegex = "[cC][lL][aA][sS][sS][nN][aA][mM][eE][sS]?"
local classNamePropNameRegex = "(?:" .. classNameRegex .. "|(?:enter|leave)(?:From|To)?)"
local quotedStringRegex = [[(?:["'`]([^"'`]*)["'`])]]

local M = {
  {
    "neovim/nvim-lspconfig",
    ---@module "lspconfig"
    ---@type PluginLspOpts
    opts = {
      diagnostics = {
        virtual_text = {
          prefix = "icons",
        },
      },
      inlay_hints = {
        enabled = true,
        exclude = { "typescript", "typescriptreact" },
      },
      ---@module "lspconfig"
      ---@type table<string, lspconfig.Config>
      servers = {
        eslint = {
          settings = {
            rulesCustomizations = {
              { rule = "prettier/prettier", severity = "off" },
            },
          },
        },
        lua_ls = {
          mason = false,
          settings = {
            Lua = {
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space", "missing-fields" },
              },
            },
          },
        },
        -- denols = {
        --   mason = false,
        --   root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
        -- },
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

                  { "cva\\(((?:[^()]|\\([^()]*\\))*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "cx\\(((?:[^()]|\\([^()]*\\))*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                },
              },
            },
          },
        },
        ["rust_analyzer"] = {
          mason = false,
          checkOnSave = {
            extraArgs = {
              -- -- prevent blocking compilation while indexing
              -- "--target-dir",
              -- "/tmp/rust-analyzer-check",
            },
          },
        },
        intelephense = {
          mason = false,
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
        nushell = { mason = false },
        marksman = { mason = false },
        -- Ideally, use only nixd. But it breaks with accents/special chars
        nil_ls = {
          mason = false,
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
          mason = false,
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
        ruff = { mason = false },
        r_language_server = { mason = false },
        biome = { mason = false },
        tinymist = { mason = false },
      },
      ---@module "lspconfig"
      ---@type table<string, fun(server:string, opts:lspconfig.Config):boolean?>
      setup = {},
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        php = {},
        nix = { "statix", "deadnix" },
      },
      ---@module "lint"
      ---@class lint.Linter
      ---@field condition fun(ctx: { filename: string, dirname: string }): boolean
      ---@type table<string, lint.Linter>
      linters = {
        shellcheck = {
          condition = function(ctx)
            local name = vim.fs.basename(ctx.filename)
            if name == nil then
              return false
            end

            return name == ".env" or name == ".envrc" or vim.startswith(name, ".env.")
          end,
        },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if vim.g.usePluginsFromStore then
        opts.ensure_installed = {}
        opts.automatic_installation = false
        return
      end

      local servers_to_skip = {
        "marksman",
      }

      opts.PATH = "append"
      opts.ensure_installed = vim.tbl_filter(function(server)
        return not vim.list_contains(servers_to_skip, server)
      end, opts.ensure_installed)
    end,
  },
  {
    "folke/ts-comments.nvim",
    optional = true,
    opts = {
      lang = {
        -- Fix being unable to uncomment comments
        phpdoc = { "// %s" },
      },
    },
  },
  {
    "folke/noice.nvim",
    optional = true,
    opts = {
      lsp = { hover = { silent = true } },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if vim.g.usePluginsFromStore then
        opts.ensure_installed = {}
        return
      end

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
        vim.list_extend(opts.ensure_installed, { "blade", "php", "php_only", "html", "css" })
      end
    end,
  },
}

return M
