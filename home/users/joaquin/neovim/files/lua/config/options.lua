-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.completeopt = "menuone,longest"

opt.wrap = true
opt.linebreak = true
opt.smoothscroll = true

vim.g.root_spec = { "cwd", "lsp", { ".git", "lua" } }

-- Hide the '[No Name]' buffer
-- vim.opt.hidden = false

-- LSP Server to use for PHP.
vim.g.lazyvim_php_lsp = "intelephense" -- or "phpactor"

if vim.env.COLORTERM == nil then
  opt.pumblend = 0 -- Popup blend
  opt.termguicolors = false
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.snacks_animate = false

-- Highlight one character after textwidth
vim.opt.colorcolumn = "+1"
