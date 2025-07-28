---@type snacks.image.Config
local image_config = {}

if not vim.o.termguicolors then
  -- The picker image previewer doesn't check if the terminal is supported,
  -- just if the image is of a supported format. Set to empty table to prevent
  -- the preview from being triggered in that case
  image_config.formats = {}
  image_config.enabled = false
end

return {
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { { "folke/persistence.nvim" } },
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      image = image_config,
      picker = {
        layouts = {
          select = {
            layout = {
              relative = "cursor",
              row = 1,
            },
          },
        },
        win = {
          input = {
            keys = {
              ["<C-y>"] = { "confirm", mode = { "n", "i" } },

              ["<A-f>"] = false,
              ["<A-h>"] = false,
              ["<A-i>"] = false,
              ["<A-m>"] = false,

              -- ["<C-f>"] = { "toggle_follow", mode = { "i", "n" } },
              ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
              ["<C-i>"] = { "toggle_ignored", mode = { "i", "n" } },
              ["<C-m>"] = { "toggle_maximize", mode = { "i", "n" } },
            },
          },
        },
      },
      indent = { animate = { enabled = false } },
      bigfile = {},
      quickfile = {},
      notifier = {},
      scope = {},
      statuscolumn = {},
      words = {},
      dashboard = {
        preset = {
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session", action = ":lua require('persistence').load()" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
    keys = {
      -- {
      --   "<leader>n",
      --   function()
      --     ---@diagnostic disable-next-line: undefined-field
      --     if Snacks.config.picker and Snacks.config.picker.enabled then
      --       Snacks.picker.notifications({ confirm = { "copy", "close" } })
      --     else
      --       Snacks.notifier.show_history()
      --     end
      --   end,
      --   desc = "Notification History",
      -- },
      {
        "<leader>n",
        function()
          require("snacks").notifier.show_history()
        end,
        desc = "Notification History",
      },
      {
        "<leader>un",
        function()
          require("snacks").notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "<leader>,",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>/",
        function()
          Snacks.picker.pick("grep")
        end,
        desc = "Grep (Root Dir)",
      },
      {
        "<leader>:",
        function()
          Snacks.picker.command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader><space>",
        function()
          Snacks.picker.pick("files")
        end,
        desc = "Find Files (Root Dir)",
      },
      -- find
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fB",
        function()
          Snacks.picker.buffers({ hidden = true, nofile = true })
        end,
        desc = "Buffers (all)",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.pick("files")
        end,
        desc = "Find Files (Root Dir)",
      },
      {
        "<leader>fF",
        function()
          Snacks.picker.pick("files", { root = false })
        end,
        desc = "Find Files (cwd)",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.git_files()
        end,
        desc = "Find Files (git-files)",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.pick("oldfiles")
        end,
        desc = "Recent",
      },
      {
        "<leader>fR",
        function()
          Snacks.picker.recent({ filter = { cwd = true } })
        end,
        desc = "Recent (cwd)",
      },
      {
        "<leader>fp",
        function()
          Snacks.picker.projects()
        end,
        desc = "Projects",
      },
      -- git
      {
        "<leader>gd",
        function()
          Snacks.picker.git_diff()
        end,
        desc = "Git Diff (hunks)",
      },
      {
        "<leader>gs",
        function()
          Snacks.picker.git_status()
        end,
        desc = "Git Status",
      },
      {
        "<leader>gS",
        function()
          Snacks.picker.git_stash()
        end,
        desc = "Git Stash",
      },
      -- Grep
      {
        "<leader>sb",
        function()
          Snacks.picker.lines()
        end,
        desc = "Buffer Lines",
      },
      {
        "<leader>sB",
        function()
          Snacks.picker.grep_buffers()
        end,
        desc = "Grep Open Buffers",
      },
      {
        "<leader>sg",
        function()
          Snacks.picker.pick("live_grep")
        end,
        desc = "Grep (Root Dir)",
      },
      {
        "<leader>sG",
        function()
          Snacks.picker.pick("live_grep", { root = false })
        end,
        desc = "Grep (cwd)",
      },
      {
        "<leader>sp",
        function()
          Snacks.picker.lazy()
        end,
        desc = "Search for Plugin Spec",
      },
      {
        "<leader>sw",
        function()
          Snacks.picker.pick("grep_word")
        end,
        desc = "Visual selection or word (Root Dir)",
        mode = { "n", "x" },
      },
      {
        "<leader>sW",
        function()
          Snacks.picker.pick("grep_word", { root = false })
        end,
        desc = "Visual selection or word (cwd)",
        mode = { "n", "x" },
      },
      -- search
      {
        '<leader>s"',
        function()
          Snacks.picker.registers()
        end,
        desc = "Registers",
      },
      {
        "<leader>s/",
        function()
          Snacks.picker.search_history()
        end,
        desc = "Search History",
      },
      {
        "<leader>sa",
        function()
          Snacks.picker.autocmds()
        end,
        desc = "Autocmds",
      },
      {
        "<leader>sc",
        function()
          Snacks.picker.command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader>sC",
        function()
          Snacks.picker.commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>sd",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "Diagnostics",
      },
      {
        "<leader>sD",
        function()
          Snacks.picker.diagnostics_buffer()
        end,
        desc = "Buffer Diagnostics",
      },
      {
        "<leader>sh",
        function()
          Snacks.picker.help()
        end,
        desc = "Help Pages",
      },
      {
        "<leader>sH",
        function()
          Snacks.picker.highlights()
        end,
        desc = "Highlights",
      },
      {
        "<leader>si",
        function()
          Snacks.picker.icons()
        end,
        desc = "Icons",
      },
      {
        "<leader>sj",
        function()
          Snacks.picker.jumps()
        end,
        desc = "Jumps",
      },
      {
        "<leader>sk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>sl",
        function()
          Snacks.picker.loclist()
        end,
        desc = "Location List",
      },
      {
        "<leader>sM",
        function()
          Snacks.picker.man()
        end,
        desc = "Man Pages",
      },
      {
        "<leader>sm",
        function()
          Snacks.picker.marks()
        end,
        desc = "Marks",
      },
      {
        "<leader>sR",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume",
      },
      {
        "<leader>sq",
        function()
          Snacks.picker.qflist()
        end,
        desc = "Quickfix List",
      },
      {
        "<leader>su",
        function()
          Snacks.picker.undo()
        end,
        desc = "Undotree",
      },
      -- ui
      {
        "<leader>uC",
        function()
          Snacks.picker.colorschemes()
        end,
        desc = "Colorschemes",
      },
    },
    config = function(_, opts)
      local Snacks = require("snacks")
      Snacks.setup(opts)

      Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
      Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
      Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
      Snacks.toggle.diagnostics():map("<leader>ud")
      Snacks.toggle.line_number():map("<leader>ul")
      Snacks.toggle
        .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" })
        :map("<leader>uc")
      Snacks.toggle
        .option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
        :map("<leader>uA")
      Snacks.toggle.treesitter():map("<leader>uT")
      Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
      Snacks.toggle.dim():map("<leader>uD")
      Snacks.toggle.indent():map("<leader>ug")
      Snacks.toggle.profiler():map("<leader>dpp")
      Snacks.toggle.profiler_highlights():map("<leader>dph")
    end,
  },
}
