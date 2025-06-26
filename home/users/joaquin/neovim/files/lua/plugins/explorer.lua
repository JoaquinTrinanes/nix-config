local M = {
  {
    "stevearc/oil.nvim",
    enabled = false,
    event = "VeryLazy",
    cmd = { "Oil" },
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      default_file_explorer = false,
      columns = {
        -- "permissions",
        "icon",
        "size",
        -- "mtime",
      },
      view_options = { show_hidden = true },
      keymaps = {
        -- ["w-"] = "actions.select-split",
        -- ["w|"] = "actions.select-vsplit",
        ["C-r"] = "actions.refresh",
        ["<S-h>"] = "actions.toggle_hidden",

        -- ["g?"] = "actions.show_help",
        -- ["<CR>"] = "actions.select",
        ["<C-s>"] = false, -- "actions.select_vsplit"
        ["<C-h>"] = false, -- "actions.select_split"
        -- ["<C-t>"] = "actions.select_tab",
        -- ["<C-p>"] = "actions.preview",
        ["<C-c>"] = false, -- "actions.close",
        ["<C-l>"] = false, -- "actions.refresh",
        -- ["-"] = "actions.parent",
        -- ["_"] = "actions.open_cwd",
        -- ["`"] = "actions.cd",
        -- ["~"] = "actions.tcd",
        -- ["gs"] = "actions.change_sort",
        -- ["gx"] = "actions.open_external",
        -- ["g."] = "actions.toggle_hidden",
        -- ["g\\"] = "actions.toggle_trash",
        ["q"] = { "actions.close", mode = "n" },
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    optional = true,
    cmd = { "Neotree" },
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        },
      },
      follow_current_file = { enabled = true },
      buffers = {
        follow_current_file = { enabled = true },
      },
    },
  },
  {
    "folke/snacks.nvim",
    optional = true,
    keys = { { "<leader>e", false }, { "<leader>E", false } },
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      explorer = { replace_netrw = false },
    },
  },
  {
    "echasnovski/mini.files",
    opts = {
      windows = {
        preview = true,
        width_focus = 50,
      },
      options = { use_as_default_explorer = true },
    },
    keys = {
      {
        "K",
        function()
          local MiniFiles = require("mini.files")
          MiniFiles.config.windows.preview = not MiniFiles.config.windows.preview
          MiniFiles.refresh({ windows = { preview = MiniFiles.config.windows.preview } })
        end,
        ft = { "minifiles" },
        desc = "Toggle preview",
      },
      {
        "<leader>e",
        function()
          local MiniFiles = require("mini.files")
          if not MiniFiles.close() then
            MiniFiles.open(vim.api.nvim_buf_get_name(0), true)
          end
        end,
        desc = "Explorer mini.files (Root Dir)",
        remap = true,
      },
      {
        "<leader>E",
        function()
          if not require("mini.files").close() then
            require("mini.files").open(vim.uv.cwd(), true)
          end
        end,
        desc = "Explorer mini.files (cwd)",
        remap = true,
      },
    },
  },
}

return M
