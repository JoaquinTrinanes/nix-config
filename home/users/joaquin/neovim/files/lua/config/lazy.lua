-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) and not vim.env.LAZY then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

opt.confirm = true

opt.number = true
opt.relativenumber = true

opt.smarttab = true
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.tabstop = 2 -- Number of spaces tabs count for

opt.smartindent = true -- Insert indents automatically

opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode

opt.smoothscroll = true
-- opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
-- opt.foldmethod = "expr"
opt.foldtext = ""

opt.shortmess:append({ W = true, I = true, c = true, C = true })

opt.completeopt = "menuone,longest"

opt.wrap = true
opt.linebreak = true
opt.smoothscroll = true

-- Hide the '[No Name]' buffer
-- vim.opt.hidden = false

if vim.env.COLORTERM == nil then
  opt.pumblend = 0 -- Popup blend
  opt.termguicolors = false
end

-- Highlight one character after textwidth
opt.colorcolumn = "+1"

opt.ignorecase = true
opt.smartcase = true

opt.signcolumn = "yes"

opt.splitright = true
opt.splitbelow = true

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- Show which line your cursor is on
opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

vim.api.nvim_create_user_command("Opts", function(args)
  local get_plugin_opts = function(name)
    local plugin = require("lazy.core.config").spec.plugins[name]
    if not plugin then
      return {}
    end
    local Plugin = require("lazy.core.plugin")
    return Plugin.values(plugin, "opts", false)
  end

  local result = {}
  if #args.fargs == 1 then
    result = get_plugin_opts(args.fargs[1])
  else
    for _, name in ipairs(args.fargs) do
      local opts = get_plugin_opts(name)
      result[name] = opts
    end
  end
  vim.print(result)
end, {
  nargs = "+",
  complete = function()
    return vim.tbl_keys(require("lazy.core.config").spec.plugins)
  end,
})

if vim.g.usePluginsFromStore == nil then
  vim.g.usePluginsFromStore = false
end

local dev = {}

--- @type LazyConfig
local lazyoptions = {
  spec = {
    { import = "plugins" },
  },
  dev = dev,
  defaults = {
    lazy = false,
    version = false, -- always use the latest git commit
  },
  local_spec = true,
  checker = { enabled = false }, -- automatically check for plugin updates
  change_detection = { notify = false },
  performance = {
    rtp = {
      reset = false,
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}

for name, path in pairs(vim.g.pluginPathMap) do
  table.insert(lazyoptions.spec, 1, { name, dir = path })
end

vim.g.lazyOptions = vim.g.lazyOptions or {}

require("config.keymaps")
require("config.autocmds")

require("lazy").setup(vim.tbl_deep_extend("force", lazyoptions, vim.g.lazyOptions))

vim.g.lazyOptions = nil
vim.g.pluginPathMap = nil
