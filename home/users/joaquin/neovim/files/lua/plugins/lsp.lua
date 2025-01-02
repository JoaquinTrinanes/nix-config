local classNameRegex = "[cC][lL][aA][sS][sS][nN][aA][mM][eE][sS]?"
local classNamePropNameRegex = "(?:" .. classNameRegex .. "|(?:enter|leave)(?:From|To)?)"
local quotedStringRegex = [[(?:["'`]([^"'`]*)["'`])]]

--- @param filename string
local is_dotenv = function(filename)
  local name = vim.fs.basename(filename)
  if name == nil then
    return false
  end

  return name == ".env" or name == ".envrc" or vim.startswith(name, ".env.")
end

local M = {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts_extend = { "library" },
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        -- { path = "LazyVim", words = { "LazyVim" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
      },
    },
  },
  -- {
  --   "folke/lazydev.nvim",
  --   ft = "lua",
  --   opts = {
  --     library = {
  --       -- Load luvit types when the `vim.uv` word is found
  --       { path = "luvit-meta/library", words = { "vim%.uv" } },
  --     },
  --   },
  -- },
  -- { "Bilal2453/luvit-meta", lazy = true },
  {
    "neovim/nvim-lspconfig",
    -- dependencies = {
    --   { "williamboman/mason.nvim", config = true },
    --   { "williamboman/mason-lspconfig.nvim", config = function() end },
    --   -- "WhoIsSethDaniel/mason-tool-installer.nvim",
    --   -- "blink.cmp",
    --   { "j-hui/fidget.nvim", opts = {} },
    -- },
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
                },
              },
            },
          },
        },
        rust_analyzer = {
          enabled = false,
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
                maxMemoryMB = 3584,
                flake = {
                  autoArchive = true,
                  autoEvalInputs = true,
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
        r_language_server = { mason = false },
      },
      ---@module "lspconfig"
      ---@type table<string, fun(server:string, opts:lspconfig.Config):boolean?>
      setup = {},
    },
    -- config = function(_, opts)
    --   local capabilities = vim.tbl_deep_extend(
    --     "force",
    --     {},
    --     vim.lsp.protocol.make_client_capabilities(),
    --     -- has_cmp and cmp_nvim_lsp.default_capabilities() or {},
    --     -- has_blink and blink.get_lsp_capabilities() or {},
    --     opts.capabilities or {}
    --   )
    --   local function setup(server)
    --     local server_opts = vim.tbl_deep_extend("force", {
    --       capabilities = vim.deepcopy(capabilities),
    --     }, opts.servers[server] or {})
    --     if server_opts.enabled == false then
    --       return
    --     end
    --
    --     if opts.setup[server] then
    --       if opts.setup[server](server, server_opts) then
    --         return
    --       end
    --     elseif opts.setup["*"] then
    --       if opts.setup["*"](server, server_opts) then
    --         return
    --       end
    --     end
    --
    --     require("lspconfig")[server].setup(server_opts)
    --   end
    --
    --   -- get all the servers that are available through mason-lspconfig
    --   local have_mason, mlsp = pcall(require, "mason-lspconfig")
    --   local all_mslp_servers = {}
    --   if have_mason then
    --     all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
    --   end
    --
    --   local ensure_installed = {} ---@type string[]
    --   for server, server_opts in pairs(opts.servers) do
    --     if server_opts then
    --       server_opts = server_opts == true and {} or server_opts
    --       if server_opts.enabled ~= false then
    --         -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
    --         if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
    --           setup(server)
    --         else
    --           ensure_installed[#ensure_installed + 1] = server
    --         end
    --       end
    --     end
    --   end
    --
    --   if have_mason then
    --     mlsp.setup({
    --       ensure_installed = vim.tbl_deep_extend(
    --         "force",
    --         ensure_installed,
    --         plugin_opts("mason-lspconfig.nvim").ensure_installed or {}
    --       ),
    --       handlers = { setup },
    --     })
    --   end
    --
    --   -- for server, _ in pairs(opts.servers) do
    --   --   setup(server)
    --   -- end
    -- end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        sh = {
          "shellcheck",
          -- "dotenv_linter",
        },
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
            return not is_dotenv(ctx.filename)
          end,
        },
      },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          -- try_lint without arguments runs the linters defined in `linters_by_ft`
          -- for the current filetype
          require("lint").try_lint()
        end,
        -- callback = M.debounce(100, M.lint),
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    enabled = false,
    -- enabled = not vim.g.usePluginsFromStore,
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
    "folke/noice.nvim",
    optional = true,
    opts = {
      lsp = { hover = { silent = true } },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufWritePost", "BufReadPost", "InsertLeave" },
    opts = function()
      local tsc = require("treesitter-context")
      Snacks.toggle({
        name = "Treesitter Context",
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map("<leader>ut")
      return { mode = "cursor", max_lines = 3 }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts_extend = { "ensure_installed" },
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
-- return X
