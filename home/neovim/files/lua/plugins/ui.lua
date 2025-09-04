local U = require("config.util")

local diagnostics_signs = vim.diagnostic.config().signs.text or {}

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

---@type LazyPluginSpec[]
return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>bh", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<leader>bl", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bb", "<cmd>BufferLinePick<CR>", desc = "Pick buffer" },
      { "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
      { "<S-l>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
      { "[b", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
      { "]b", "<Cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
      { "[B", "<Cmd>BufferLineMovePrev<CR>", desc = "Move buffer prev" },
      { "]B", "<Cmd>BufferLineMoveNext<CR>", desc = "Move buffer next" },
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
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts_extend = {
      "sections.lualine_a",
      "sections.lualine_b",
      "sections.lualine_c",
      "sections.lualine_x",
      "sections.lualine_y",
      "sections.lualine_z",
    },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        icons_enabled = vim.o.termguicolors,
      },
      ---@class LualineSectionItem
      ---@field [1] string|fun():string
      ---@field icons_enabled? boolean
      ---@field icon? string | {[1]:string, color:table}
      ---@field separator? string | {left:string, right:string}
      ---@field cond? fun():boolean
      ---@field draw_empty? boolean
      ---@field color? string|fun(section:LualineSectionItem[])|table
      ---@field type? string
      ---@field padding? number|{left?:number, right?: number}
      ---@field fmt? fun(content:string, ctx: table):string
      ---@field on_click? fun(n_clicks:integer, mouse_button:string, modifiers:string)
      ---@type table<string, (string|(fun():string)|LualineSectionItem)[]>
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
          {
            "filename",
            path = 1,
            padding = { left = 0, right = 1 },
          },
        },
        lualine_x = {
          {
            -- show size of visual selection
            function()
              local mode = vim.fn.mode(true)
              local line_start, col_start = tonumber(vim.fn.line("v")) or 0, tonumber(vim.fn.col("v")) or 0
              local line_end, col_end = tonumber(vim.fn.line(".")) or 0, tonumber(vim.fn.col(".")) or 0
              if mode:match("\22") then
                return string.format("%dL %dC", math.abs(line_start - line_end) + 1, math.abs(col_start - col_end) + 1)
              elseif mode:match("V") or line_start ~= line_end then
                return tostring(math.abs(line_start - line_end) + 1) .. "L"
              else
                return ""
              end
            end,
            cond = function()
              local mode = vim.fn.mode(true)
              return mode == "v" or mode == "V" or mode == "\22"
            end,
          },
          {
            -- show number of selected characters and words
            function()
              local wordcount = vim.fn.wordcount()
              return ("%d words %d chars"):format(wordcount.visual_words, wordcount.visual_chars)
            end,
            cond = function()
              local mode = vim.fn.mode(true)
              return mode == "v" or mode == "V" or mode == "\22"
            end,
          },
          {
            function()
              return "recording @" .. vim.fn.reg_recording()
            end,
            cond = function()
              return vim.fn.reg_recording() ~= ""
            end,
          },
          {
            "encoding",
            cond = function()
              return vim.bo.fileencoding ~= "utf-8"
            end,
          },
          {
            "fileformat",
            icons_enabled = false,
            cond = function()
              return vim.bo.fileformat ~= "unix"
            end,
          },
          {
            "diff",
            colored = vim.o.termguicolors,
            symbols = vim.o.termguicolors and {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            } or nil,
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if not gitsigns then
                return
              end
              return {
                added = gitsigns.added,
                modified = gitsigns.changed,
                removed = gitsigns.removed,
              }
            end,
          },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {},
      },
      extensions = { "lazy" },
    },
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
      lazy_update_context = true,
    },
    specs = {
      {
        "nvim-lualine/lualine.nvim",
        optional = true,
        opts = { sections = { lualine_c = { { "navic", color_correction = "dynamic" } } } },
      },
    },
  },
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
}
