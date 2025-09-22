---@type LazyPluginSpec[]
return {
  {
    -- will never be loaded, only used for types
    "DrKJeff16/wezterm-types",
    lazy = true,
    specs = {
      {
        "folke/lazydev.nvim",
        optional = true,
        opts = {
          library = {
            { path = "wezterm-types", mods = { "wezterm" } },
          },
        },
      },
    },
  },
  {
    "nvim-mini/mini.pairs",
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
              local paths = vim
                .iter({
                  "package.{json,jsonc}",
                  "snippets/package.{json,jsonc}",
                })
                :map(function(pattern)
                  return vim.api.nvim_get_runtime_file(pattern, true)
                end)
                :flatten()
                :map(function(file)
                  return vim.fn.fnamemodify(file, ":h")
                end)
                :totable()

              require("luasnip.loaders.from_vscode").lazy_load({ paths = paths })
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
  {
    "xzbdmw/colorful-menu.nvim",
    opts = {},
    lazy = true,
    specs = {
      {
        "saghen/blink.cmp",
        optional = true,
        opts = {
          completion = {
            menu = {
              draw = {
                -- We don't need label_description now because label and label_description are already
                -- combined together in label by colorful-menu
                columns = { { "kind_icon" }, { "label", gap = 1 } },
                components = {
                  label = {
                    text = function(ctx)
                      return require("colorful-menu").blink_components_text(ctx)
                    end,
                    highlight = function(ctx)
                      return require("colorful-menu").blink_components_highlight(ctx)
                    end,
                  },
                },
              },
            },
          },
        },
      },
    },
  },
  {
    "catppuccin",
    optional = true,
    opts = {
      integrations = { blink_cmp = true },
    },
  },
}
