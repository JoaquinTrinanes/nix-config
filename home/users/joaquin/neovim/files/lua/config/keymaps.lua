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
