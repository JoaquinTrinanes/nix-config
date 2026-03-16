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
      vim.cmd.colorscheme("catppuccin-nvim")
    end,
    ---@module "catppuccin"
    ---@type CatppuccinOptions
    opts = {
      flavour = "auto", -- latte, frappe, macchiato, mocha
      background = {
        light = "latte",
        dark = "frappe",
      },
      lsp_styles = {
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      auto_integrations = true,
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
            opts.highlights = function()
              local highlights = require("catppuccin.special.bufferline").get_theme({ styles = { "bold" } })()
              ---@diagnostic disable-next-line: undefined-field
              highlights.duplicate_selected.italic = true
              ---@diagnostic disable-next-line: undefined-field
              highlights.duplicate_visible.italic = true
              ---@diagnostic disable-next-line: undefined-field
              highlights.duplicate.italic = true
              return highlights
            end
          end
        end,
      },
    },
  },
}

return M
