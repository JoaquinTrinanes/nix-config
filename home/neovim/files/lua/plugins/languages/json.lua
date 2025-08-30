local U = require("config.util")

---@type LazyPluginSpec[]
return {
  { "b0o/SchemaStore.nvim" },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        jsonls = {
          before_init = function(_, config)
            config.settings.json.schemas = config.settings.json.schemas or {}
            vim.list_extend(
              config.settings.json.schemas,
              require("schemastore").json.schemas(U.opts("SchemaStore.nvim"))
            )
          end,
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
          },
        },
      },
    },
  },
}
