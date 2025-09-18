---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Wrapper around vim.keymap.set that will
-- not create a keymap if a lazy key handler exists.
-- It will also set `silent` to true by default.
local function safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys --[[@as LazyKeysHandler]]
  local modes = type(mode) == "string" and { mode } or mode

  ---@param m string
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      ---@diagnostic disable-next-line: no-unknown
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

-- Handle wrapped lines with normal movement
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })

-- Move Lines
map("n", "<A-j>", "<Cmd>execute 'move .+' . v:count1<CR>==", { desc = "Move Down" })
map("n", "<A-k>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><Cmd>m .+1<CR>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><Cmd>m .-2<CR>==gi", { desc = "Move Up" })
map("v", "<A-j>", [[<Cmd>execute "'<,'>move '>+" . v:count1<CR>gv=gv]], { desc = "Move Down" })
map("v", "<A-k>", [[<Cmd>execute "'<,'>move '<-" . (v:count1 + 1)<CR>gv=gv]], { desc = "Move Up" })

-- buffers
map("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "[b", "<Cmd>bprevious<CR>", { desc = "Prev Buffer" })
map("n", "]b", "<Cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<Cmd>e #<CR>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<Cmd>e #<CR>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function()
  require("snacks").bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function()
  require("snacks").bufdelete.other()
end, { desc = "Delete Other Buffers" })
map("n", "<leader>bD", "<Cmd>:bd<CR>", { desc = "Delete Buffer and Window" })

-- Clear search and stop snippet on escape
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  -- LazyVim.cmp.actions.snippet_stop()
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Move current line(s) down by {count}
map("n", "<C-A-j>", function()
  local count = vim.v.count1
  return string.format(":%dmove .+%d<CR>==", count, count)
end, { expr = true, desc = "Move line(s) down by count", silent = true })

-- Move current line(s) up by {count}
map("n", "<C-A-j>", function()
  local count = vim.v.count1
  vim.cmd("move .+" .. count)
end, { desc = "Move line down by count", silent = true })
map("n", "<C-A-k>", function()
  local count = vim.v.count1
  -- move up needs +1 because :move places *after* target
  vim.cmd("move .-" .. (count + 1))
end, { desc = "Move line up by count", silent = true })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Add undo break-points
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", ";", ";<C-g>u")

--keywordprg
map("n", "<leader>K", "<Cmd>norm! K<CR>", { desc = "Keywordprg" })

-- keep selection after indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- commenting
map("n", "gco", "o<esc>Vcx<esc><Cmd>normal gcc<CR>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><Cmd>normal gcc<CR>fxa<bs>", { desc = "Add Comment Above" })

-- lazy
map("n", "<leader>l", "<Cmd>Lazy<CR>", { desc = "Lazy" })

-- new file
map("n", "<leader>fn", "<Cmd>enew<CR>", { desc = "New File" })

-- location list
map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })

-- quickfix list
map("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- diagnostic
local diagnostic_goto = function(next, severity)
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    vim.diagnostic.jump({ count = next and 1 or -1, float = true, severity = severity })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

if vim.lsp.inlay_hint then
  Snacks.toggle.inlay_hints():map("<leader>uh")
end

-- lazygit
-- if vim.fn.executable("lazygit") == 1 then
-- map("n", "<leader>gg", function() Snacks.lazygit( { cwd = LazyVim.root.git() }) end, { desc = "Lazygit (Root Dir)" })
-- map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
-- map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })
-- map("n", "<leader>gl", function() Snacks.picker.git_log({ cwd = LazyVim.root.git() }) end, { desc = "Git Log" })
-- map("n", "<leader>gL", function() Snacks.picker.git_log() end, { desc = "Git Log (cwd)" })
-- end

-- map("n", "<leader>gb", function() Snacks.picker.git_log_line() end, { desc = "Git Blame Line" })
-- map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })
-- map({"n", "x" }, "<leader>gY", function()
--   Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
-- end, { desc = "Git Browse (copy)" })

-- quit
map("n", "<leader>qq", "<Cmd>qa<CR>", { desc = "Quit All" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })

-- floating terminal
-- map("n", "<leader>fT", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
-- map("n", "<leader>ft", function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "Terminal (Root Dir)" })
-- map("n", "<C-/>",      function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "Terminal (Root Dir)" })
-- map("n", "<C-_>",      function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "which_key_ignore" })

-- Terminal Mappings
map("t", "<C-/>", "<Cmd>close<CR>", { desc = "Hide Terminal" })
map("t", "<C-_>", "<Cmd>close<CR>", { desc = "which_key_ignore" })

-- windows
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
-- Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
-- Snacks.toggle.zen():map("<leader>uz")

-- tabs
map("n", "<leader><Tab>l", "<Cmd>tablast<CR>", { desc = "Last Tab" })
map("n", "<leader><Tab>o", "<Cmd>tabonly<CR>", { desc = "Close Other Tabs" })
map("n", "<leader><Tab>f", "<Cmd>tabfirst<CR>", { desc = "First Tab" })
map("n", "<leader><Tab><Tab>", "<Cmd>tabnew<CR>", { desc = "New Tab" })
map("n", "<leader><Tab>]", "<Cmd>tabnext<CR>", { desc = "Next Tab" })
map("n", "<leader><Tab>d", "<Cmd>tabclose<CR>", { desc = "Close Tab" })
map("n", "<leader><Tab>[", "<Cmd>tabprevious<CR>", { desc = "Previous Tab" })

map("n", "Q", "@qj")
map("x", "Q", ":norm @q<CR>")

-- Ctrl-Backspace to delete previous word in insert mode
map("i", "<C-BS>", "<C-W>")

map("n", "y<C-g>", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
end, {
  expr = true,
})

map("n", "<leader>fd", function()
  vim.fn.setreg("+", vim.fs.dirname(vim.fn.expand("%:.")))
end, { desc = "Copy relative file directory" })

map("n", "<leader>fD", function()
  vim.fn.setreg("+", vim.fs.dirname(vim.fn.expand("%:p")))
end, { desc = "Copy file directory" })

map("n", "<leader>fy", function()
  vim.fn.setreg("+", vim.fn.expand("%:."))
end, { desc = "Copy relative file path" })

map("n", "<leader>fY", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy file path" })

map("i", "<C-c>", "<Esc>")

-- Buffers. Only set if no other plugin does
safe_keymap_set("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "Prev Buffer" })
safe_keymap_set("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "Next Buffer" })
safe_keymap_set("n", "[b", "<Cmd>bprevious<CR>", { desc = "Prev Buffer" })
safe_keymap_set("n", "]b", "<Cmd>bnext<CR>", { desc = "Next Buffer" })

map("n", "<Esc>", "<Cmd>nohlsearch<CR>")

map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

map("n", "<leader>l", "<Cmd>Lazy<CR>")

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- CTRL+<hjkl> to switch between windows (:h wincmd)
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Clear search, diff update and redraw
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / Clear hlsearch / Diff Update" }
)

map("n", "<leader>w", "<C-w>", { desc = "Windows", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

map("n", "<Tab>", function()
  local line = vim.fn.line(".")
  local fold_level = vim.fn.foldlevel(line)

  -- Only toggle if there's a fold on this line
  if fold_level > 0 then
    vim.cmd("normal! za")
  end
end, {
  desc = "Toggle fold under cursor",
})

-- Don't copy text when deleting single characters
map("n", "x", [["_x]])
map("n", "X", [["_X]])

-- Yank, paste and delete without affecting the system clipboard
map({ "n", "v" }, "<leader>y", '"*y')
map("n", "<leader>Y", '"*y$')
map({ "n", "v" }, "<leader>p", '"*p')
map({ "n", "v" }, "<leader>P", '"*P')
map({ "n", "v" }, "<leader>d", '"*d')
map("n", "<leader>D", '"*D')
