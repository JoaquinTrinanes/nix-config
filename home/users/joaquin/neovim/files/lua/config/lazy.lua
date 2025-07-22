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

vim.g.nixPureMode = vim.g.nixPureMode == true or false

---@type LazyConfig
local lazyoptions = {
  spec = {
    { import = "plugins" },
    { import = "plugins.languages" },
  },
  defaults = {
    lazy = false,
    version = false,
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

for name, path in pairs(vim.g.pluginPathMap or {}) do
  lazyoptions.spec[#lazyoptions.spec + 1] = { name, dir = path, pin = true }
end

-- Disable some deprecation warnings while snacks.nvim is not updated
if vim.fn.has("nvim-0.12") == 1 then
  local original_vim_deprecate = vim.deprecate
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.deprecate = function(name, ...)
    if vim.list_contains({ "client.notify", "client.supports_method" }, name) then
      return
    end
    original_vim_deprecate(name, ...)
  end
end

-- force-load lspconfig, allowing access to default values when configuring it
local lspconfig_path = vim.g.pluginPathMap["nvim-lspconfig"] or vim.fn.stdpath("data") .. "/lazy/nvim-lspconfig"
vim.opt.rtp:prepend(lspconfig_path)

require("config.options")
require("config.autocmds")
require("lazy").setup(vim.tbl_deep_extend("force", lazyoptions, vim.g.lazyOptions or {}))
require("config.keymaps")

vim.g.lazyOptions = nil
vim.g.pluginPathMap = nil
