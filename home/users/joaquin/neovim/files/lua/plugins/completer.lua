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
        { path = "wezterm-types/types", mods = { "wezterm" } },
      },
    },
  },
  {
    "echasnovski/mini.pairs",
    enabled = false,
  },
  {
    "saghen/blink.cmp",
    optional = true,
    lazy = false,
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },

      -- trigger = { completion = { show_in_snippet = false } },
      -- prebuilt_binaries = { download = false },
      windows = { autocomplete = { selection = "manual" } },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    --- @param opts cmp.ConfigSchema
    opts = function(_, opts)
      -- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      -- local cmp = require("cmp")
      -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      local prev_format = opts.formatting.format
      local max_menu_length = 15

      opts.formatting.format = function(entry, vim_item)
        local item = prev_format(entry, vim_item)
        if entry.completion_item.detail ~= nil and entry.completion_item.detail ~= "" then
          item.menu = entry.completion_item.detail
          item.menu_hl_group = "Comment"

          local truncated = string.sub(item.menu, 1, max_menu_length)
          if #truncated < #item.menu then
            item.menu = string.sub(truncated, 1, max_menu_length - 1) .. "…"
          end
          -- else
          --   vim_item.menu = ({
          --     nvim_lsp = "[LSP]",
          --     luasnip = "[Snippet]",
          --     buffer = "[Buffer]",
          --     path = "[Path]",
          --   })[entry.source.name]
        end
        return item
      end
    end,
  },
}

return M
