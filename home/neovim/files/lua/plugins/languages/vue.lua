---@type LazyPluginSpec[]
return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    ---@type LspConfig
    opts = {
      servers = {
        vue_ls = {},
        vtsls = {
          settings = {
            typescript = {
              tsserver = {
                pluginPaths = {
                  vim.g.vue_language_server_typescript_plugin_path,
                },
              },
            },
            vtsls = {
              tsserver = {
                globalPlugins = {
                  {
                    name = "@vue/typescript-plugin",
                    languages = { "vue" },
                    configNamespace = "typescript",
                    enableForWorkspaceTypeScriptVersions = true,
                  },
                },
              },
            },
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    ---@param opts LspConfig
    opts = function(_, opts)
      opts.servers.vtsls.filetypes = opts.servers.vtsls.filetypes or vim.lsp.config.vtsls.filetypes or {}
      table.insert(opts.servers.vtsls.filetypes, "vue")
    end,
  },
}
