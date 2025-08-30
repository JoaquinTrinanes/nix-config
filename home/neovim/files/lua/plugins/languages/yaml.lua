local U = require("config.util")

---@type LazyPluginSpec[]
return {
  { "b0o/SchemaStore.nvim" },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        yamlls = {
          before_init = function(_, config)
            config.settings.yaml.schemas = config.settings.yaml.schemas or {}
            config.settings.yaml.schemas = vim.tbl_extend(
              "force",
              require("schemastore").yaml.schemas(U.opts("SchemaStore.nvim")),
              config.settings.yaml.schemas
            )
          end,
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              keyOrdering = false,
              format = {
                enable = true,
              },
              validate = true,
              schemaStore = {
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
              },
            },
          },
        },
      },
    },
  },
}
