local M = {
  {
    "folke/snacks.nvim",
    optional = true,
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      scroll = { enabled = false },
      dashboard = {
        preset = {
          header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
          --  header = [[
          --        ⠀⠀⢀⣀⣠⣤⣤⣶⣶⣿⣷⣆⠀⠀⠀⠀
          -- ⠀⠀⠀⢀⣤⣤⣶⣶⣾⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⡆⠀⠀⠀
          -- ⠀⢀⣴⣿⣿⣿⣿⣿⣿⡿⠛⠉⠉⠀⠀⠀⣿⣿⣿⣿⣷⠀⠀⠀
          -- ⣠⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⢤⣶⣾⠿⢿⣿⣿⣿⣿⣇⠀⠀
          -- ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠈⠉⠀⠀⠀⣿⣿⣿⣿⣿⡆⠀
          -- ⢸⣿⣿⣿⣏⣿⣿⣿⣿⣿⣷⠀⠀⢠⣤⣶⣿⣿⣿⣿⣿⣿⣿⡀
          -- ⠀⢿⣿⣿⣿⡸⣿⣿⣿⣿⣿⣇⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣧
          -- ⠀⠸⣿⣿⣿⣷⢹⣿⣿⣿⣿⣿⣄⣀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿
          -- ⠀⠀⢻⣿⣿⣿⡇⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
          -- ⠀⠀⠘⣿⣿⣿⣿⠘⠻⠿⢛⣛⣭⣽⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿
          -- ⠀⠀⠀⢹⣿⣿⠏⠀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠟⠋
          -- ⠀⠀⠀⠈⣿⠏⠀⣰⣿⣿⣿⣿⣿⣿⠿⠟⠛⠋⠉⠀⠀⠀⠀⠀
          -- ⠀⠀⠀⠀⠀⠀⢠⡿⠿⠛⠋⠉⠀⠀⠀⠀        ]],
        },
      },
      image = { enabled = false },
      picker = {
        sources = { grep = { jump = { match = true } } },
        layouts = {
          select = {
            layout = {
              relative = "cursor",
              -- width = 70,
              -- min_width = 0,
              row = 1,
            },
          },
        },
        win = {
          list = {
            keys = {
              ["<C-y>"] = { "confirm", mode = { "n", "i" } },
            },
          },
          input = {
            keys = {
              ["<C-y>"] = { "confirm", mode = { "n", "i" } },

              -- ["<a-p>"] = { "" },
              ["<A-f>"] = false,
              ["<A-h>"] = false,
              ["<A-i>"] = false,
              ["<A-m>"] = false,

              ["<C-f>"] = { "toggle_follow", mode = { "i", "n" } },
              ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
              ["<C-i>"] = { "toggle_ignored", mode = { "i", "n" } },
              ["<C-m>"] = { "toggle_maximize", mode = { "i", "n" } },
              -- ["<C-c>"] = { "", mode = { "i", "n" } },
            },
          },
        },
      },
      indent = { enabled = false, animate = { enabled = false }, blank = { char = "·" } },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
    },
  },
  {
    "akinsho/bufferline.nvim",
    optional = true,
    keys = {
      -- disable default key
      { "<leader>br", false },
      { "<leader>bh", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<leader>bl", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bb", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      -- disable clock
      opts.sections.lualine_z = {}
    end,
  },
  {
    "echasnovski/mini.indentscope",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.draw = opts.draw or {}
      opts.draw.animation = require("mini.indentscope").gen_animation.none()
      return opts
    end,
  },
  {
    "julienvincent/hunk.nvim",
    cmd = { "DiffEditor" },
    opts = {
      hooks = {
        ---@class HunkTree
        ---@class HunkChangeset
        ---@field filepath string
        ---@field hunks { left: [number, number]; right: [number, number] }[]
        ---@field left_filepath string
        ---@field right_filepath string
        ---@field selected boolean
        ---@field selected_lines { left: integer[]; right: integer[]; }
        ---@field type "added" | "modified" | "deleted"
        ---@class HunkTreeMountOpts
        ---@field changeset table<string, HunkChangeset>
        ---@field on_open fun(change: HunkChangeset, opts: {tree: HunkTree?; })
        ---@class HunkContext
        ---@field buf integer
        ---@field opts HunkTreeMountOpts
        ---@field tree table
        ---@param context HunkContext
        on_tree_mount = function(context)
          vim.keymap.set("n", "<space>ff", function()
            Snacks.picker.pick({
              items = vim
                .iter(context.opts.changeset)
                ---@param v HunkChangeset
                :map(function(k, v)
                  ---@type snacks.picker.Item
                  return { file = v.filepath, text = k, change = v }
                end)
                :totable(),
              confirm = function(picker, item)
                context.opts.on_open(item.change, { tree = context.tree })
              end,
            })
          end, { desc = "Find files in diff" })
        end,
      },
      ui = {
        tree = {
          mode = "flat",
          -- width = 100,
        },
      },
    },
  },
  {
    "echasnovski/mini.splitjoin",
    opts = { mappings = { toggle = "gS", split = "", join = "" } },
  },
  {
    "mrjones2014/smart-splits.nvim",
    keys = {
      -- stylua: ignore start
      -- Resizing splits
      { "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize left", },
      { "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize down", },
      { "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize up", },
      { "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize right", },

      -- Moving between splits
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to split below" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to split above" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },

      -- Swapping buffers between windows
      { "<leader><leader>h>", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer with left split" },
      { "<leader><leader>j>", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer with split below" },
      { "<leader><leader>k>", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer with split above" },
      { "<leader><leader>l>", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer with right split" },
      -- stylua: ignore end
    },
    enabled = false,
    version = "*",
    priority = 1000,
    lazy = false,
  },
}

return M
