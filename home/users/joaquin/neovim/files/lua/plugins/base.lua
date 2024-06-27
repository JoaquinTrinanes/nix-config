local M = {
  { "nvim-lua/plenary.nvim" },
  {
    "stevearc/oil.nvim",
    event = "VeryLazy",
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
    dependencies = { "telescope.nvim" },
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
    opts = function(_, opts)
      -- disable clock
      opts.sections.lualine_z = {}
    end,
  },
  {
    "nvimdev/dashboard-nvim",
    opts = function(_, opts)
      local logo = [[
        ⠀⠀⢀⣀⣠⣤⣤⣶⣶⣿⣷⣆⠀⠀⠀⠀
⠀⠀⠀⢀⣤⣤⣶⣶⣾⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⡆⠀⠀⠀
⠀⢀⣴⣿⣿⣿⣿⣿⣿⡿⠛⠉⠉⠀⠀⠀⣿⣿⣿⣿⣷⠀⠀⠀
⣠⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⢤⣶⣾⠿⢿⣿⣿⣿⣿⣇⠀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠈⠉⠀⠀⠀⣿⣿⣿⣿⣿⡆⠀
⢸⣿⣿⣿⣏⣿⣿⣿⣿⣿⣷⠀⠀⢠⣤⣶⣿⣿⣿⣿⣿⣿⣿⡀
⠀⢿⣿⣿⣿⡸⣿⣿⣿⣿⣿⣇⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣧
⠀⠸⣿⣿⣿⣷⢹⣿⣿⣿⣿⣿⣄⣀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⢻⣿⣿⣿⡇⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠘⣿⣿⣿⣿⠘⠻⠿⢛⣛⣭⣽⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⢹⣿⣿⠏⠀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠟⠋
⠀⠀⠀⠈⣿⠏⠀⣰⣿⣿⣿⣿⣿⣿⠿⠟⠛⠋⠉⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⡿⠿⠛⠋⠉⠀⠀⠀⠀        ]]

      opts.config.header = vim.split(logo, "\n")
    end,
  },
  {
    "echasnovski/mini.indentscope",
    opts = function(_, opts)
      opts = opts or {}
      opts.draw = opts.draw or {}
      opts.draw.animation = require("mini.indentscope").gen_animation.none()
      return opts
    end,
  },
  {
    "LunarVim/bigfile.nvim",
    event = { "FileReadPre", "BufReadPre", "User FileOpened" },
    opts = {
      filesize = 10, -- in MB
      features = {
        "indent_blankline",
        "illuminate",
        "lsp",
        "treesitter",
        "syntax",
        "matchparen",
        "vimopts",
        "filetype",
        {
          name = "mini.indentscope",
          opts = { defer = false },
          disable = function()
            vim.b.miniindentscope_disable = true
          end,
        },
      },
    },
  },
}

return M
