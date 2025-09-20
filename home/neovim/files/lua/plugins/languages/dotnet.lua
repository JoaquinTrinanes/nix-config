---@type LazyPluginSpec[]
return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
        -- fsharp = { "fantomas" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    ---@type LspConfig
    opts = {
      servers = {
        roslyn_ls = {
          settings = {
            ["csharp|background_analysis"] = {
              -- dotnet_analyzer_diagnostics_scope = "none",
            },
            ["csharp|formatting"] = { dotnet_organize_imports_on_format = true },
            ["csharp|inlay_hints"] = {
              csharp_enable_inlay_hints_for_implicit_object_creation = true,
              csharp_enable_inlay_hints_for_implicit_variable_types = true,
            },
            ["csharp|code_lens"] = {
              dotnet_enable_references_code_lens = true,
            },
            ["csharp|quick_info"] = {},
            ["csharp|completion"] = {
              dotnet_provide_regex_completions = true,
              dotnet_show_completion_items_from_unimported_namespaces = true,
              dotnet_show_name_completion_suggestions = true,
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
      if not dap.adapters.netcoredbg then
        dap.adapters.netcoredbg = {
          type = "executable",
          command = vim.fn.exepath("netcoredbg"),
          args = { "--interpreter=vscode" },
          options = {
            detached = false,
          },
        }
      end
      dap.adapters.coreclr = dap.adapters.coreclr or dap.adapters.netcoredbg
      for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
        dap.configurations[lang] = dap.configurations[lang]
          or {
            {
              type = "netcoredbg",
              name = "Launch file",
              request = "launch",
              program = function()
                return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
              end,
              cwd = "${workspaceFolder}",
            },
            {
              type = "netcoredbg",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              request = "attach",
              -- program = function()
              --   return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
              -- end,
              cwd = "${workspaceFolder}",
            },
          }
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
