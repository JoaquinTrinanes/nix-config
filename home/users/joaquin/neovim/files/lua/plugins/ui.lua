local U = require("config.util")

local diagnostics_signs = vim.diagnostic.config().signs.text or {}

return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>bh", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<leader>bl", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bb", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
      { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diagnostics_dict)
          local errors = diagnostics_dict.error
              and diagnostics_signs[vim.diagnostic.severity.ERROR] .. diagnostics_dict.error
            or ""
          local warnings = diagnostics_dict.warning
              and diagnostics_signs[vim.diagnostic.severity.WARN] .. diagnostics_dict.warning
            or ""

          return vim.trim(errors .. " " .. warnings)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
          {
            filetype = "snacks_layout_box",
          },
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      local icons = {
        diagnostics = {
          error = diagnostics_signs[vim.diagnostic.severity.ERROR],
          warn = diagnostics_signs[vim.diagnostic.severity.WARN],
          hint = diagnostics_signs[vim.diagnostic.severity.HINT],
          info = diagnostics_signs[vim.diagnostic.severity.INFO],
        },
        git = {
          added = " ",
          modified = " ",
          removed = " ",
        },
      }

      local new_opts = {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.error,
                warn = icons.diagnostics.warn,
                info = icons.diagnostics.info,
                hint = icons.diagnostics.hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1 },
          },
          lualine_x = {
            {
              "diff",
              symbols = vim.o.termguicolors and {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              } or nil,
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {},
        },
        extensions = { "neo-tree", "lazy" },
      }

      return vim.tbl_deep_extend("force", opts, new_opts)
    end,
  },
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    init = function()
      U.lsp.on_attach(function(client, buffer)
        local navic = require("nvim-navic")
        local prev_client_id = vim.b[buffer].navic_client_id

        if prev_client_id and client.id ~= prev_client_id then
          return
        end

        if client:supports_method("textDocument/documentSymbol") then
          navic.attach(client, buffer)
        end
      end)
    end,
    opts = {
      separator = " ",
      highlight = true,
      depth_limit = 5,
      -- icons = LazyVim.config.icons.kinds,
      lazy_update_context = true,
    },
    specs = {
      {
        "nvim-lualine/lualine.nvim",
        optional = true,
        opts = function(_, opts)
          table.insert(opts.sections.lualine_c, { "navic", color_correction = "dynamic" })
        end,
      },
    },
  },

  -- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    ---@module 'noice'
    ---@type NoiceConfig
    opts = {
      lsp = { hover = { silent = true } },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    -- stylua: ignore
    keys = {
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
      { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
      { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
    },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup(opts)
    end,
  },

  -- ui components
  { "MunifTanjim/nui.nvim", lazy = true },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
  },
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { { "folke/persistence.nvim" } },
    ---@type snacks.Config
    opts = {
      indent = { enabled = true },
      toggle = {},
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      dashboard = {
        preset = {
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            -- { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session", action = ":lua require('persistence').load()" },
            -- { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
    keys = {
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
      vim.g.snacks_animate = false
      require("snacks").setup(opts)
    end,
    -- config = function(_, opts)
    --   require("snacks").setup(opts)
    --   -- HACK: hide statusline on dashboard
    --   -- remove this if you want to see the statusline on the dashboard
    --   -- local group = vim.api.nvim_create_augroup("SnacksDashboard", { clear = true })
    --   -- vim.api.nvim_create_autocmd("User", {
    --   --   pattern = "SnacksDashboardOpened",
    --   --   group = group,
    --   --   callback = function()
    --   --     vim.o.laststatus = 0
    --   --   end,
    --   -- })
    --   -- vim.api.nvim_create_autocmd("User", {
    --   --   pattern = "SnacksDashboardClosed",
    --   --   group = group,
    --   --   callback = function()
    --   --     vim.o.laststatus = 3
    --   --   end,
    --   -- })
    -- end,
  },
}
