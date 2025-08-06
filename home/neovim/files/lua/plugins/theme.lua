---@type LazyPluginSpec[]
local M = {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    cond = function()
      return vim.o.termguicolors
    end,
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
    ---@module "catppuccin"
    ---@type CatppuccinOptions
    opts = {
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        fzf = true,
        grug_far = true,
        gitsigns = false,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        snacks = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
      flavour = "auto", -- latte, frappe, macchiato, mocha
      background = {
        light = "latte",
        dark = "frappe",
      },
      term_colors = true,
      custom_highlights = function(colors)
        local U = require("catppuccin.utils.colors")

        return {
          LspSignatureActiveParameter = { style = { "bold" } },
          SpellBad = {
            sp = colors.subtext0,
          },
          Added = { fg = colors.blue },
          diffAdded = { link = "Added" },
          DiffAdd = { bg = U.darken(colors.blue, 0.18, colors.base) },

          Removed = { fg = colors.red },
          diffRemoved = { link = "Removed" },
          DiffDelete = { bg = U.darken(colors.red, 0.18, colors.base) },

          Changed = { fg = colors.yellow },
          diffChanged = { link = "Changed" },
          DiffChange = { bg = U.darken(colors.yellow, 0.07, colors.base) },
        }
      end,
    },
    specs = {
      {
        "akinsho/bufferline.nvim",
        optional = true,
        opts = function(_, opts)
          if (vim.g.colors_name or ""):find("catppuccin") then
            opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
          end
        end,
      },
    },
  },
}

return M
