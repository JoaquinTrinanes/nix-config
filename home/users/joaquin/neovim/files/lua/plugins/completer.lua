local M = {
  {
    -- will never be loaded, only used for types
    "justinsgithub/wezterm-types",
    lazy = true,
  },
  {
    "folke/lazydev.nvim",
    opts = {
      library = {
        { path = "wezterm-types", mods = { "wezterm" } },
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
    event = "InsertEnter",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
              require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
            end,
          },
        },
        version = "v2.*",
      },
      {
        "saghen/blink.compat",
        optional = true, -- make optional so it's only enabled if actually used
        opts = {},
      },
    },
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.compat",
      "sources.default",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 50,
          update_delay_ms = 50,
        },
        ghost_text = {
          enabled = false,
        },
        list = {
          selection = { preselect = false, auto_insert = true },
          cycle = {
            from_bottom = true,
            from_top = true,
          },
        },
        menu = {
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  if vim.o.termguicolors and ctx.kind_icon then
                    return ctx.kind_icon
                  end
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                highlight = function(ctx)
                  if vim.o.termguicolors and ctx.kind_hl then
                    return ctx.kind_hl
                  end
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
              kind = {
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
            treesitter = { "lsp" },
          },
        },
      },
      signature = { enabled = true },
      keymap = {
        preset = "default",
        ["<C-n>"] = { "select_next", "show", "fallback_to_mappings" },
      },
      fuzzy = { prebuilt_binaries = { download = false } },
    },
  },
  -- lazydev
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
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
  -- catppuccin support
  {
    "catppuccin",
    optional = true,
    opts = {
      integrations = { blink_cmp = true },
    },
  },
}

return M
