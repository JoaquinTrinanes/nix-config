local classNameRegex = [[(?:(?:[cC]lass[nN]ames?)|(?:CLASSNAMES?))]] -- "[cC][lL][aA][sS][sS][nN][aA][mM][eE][sS]?"
local classNamePropNameRegex = "(?:" .. classNameRegex .. "|(?:enter|leave)(?:From|To)?)"
local quotedStringRegex = [[(?:["'`]([^"'`]*)["'`])]]

local bufCache = {}

--- @param filename string
local is_dotenv = function(filename)
  local name = vim.fs.basename(filename)
  if name == nil then
    return false
  end

  return name == ".env" or name == ".envrc" or name:find("%.env%.[%w_.-]+") ~= nil -- name:find("^%.env%.%a+") == nil
end

local function merge_in_place(a, b)
  if type(a) == "table" and type(b) == "table" then
    for k, v in pairs(b) do
      if type(v) == "table" and type(a[k] or false) == "table" then
        merge_in_place(a[k], v)
      else
        a[k] = v
      end
    end
  end
  return a
end

local detachEslintIfIgnored = function(client, bufnr)
  local ok, is_exe = pcall(vim.fn.executable, "eslint")
  if not ok or is_exe == 0 then
    return
  end
  local Job = require("plenary.job")
  local file = vim.api.nvim_buf_get_name(bufnr)

  Job:new({
    command = "eslint",
    args = { "--format", "json", file },
    detached = true,
    on_stdout = function(_, data)
      local response = vim.json.decode(data)
      local error = ((response[1] or {}).messages[1] or {}).message
      if error == nil then
        return
      end
      local is_ignored = error:match("%-%-no%-ignore") ~= nil
      if is_ignored then
        vim.schedule(function()
          vim.lsp.buf_detach_client(bufnr, client.id)
        end)
      end
    end,
  }):start()
end

local M = {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("LspDetach", {
        callback = function(e)
          bufCache[e.buf] = {}
        end,
      })

      merge_in_place(opts, {
        diagnostics = {
          virtual_text = {
            prefix = "icons",
          },
        },
        inlay_hints = {
          enabled = true,
        },
        -- codelens = { enabled = vim.fn.has("nvim-0.10") },
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
          nushell = { mason = false },
          marksman = { mason = false },
          intelephense = {},
          -- nixd = { mason = false },
        },
        setup = {
          eslint = function()
            require("lazyvim.util").lsp.on_attach(function(client, bufnr)
              if client.name == "eslint" then
                client.server_capabilities.documentFormattingProvider = true
                detachEslintIfIgnored(client, bufnr)
              elseif client.name == "tsserver" then
                client.server_capabilities.documentFormattingProvider = false
              end
            end)
          end,
        },
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = {
          "shellcheck",
          -- "dotenv_linter",
        },
        nix = { "statix" },
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
        nix = { { "alejandra", "nixfmt" } },
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
      formatters = {
        prettier = {
          --- @param ctx {filename: string, dirname: string, buf: number}
          ---@diagnostic disable-next-line: unused-local
          condition = function(self, ctx)
            local is_prettier_enabled = (bufCache[ctx.buf] or {})["is_prettier_enabled"]
            if is_prettier_enabled ~= nil then
              return is_prettier_enabled
            end

            local get_is_prettier_enabled = function()
              local eslint = require("lazyvim.util").lsp.get_clients({ name = "eslint", buf = ctx.buf })[1]
              if eslint == nil or not eslint.server_capabilities.documentFormattingProvider then
                return true
              end

              local handle, err = io.popen("eslint --print-config " .. ctx.filename .. " --format json")
              if handle == nil or err ~= nil then
                return true
              end
              local response = handle:read("*a")
              handle:close()
              response = vim.json.decode(response)
              local eslintPrettierConfig = (response.rules["prettier/prettier"] or {})[1] or "off"
              return eslintPrettierConfig == "off"
            end

            is_prettier_enabled = get_is_prettier_enabled()

            bufCache[ctx.buf] =
              vim.tbl_extend("force", bufCache[ctx.buf] or {}, { is_prettier_enabled = is_prettier_enabled })

            return is_prettier_enabled
          end,
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      lsp = { hover = { silent = true } },
    },
  },
  {
    "LhKipp/nvim-nu",
    ft = { "nu" },
    build = ":TSInstall nu",
    opts = {
      use_lsp_features = false,
      all_cmd_names = [[nu -c 'help commands | get name | str join (char newline)']],
    },
    config = true,
  },
  { "imsnif/kdl.vim", ft = { "kdl" } },
  { "prisma/vim-prisma", ft = { "prisma" } },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = "all"

      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config["blade"] = {
        install_info = {
          url = "https://github.com/EmranMR/tree-sitter-blade",
          files = { "src/parser.c" },
          branch = "main",
        },
        filetype = "blade",
      }
    end,
  },
}

return M
