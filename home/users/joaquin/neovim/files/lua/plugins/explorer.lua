local M = {
  {
    "stevearc/oil.nvim",
    event = "VeryLazy",
    keys = {
      -- { "-", "<cmd>Oil<cr>", desc = "Open Oil" },
    },
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
    cmd = "Neotree",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        -- follow_current_file = { enabled = true },
        -- bind_to_cwd = false,
      },
      follow_current_file = { enabled = true },
      buffers = {
        follow_current_file = { enabled = true },
      },
    },
  },
}

return M
