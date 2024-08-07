-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.completeopt = "menuone,longest"
vim.opt.wrap = true
vim.opt.linebreak = true
-- vim.opt.signcolumn = "auto:2"
vim.opt.smoothscroll = true

vim.g.root_spec = { "cwd", "lsp", { ".git", "lua" } }

-- Hide the '[No Name]' buffer
-- vim.opt.hidden = false

-- LSP Server to use for PHP.
vim.g.lazyvim_php_lsp = "intelephense" -- or "phpactor"
