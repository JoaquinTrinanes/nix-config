local M = {
  {
    "folke/snacks.nvim",
    init = function()
      vim.g.snacks_animate = false
    end,
    keys = {
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
    },
    opts = {
      notifier = { enabled = true },
      indent = { animate = { enabled = false }, blank = { char = "·" } },
      bigfile = { enabled = true },
      input = { enabled = true },
      quickfile = { enabled = true },
    },
  },
  {
    "tpope/vim-sleuth",
  },
  {
    "akinsho/bufferline.nvim",
    keys = {
      -- disable default key
      { "<leader>br", false },
      { "<leader>bh", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<leader>bl", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
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
  { "julienvincent/hunk.nvim", cmd = { "DiffEditor" }, opts = {} },
  { "avm99963/vim-jjdescription", lazy = false },
  {
    "ibhagwan/fzf-lua",
    optional = true,
    opts = function(_, opts)
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

      opts.fzf_opts = vim.tbl_extend("force", opts.fzf_opts, { ["--cycle"] = true })
      return opts
    end,
  },
}

return M
