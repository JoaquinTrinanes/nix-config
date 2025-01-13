local M = {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    opts = {
      sources = {
        -- add lazydev to your completion providers
        default = { "lazydev" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- show at a higher priority than lsp
          },
        },
      },
    },
  },
  {
    -- will never be loaded, only used for types
    "justinsgithub/wezterm-types",
    lazy = true,
  },
  {
    "folke/lazydev.nvim",
    opts = {
      library = {
        { path = "wezterm-types/types", mods = { "wezterm" } },
      },
    },
  },
  {
    "echasnovski/mini.pairs",
    optional = true,
    enabled = false,
  },
  {
    "saghen/blink.cmp",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      completion = {
        ghost_text = {
          enabled = false,
        },
        accept = { auto_brackets = { kind_resolution = { blocked_filetypes = { "nu" } } } },
        list = {
          selection = { preselect = false, auto_insert = true },
          cycle = {
            from_bottom = true,
            from_top = true,
          },
        },
        menu = {
          draw = { treesitter = { "lsp" } },
        },
      },
      signature = { enabled = true },
      keymap = {
        preset = "default",
        ["<C-n>"] = { "select_next", "show", "show_documentation", "hide_documentation", "fallback" },
      },
      fuzzy = { prebuilt_binaries = { download = false } },
    },
  },
  -- {
  --   "hrsh7th/nvim-cmp",
  --   optional = true,
  --   --- @module "cmp"
  --   --- @param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     -- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  --     -- local cmp = require("cmp")
  --     -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  --
  --     local prev_format = opts.formatting.format
  --     local max_menu_length = 15
  --
  --     opts.formatting.format = function(entry, vim_item)
  --       local item = prev_format(entry, vim_item)
  --       if entry.completion_item.detail ~= nil and entry.completion_item.detail ~= "" then
  --         item.menu = entry.completion_item.detail
  --         item.menu_hl_group = "Comment"
  --
  --         local truncated = string.sub(item.menu, 1, max_menu_length)
  --         if #truncated < #item.menu then
  --           item.menu = string.sub(truncated, 1, max_menu_length - 1) .. "…"
  --         end
  --         -- else
  --         --   vim_item.menu = ({
  --         --     nvim_lsp = "[LSP]",
  --         --     luasnip = "[Snippet]",
  --         --     buffer = "[Buffer]",
  --         --     path = "[Path]",
  --         --   })[entry.source.name]
  --       end
  --       return item
  --     end
  --   end,
  -- },

  -- supertab
  -- {
  --   "hrsh7th/nvim-cmp",
  --   optional = true,
  --   ---@module "cmp"
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     local has_words_before = function()
  --       unpack = unpack or table.unpack
  --       local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  --       return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  --     end
  --
  --     local cmp = require("cmp")
  --
  --     opts.completion.completeopt = "menuone,noinsert,noselect"
  --
  --     local select_opts = { behaviour = cmp.SelectBehavior.Select }
  --
  --     opts.mapping = vim.tbl_extend("force", opts.mapping, {
  --       ["<Tab>"] = cmp.mapping(function(fallback)
  --         if cmp.visible() then
  --           cmp.select_next_item(select_opts)
  --         elseif vim.snippet.active({ direction = 1 }) then
  --           vim.schedule(function()
  --             vim.snippet.jump(1)
  --           end)
  --         elseif has_words_before() then
  --           cmp.complete()
  --         else
  --           fallback()
  --         end
  --       end, { "i", "s" }),
  --       ["<S-Tab>"] = cmp.mapping(function(fallback)
  --         if cmp.visible() then
  --           cmp.select_prev_item(select_opts)
  --         elseif vim.snippet.active({ direction = -1 }) then
  --           vim.schedule(function()
  --             vim.snippet.jump(-1)
  --           end)
  --         else
  --           fallback()
  --         end
  --       end, { "i", "s" }),
  --       ["<CR>"] = cmp.mapping.confirm({
  --         behavior = cmp.ConfirmBehavior.Replace,
  --         select = false,
  --       }),
  --     })
  --   end,
  -- },
}

return M
