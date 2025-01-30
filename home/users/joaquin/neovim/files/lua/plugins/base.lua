local M = {
  {
    "folke/snacks.nvim",
    optional = true,
    init = function()
      vim.g.snacks_animate = false
    end,
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      debug = {},
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
      indent = { animate = { enabled = false }, blank = { char = "·" } },
      bigfile = { enabled = true },
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

      opts.keymap = opts.keymap or {}
      opts.keymap.builtin = { true, ["<C-c>"] = "hide" }
      opts.fzf_opts = vim.tbl_extend("force", opts.fzf_opts, { ["--cycle"] = true })
      return opts
    end,
  },
}

return M
