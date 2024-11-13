local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) and not vim.env.LAZY then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end

vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

if vim.g.usePluginsFromStore == nil then
  vim.g.usePluginsFromStore = false
end

local dev = {}

-- if vim.g.usePluginsFromStore and vim.g.pluginPath then
--   dev = {
--     path = function(plugin)
--       local myNeovimPackages = vim.g.pluginPath
--       local path = nil
--       local name = vim.g.pluginNameOverride[plugin.name] or plugin.name
--       if vim.fn.isdirectory(myNeovimPackages .. "/start/" .. name) == 1 then
--         path = myNeovimPackages .. "/start/" .. name
--       elseif vim.fn.isdirectory(myNeovimPackages .. "/opt/" .. name) == 1 then
--         path = myNeovimPackages .. "/opt/" .. name
--       elseif vim.fn.isdirectory(myNeovimPackages .. "/" .. name) == 1 then
--         path = myNeovimPackages .. "/" .. name
--       else
--         path = "~/projects/" .. name
--       end
--       return path
--     end,
--     patterns = { "." },
--     fallback = true,
--   }
-- end

--- @type LazyConfig
local lazyoptions = {
  spec = {
    -- add LazyVim and import its plugins
    {
      "LazyVim/LazyVim",
      opts = { news = { lazyvim = false, neovim = false } },
      import = "lazyvim.plugins",
    },
    { import = "lazyvim.plugins.extras.dap.core" },
    -- { import = "lazyvim.plugins.extras.coding.blink" },
    { import = "lazyvim.plugins.extras.dap.nlua" },
    { import = "lazyvim.plugins.extras.editor.dial" },
    { import = "lazyvim.plugins.extras.editor.harpoon2" },
    { import = "lazyvim.plugins.extras.editor.inc-rename" },
    { import = "lazyvim.plugins.extras.formatting.prettier" },
    { import = "lazyvim.plugins.extras.lang.clangd" },
    { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.nix" },
    { import = "lazyvim.plugins.extras.lang.nushell" },
    { import = "lazyvim.plugins.extras.lang.php" },
    { import = "lazyvim.plugins.extras.lang.prisma" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.sql" },
    { import = "lazyvim.plugins.extras.lang.tailwind" },
    { import = "lazyvim.plugins.extras.lang.terraform" },
    { import = "lazyvim.plugins.extras.lang.toml" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.linting.eslint" },
    { import = "lazyvim.plugins.extras.ui.mini-indentscope" },
    { import = "lazyvim.plugins.extras.ui.treesitter-context" },
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
    { import = "lazyvim.plugins.extras.util.project" },
    -- { import = "lazyvim.plugins.extras.coding.copilot" },
    { import = "plugins" },
  },
  dev = dev,
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = true,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
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
vim.g.pluginPathMap = vim.g.pluginPathMap or {}

for name, path in pairs(vim.g.pluginPathMap) do
  table.insert(lazyoptions.spec, 1, { name, dir = path })
end

vim.g.lazyOptions = vim.g.lazyOptions or {}

require("lazy").setup(vim.tbl_deep_extend("force", lazyoptions, vim.g.lazyOptions))

vim.g.lazyOptions = nil
vim.g.pluginPathMap = nil
