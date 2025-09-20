local U = require("config.util")

---@type LazyPluginSpec[]
local M = {
  {
    "p00f/clangd_extensions.nvim",
    lazy = true,
    config = function() end,
    opts = {
      inlay_hints = {
        inline = false,
      },
      ast = {
        --These require codicons (https://github.com/microsoft/vscode-codicons)
        role_icons = {
          type = "",
          declaration = "",
          expression = "",
          specifier = "",
          statement = "",
          ["template argument"] = "",
        },
        kind_icons = {
          Compound = "",
          Recovery = "",
          TranslationUnit = "",
          PackExpansion = "",
          TemplateTypeParm = "",
          TemplateTemplateParm = "",
          TemplateParamObject = "",
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
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
      if not dap.adapters["lldb"] then
        require("dap").adapters["lldb"] = {
          type = "executable",
          command = "lldb",
          name = "lldb",

          -- host = "localhost",
          -- port = "${port}",
          -- executable = {
          --   command = "codelldb",
          --   args = {
          --     "--port",
          --     "${port}",
          --   },
          -- },
        }
      end
      for _, lang in ipairs({ "c", "cpp" }) do
        dap.configurations[lang] = {
          {
            name = "Launch",
            type = "lldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
          -- {
          --   type = "codelldb",
          --   request = "launch",
          --   name = "Launch file",
          --   program = function()
          --     return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          --   end,
          --   cwd = "${workspaceFolder}",
          -- },
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

U.lsp.on_attach(function(client, buffer)
  if not U.has("clangd_extensions.nvim") then
    return
  end
  local clangd_ext_opts = U.opts("clangd_extensions.nvim")
  require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = client.config }))
end, "clangd")

return M
