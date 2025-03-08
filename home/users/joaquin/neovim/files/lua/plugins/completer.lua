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
}

return M
