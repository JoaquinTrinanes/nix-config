---@type LazyPluginSpec[]
local M = {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    ---@type LspConfig
    opts = {
      servers = {
        clangd = {
          keys = {
            { "<leader>ch", "<Cmd>LspClangdSwitchSourceHeader<CR>", desc = "Switch Source/Header (C/C++)" },
          },
          cmd = {
            "clangd",
            "--background-index",
            -- "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
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
      if not dap.adapters["codelldb"] then
        dap.adapters["codelldb"] = {
          type = "executable",
          command = "codelldb",
        }
      end
      for _, lang in ipairs({ "c", "cpp" }) do
        dap.configurations[lang] = {
          {
            type = "codelldb",
            request = "launch",
            name = "Launch File",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            -- TODO: check if projects that don't need this fallback gracefully
            sourceMap = {
              [vim.fn.getcwd() .. "/build"] = vim.fn.getcwd(),
            },
          },
          -- {
          --   type = "codelldb",
          --   request = "attach",
          --   name = "Attach to process",
          --   pid = require("dap.utils").pick_process,
          --   cwd = "${workspaceFolder}",
          -- },
        }
      end
    end,
  },
}

return M
