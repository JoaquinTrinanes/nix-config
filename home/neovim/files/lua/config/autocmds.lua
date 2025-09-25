local U = require("config.util")

local augroup = U.augroup

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check if file needs reloading when changed",
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd.checktime()
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
  desc = "Resize splits if window got resized",
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- go to last loc when opening a buffer
-- TODO: compare against plugin-less nvim config
-- vim.api.nvim_create_autocmd("BufReadPost", {
--   group = augroup("last_loc"),
--   callback = function(event)
--     local exclude = { "gitcommit" }
--     local buf = event.buf
--     if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
--       return
--     end
--     vim.b[buf].lazyvim_last_loc = true
--     local mark = vim.api.nvim_buf_get_mark(buf, '"')
--     local lcount = vim.api.nvim_buf_line_count(buf)
--     if mark[1] > 0 and mark[1] <= lcount then
--       pcall(vim.api.nvim_win_set_cursor, 0, mark)
--     end
--   end,
-- })

vim.api.nvim_create_autocmd("FileType", {
  desc = "Close some filetypes with <q>",
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "snacks_dashboard",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Make it easier to close man-files when opened inline",
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Wrap and check for spell in text filetypes",
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  desc = "Auto create dir when saving a file, in case some intermediate directory does not exist",
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Disable colorcolumn when buffer is not modifiable",
  group = augroup("disable_colorcolum"),
  callback = function(event)
    local buf = event.buf
    local bo = vim.bo[buf]

    if not bo.modifiable then
      vim.wo.colorcolumn = ""
    end
  end,
})

local executable_on_shebang_group = augroup("executable_on_shebang")

vim.api.nvim_create_autocmd("BufNewFile", {
  desc = "On new file, check for shebang after first write",
  group = executable_on_shebang_group,
  callback = function(newFileEvent)
    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = newFileEvent.buf,
      desc = "Make new file executable if it has a shebang",
      group = executable_on_shebang_group,
      once = true,
      callback = function(event)
        local filepath = vim.api.nvim_buf_get_name(event.buf)
        local first_line = vim.api.nvim_buf_get_lines(event.buf, 0, 1, false)[1]
        if not first_line or not first_line:match("^#!/") then
          return
        end

        local perms = vim.fn.getfperm(filepath)
        if perms:sub(3, 3) == "x" then
          -- already executable by owner
          return
        end

        local new_perms = perms:sub(1, 2) .. "x" .. perms:sub(4)
        vim.fn.setfperm(filepath, new_perms)

        vim.notify(
          "Made '" .. vim.fn.fnamemodify(filepath, ":t") .. "' executable",
          vim.log.levels.INFO,
          { title = "Shebang Detected" }
        )
      end,
    })
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  desc = "Disable undofile for some paths",
  group = augroup("disable_undofile"),
  callback = function(event)
    local fname = vim.fn.resolve(event.file)
    local bo = vim.bo[event.buf]

    if
      not bo.modifiable
      or bo.buftype ~= ""
      or vim.startswith(fname, "/tmp/")
      or fname:match("/node_modules/")
      or vim.startswith(fname, "/nix/store/")
      or fname:match("COMMIT_EDITMSG$")
    then
      bo.undofile = false
    end
  end,
})
