local M = {
  {
    "stevearc/oil.nvim",
    event = "VeryLazy",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      columns = {
        -- "permissions",
        "icon",
        "size",
        -- "mtime",
      },
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
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      -- show columnsign at the left
      -- sign_priority = 0,
      current_line_blame = true,
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    enabled = true,
  },
  {
    "stevearc/dressing.nvim",
    optional = true,
    opts = {
      input = {
        get_config = function()
          if vim.api.nvim_win_get_width(0) < 50 then
            return {
              relative = "editor",
            }
          end
        end,
        relative = "cursor",
      },
      select = {
        get_config = function(inner_opts)
          if inner_opts.kind == "codeaction" or inner_opts.kind == "hover" then
            return { telescope = require("telescope.themes").get_cursor() }
          end
          return { telescope = require("telescope.themes").get_dropdown() }
        end,
      },
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
    "folke/snacks.nvim",
    optional = true,
    ---@module "snacks"
    ---@class snacks.Config
    opts = {
      dashboard = {
        sections = {
          { section = "header" },
          {
            section = "keys",
            gap = 1,
            -- indent=2,
            padding = 1,
          },
          {
            -- icon = " ",
            -- pane = 2,
            title = "Recent Files",
            section = "recent_files",
            indent = 2,
            padding = 1,
          },
          {
            -- icon = " ",
            -- pane = 2,
            title = "Projects",
            section = "projects",
            indent = 2,
            padding = 1,
          },
          { section = "startup" },
        },
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
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    optional = true,
    opts = {
      filesystem = { hijack_netrw_behavior = "disabled" },
    },
  },
  {
    "which-key.nvim",
    optional = true,
    opts = {
      preset = "helix",
    },
  },
  { "julienvincent/hunk.nvim", cmd = { "DiffEditor" }, opts = {} },
  { "avm99963/vim-jjdescription", lazy = false },
  {
    "akinsho/bufferline.nvim",
    optional = true,
    keys = {
      -- { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>br", false },
      { "<leader>bh", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<leader>bl", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
    },
  },
  {
    "ibhagwan/fzf-lua",
    optional = true,
    opts = function(_, opts)
      local config = require("fzf-lua.config")

      local prev_ui_select = opts.ui_select

      opts.ui_select = function(fzf_opts, items)
        local result = prev_ui_select(fzf_opts, items)

        if fzf_opts.kind == "codeaction" then
          result.winopts.relative = "cursor"
          result.winopts.backdrop = 100
          result.winopts.height = math.floor(math.min(vim.o.lines * 0.3 - 16, #items + 2) + 0.5) + 16
        end
        return result
      end

      config.defaults.keymap.fzf["tab"] = "down"
      config.defaults.keymap.fzf["shift-tab"] = "up"

      opts.fzf_opts = vim.tbl_extend("force", opts.fzf_opts, { ["--cycle"] = true })
      return opts
    end,
  },
}

return M
