local U = require("config.util")

---@type LazyPluginSpec[]
return {
  { "tpope/vim-dadbod", lazy = true, cmd = "DB" },
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = {
      { "vim-dadbod" },
      {
        "kristijanhusak/vim-dadbod-completion",
        dependencies = { "vim-dadbod" },
        ft = { "sql" },
      },
    },
    keys = {
      { "<leader>D", "<Cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql" },
        callback = vim.schedule_wrap(function(args)
          if vim.g.dbs and vim.g.dbs[1] and vim.g.dbs[1].url then
            local url = vim.g.dbs[1].url
            if not url then
              return
            end
            if type(url) == "function" then
              url = url()
            end
            if url then
              vim.b[args.buf].db = url
            end
          end
        end),
      })

      local data_path = vim.fn.stdpath("data")

      -- vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_save_location = vim.fs.joinpath(data_path, "dadbod_ui")
      vim.g.db_ui_show_database_icon = vim.o.termguicolors
      vim.g.db_ui_use_nerd_fonts = vim.o.termguicolors
      vim.g.db_ui_use_nvim_notify = true
      vim.g.db_ui_execute_on_save = false
    end,
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        per_filetype = {
          sql = { inherit_defaults = true, "dadbod" },
        },
        providers = {
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
            fallbacks = { "lsp" },
            override = {
              get_completions = function(prev, ctx, callback)
                local ok, result = pcall(prev.get_completions, prev, ctx, callback)
                if not ok then
                  vim.notify_once(result, vim.log.levels.WARN)
                end
                return ok and result or function() end
              end,
            },
          },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = { sql = { "sqlfluff" } },
      formatters = {
        sqlfluff = {
          append_args = { "--dialect=ansi" },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = { linters_by_ft = { sql = { "sqlfluff" } } },
  },
}
