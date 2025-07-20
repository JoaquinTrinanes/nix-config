local opt = vim.opt
local o = vim.o

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

o.confirm = true

o.number = true
o.relativenumber = true

o.smarttab = true
o.expandtab = true -- Use spaces instead of tabs
o.shiftround = true -- Round indent
o.shiftwidth = 2 -- Size of an indent
o.tabstop = 2 -- Number of spaces tabs count for
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

o.updatetime = 200 -- Save swap file and trigger CursorHold
o.timeoutlen = 300

o.smartindent = true -- Insert indents automatically

o.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode

opt.shortmess:append({ W = true, I = true, c = true, C = true })

opt.completeopt = { "menuone", "longest" }
opt.wildmode = { "longest:full", "full" } -- Command-line completion mode

o.wrap = true
o.linebreak = true
o.smoothscroll = true

o.undofile = true
o.undolevels = 10000

if vim.env.COLORTERM == nil then
  o.pumblend = 0 -- Popup blend
  o.termguicolors = false
else
  o.pumblend = 10
  o.termguicolors = true
end

o.conceallevel = 0

-- Highlight one character after textwidth
o.colorcolumn = "+1"

o.ignorecase = true
o.smartcase = true

o.signcolumn = "yes"

o.splitright = true
o.splitbelow = true

o.backup = false
o.writebackup = true
o.swapfile = true

o.autoread = true
o.autowrite = true

o.hidden = true
o.errorbells = false
opt.backspace = { "indent", "eol", "start" }
o.autochdir = false
o.mouse = "a"

o.clipboard = "unnamedplus"

o.foldmethod = "expr"
o.foldlevel = 99
o.foldtext = ""

o.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live
o.inccommand = "split"

o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
o.scrolloff = 10
o.sidescrolloff = 8

o.grepprg = "rg --vimgrep"

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

vim.api.nvim_create_user_command("FtPlugin", function(opts)
  local filetype = opts.args
  local rtp = vim.opt.runtimepath:get()

  local already_opened_file = false
  local open = function(...)
    if already_opened_file then
      return vim.cmd.badd(...)
    else
      already_opened_file = true
      return vim.cmd.edit(...)
    end
  end

  for _, path in ipairs(rtp) do
    local plugin_path = path .. "/ftplugin/" .. filetype .. ".vim"
    local plugin_lua_path = path .. "/ftplugin/" .. filetype .. ".lua"

    if vim.fn.filereadable(plugin_path) == 1 then
      open(plugin_path)
    end
    if vim.fn.filereadable(plugin_lua_path) == 1 then
      open(plugin_lua_path)
      -- vim.print(plugin_lua_path)
    end
  end
end, {
  nargs = 1,
  complete = "filetype",
})
