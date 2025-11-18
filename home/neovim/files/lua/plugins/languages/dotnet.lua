---@type LazyPluginSpec[]
return {
  { "Hoffs/omnisharp-extended-lsp.nvim", lazy = true },
  {
    "neovim/nvim-lspconfig",
    opts = {
      ---@type table<string, vim.lsp.ClientConfig>
      servers = {
        -- fsautocomplete = {},
        omnisharp = {
          handlers = {
            ["textDocument/definition"] = function(...)
              return require("omnisharp_extended").handler(...)
            end,
          },
          keys = {
            {
              "gd",
              function()
                require("omnisharp_extended").lsp_definitions()
              end,
              desc = "Goto Definition",
            },
          },
          settings = {
            FormattingOptions = { OrganizeImports = true },
            RoslynExtensionsOptions = {
              EnableAnalyzersSupport = true,
              EnableImportCompletion = true,
              EnableDecompilationSupport = true,
            },
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      if not dap.adapters["netcoredbg"] then
        require("dap").adapters["netcoredbg"] = {
          type = "executable",
          command = vim.fn.exepath("netcoredbg"),
          args = { "--interpreter=vscode" },
          options = {
            detached = false,
          },
        }
      end
      for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
        if not dap.configurations[lang] then
          dap.configurations[lang] = {
            {
              type = "netcoredbg",
              name = "Launch file",
              request = "launch",
              ---@diagnostic disable-next-line: redundant-parameter
              program = function()
                return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
              end,
              cwd = "${workspaceFolder}",
            },
          }
        end
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "Nsidorenco/neotest-vstest",
    },
    opts = {
      adapters = {
        ["neotest-vstest"] = {
          -- Here we can set options for neotest-vstest
        },
      },
    },
  },
}
