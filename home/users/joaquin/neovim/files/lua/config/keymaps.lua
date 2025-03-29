-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

local mapSafe = LazyVim.safe_keymap_set

-- don't copy text when deleting single characters
map("n", "x", [["_x]])
map("n", "X", [["_X]])

map("n", "Q", "@qj")
map("x", "Q", ":norm @q<CR>")

-- Ctrl-Backspace to delete previous word in insert mode
map("i", "<C-BS>", "<C-W>")

-- resizing splits
map("n", "<A-h>", function()
  require("smart-splits").resize_left()
end)
map("n", "<A-j>", function()
  require("smart-splits").resize_down()
end)
map("n", "<A-k>", function()
  require("smart-splits").resize_up()
end)
map("n", "<A-l>", function()
  require("smart-splits").resize_right()
end)

-- moving between splits
map("n", "<C-h>", function()
  require("smart-splits").move_cursor_left()
end)
map("n", "<C-j>", function()
  require("smart-splits").move_cursor_down()
end)
map("n", "<C-k>", function()
  require("smart-splits").move_cursor_up()
end)
map("n", "<C-l>", function()
  require("smart-splits").move_cursor_right()
end)

-- swapping buffers between windows
map("n", "<leader><leader>h>", function()
  require("smart-splits").swap_buf_left()
end)
map("n", "<leader><leader>j>", function()
  require("smart-splits").swap_buf_down()
end)
map("n", "<leader><leader>k>", function()
  require("smart-splits").swap_buf_up()
end)
map("n", "<leader><leader>l>", function()
  require("smart-splits").swap_buf_right()
end)

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

-- better up/down
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
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- Buffers. Only set if no other plugin does
mapSafe("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
mapSafe("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
mapSafe("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
mapSafe("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

map("n", "<leader>l", "<cmd>Lazy<cr>")

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
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

map("n", "<leader>w", "<c-w>", { desc = "Windows", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
