---@type LazyPluginSpec[]
return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts_extend = {
      "servers.vtsls.settings.typescript.tsserver.pluginPaths",
      "servers.vtsls.settings.vtsls.tsserver.globalPlugins",
    },
    ---@type LspConfig
    opts = {
      ---@type table<string, ExtendedLspConfig>
      servers = {
        vtsls = {
          settings = {
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                maxInlayHintLength = 30,
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                -- This slows down the server a LOT
                -- parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
          keys = {
            {
              "gD",
              function()
                local params = vim.lsp.util.make_position_params(0, "utf-8")
                require("trouble").open({
                  mode = "lsp_command",
                  params = {
                    command = "typescript.goToSourceDefinition",
                    arguments = { params.textDocument.uri, params.position },
                  },
                })
              end,
              desc = "Goto Source Definition",
            },
            {
              "gR",
              function()
                require("trouble").open({
                  mode = "lsp_command",
                  params = {
                    command = "typescript.findAllFileReferences",
                    arguments = { vim.uri_from_bufnr(0) },
                  },
                })
              end,
              desc = "File References",
            },
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = { "source.organizeImports" },
                    diagnostics = {},
                  },
                })
              end,
              desc = "Organize Imports",
            },
            {
              "<leader>cM",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = {
                      ---@diagnostic disable-next-line: assign-type-mismatch
                      "source.addMissingImports.ts",
                    },
                    diagnostics = {},
                  },
                })
              end,
              desc = "Add missing imports",
            },
            {
              "<leader>cu",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = {
                      ---@diagnostic disable-next-line: assign-type-mismatch
                      "source.removeUnused.ts",
                    },
                    diagnostics = {},
                  },
                })
              end,
              desc = "Remove unused imports",
            },
            {
              "<leader>cD",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = {
                      ---@diagnostic disable-next-line: assign-type-mismatch
                      "source.fixAll.ts",
                    },
                    diagnostics = {},
                  },
                })
              end,
              desc = "Fix all diagnostics",
            },
            {
              "<leader>cV",
              function()
                require("trouble").open({
                  mode = "lsp_command",
                  params = {
                    command = "typescript.selectTypeScriptVersion",
                  },
                })
              end,
              desc = "Select TS workspace version",
            },
          },
          on_attach = function(client, buffer)
            client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
              ---@type string, string, lsp.Range
              local action, uri, range = unpack(command.arguments)

              local function move(newf)
                ---@diagnostic disable-next-line: param-type-mismatch
                client:request("workspace/executeCommand", {
                  command = command.command,
                  arguments = { action, uri, range, newf },
                })
              end

              local fname = vim.uri_to_fname(uri)
              ---@diagnostic disable-next-line: param-type-mismatch
              client:request("workspace/executeCommand", {
                command = "typescript.tsserverRequest",
                arguments = {
                  "getMoveToRefactoringFileSuggestions",
                  {
                    file = fname,
                    startLine = range.start.line + 1,
                    startOffset = range.start.character + 1,
                    endLine = range["end"].line + 1,
                    endOffset = range["end"].character + 1,
                  },
                },
              }, function(_, result)
                ---@type string[]
                local files = result.body.files
                table.insert(files, 1, "Enter new path...")
                vim.ui.select(files, {
                  prompt = "Select move destination:",
                  format_item = function(f)
                    return vim.fn.fnamemodify(f, ":~:.")
                  end,
                }, function(f)
                  if f and f:find("^Enter new path") then
                    vim.ui.input({
                      prompt = "Enter move destination:",
                      default = vim.fn.fnamemodify(fname, ":h") .. "/",
                      completion = "file",
                    }, function(newf)
                      return newf and move(newf)
                    end)
                  elseif f then
                    move(f)
                  end
                end)
              end)
            end
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      if not dap.adapters["pwa-node"] then
        require("dap").adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "js-debug",
            args = {
              "${port}",
            },
          },
        }
      end

      local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

      local vscode = require("dap.ext.vscode")
      vscode.type_to_filetypes["node"] = js_filetypes
      vscode.type_to_filetypes["pwa-node"] = js_filetypes

      for _, language in ipairs(js_filetypes) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
          }
        end
      end
    end,
  },

  -- Filetype icons
  {
    "nvim-mini/mini.icons",
    optional = true,
    opts = {
      file = {
        [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
        [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
        [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
        ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
        ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
      },
    },
  },
}
