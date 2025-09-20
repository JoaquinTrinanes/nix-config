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
      { "<leader>D", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
    },
    init = function()
      local data_path = vim.fn.stdpath("data")

      local function get_first_db_url()
        if not vim.g.dbs then
          return nil
        end
        for _, db in ipairs(vim.g.dbs) do
          local url
          if type(db.url) == "function" then
            local ok, res = pcall(db.url)
            if ok then
              url = res
            end
          else
            url = db.url
          end
          if url and url ~= "" then
            return url
          end
        end
        return nil
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql" },
        callback = vim.schedule_wrap(function(args)
          local url = get_first_db_url()
          if url then
            vim.b[args.buf].db = url
          end
        end),
      })

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
