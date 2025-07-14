local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

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
else
  opt.pumblend = 10
  opt.termguicolors = true
end

opt.conceallevel = 0

-- Highlight one character after textwidth
opt.colorcolumn = "+1"

opt.ignorecase = true
opt.smartcase = true

opt.showmatch = true

opt.signcolumn = "yes"

opt.splitright = true
opt.splitbelow = true

opt.backup = false
opt.writebackup = false
opt.swapfile = false

opt.autoread = true
opt.autowrite = true

opt.hidden = true
opt.errorbells = false
opt.backspace = { "indent", "eol", "start" }
opt.autochdir = false
opt.mouse = "a"

vim.opt.clipboard = "unnamedplus"

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- Use treesitter for folding
opt.foldlevel = 99

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- Show which line your cursor is on
opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10
opt.sidescrolloff = 8

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

---@type 'intelephense'|'phpactor'
vim.g.lazyvim_php_lsp = "intelephense"

---@type 'auto'|'nvim-cmp'|'blink.cmp'
vim.g.lazyvim_cmp = "auto"

---@type 'auto'|'snacks'|'fzf'|'telescope'|nil
vim.g.lazyvim_picker = "auto"

vim.g.ai_cmp = false

vim.g.dbs = {
  {
    name = "local",
    url = function()
      return vim.env.DATABASE_URL
        or ("%s://%s:%s@%s:%s/%s"):format(
          vim.env.DB_PROTOCOL or vim.env.DATABASE_PROTOCOL or "postgres",
          vim.env.DB_USER or vim.env.DATABASE_USER,
          vim.env.DB_PASSWORD or vim.env.DATABASE_PASSWORD,
          vim.env.DB_HOST or vim.env.DATABASE_HOST or "localhost",
          vim.env.DB_PORT or vim.env.DATABASE_PORT or "5432",
          vim.env.DB_NAME or vim.env.DATABASE_NAME
        )
    end,
  },
  {
    name = "local postgres",
    url = function()
      return vim.env.PG_URL
        or ("postgresql://%s:%s@%s:%s/%s"):format(
          vim.env.PGUSER,
          vim.env.PGPASSWORD,
          vim.env.PGHOST or "localhost",
          vim.env.PGPORT or "5432",
          vim.env.PGDATABASE
        )
    end,
  },
}
