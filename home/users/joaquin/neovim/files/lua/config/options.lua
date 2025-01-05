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
  local result = {}
  if #args.fargs == 1 then
    result = LazyVim.opts(args.fargs[1])
  else
    for _, name in ipairs(args.fargs) do
      local opts = LazyVim.opts(name)
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

vim.g.snacks_animate = false
vim.g.root_spec = { "cwd", "lsp", { ".git", "lua" } }
vim.g.lazyvim_php_lsp = "intelephense"
vim.g.ai_cmp = false
