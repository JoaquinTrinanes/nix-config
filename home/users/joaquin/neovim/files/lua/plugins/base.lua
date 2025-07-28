---@type LazyPluginSpec[]
local M = {
  {
    "julienvincent/hunk.nvim",
    cmd = { "DiffEditor" },
    opts = {
      hooks = {
        ---@class HunkTree
        ---@class HunkChangeset
        ---@field filepath string
        ---@field hunks { left: [number, number]; right: [number, number] }[]
        ---@field left_filepath string
        ---@field right_filepath string
        ---@field selected boolean
        ---@field selected_lines { left: integer[]; right: integer[]; }
        ---@field type "added" | "modified" | "deleted"
        ---@class HunkTreeMountOpts
        ---@field changeset table<string, HunkChangeset>
        ---@field on_open fun(change: HunkChangeset, opts: {tree: HunkTree?; })
        ---@class HunkContext
        ---@field buf integer
        ---@field opts HunkTreeMountOpts
        ---@field tree table
        ---@param context HunkContext
        on_tree_mount = function(context)
          if vim.fn.hasmapto("j", "n") == 1 then
            vim.keymap.set({ "n", "x" }, "j", "j", {
              nowait = true,
              buffer = context.buf,
            })
          end

          if vim.fn.hasmapto("k", "n") == 1 then
            vim.keymap.set({ "n", "x" }, "k", "k", {
              nowait = true,
              buffer = context.buf,
            })
          end

          vim.keymap.set("n", "<space>ff", function()
            Snacks.picker.pick({
              items = vim
                .iter(context.opts.changeset)
                ---@param v HunkChangeset
                :map(function(k, v)
                  ---@type snacks.picker.Item
                  return { file = v.filepath, text = k, change = v }
                end)
                :totable(),
              confirm = function(_, item)
                context.opts.on_open(item.change, { tree = context.tree })
              end,
            })
          end, { desc = "Find files in diff" })
        end,
      },
      ui = {
        tree = {
          mode = "flat",
          -- width = 100,
        },
      },
    },
  },
  {
    "ibhagwan/fzf-lua",
    optional = true,
    opts = {
      "hide",
      "fzf-native",
      lsp = { code_actions = { winopts = { relative = "cursor", backdrop = 100, row = 1 } } },
      keymap = {
        builtin = { true, ["<C-c>"] = "hide" },
        fzf = { true, ["ctrl-y"] = "accept" },
      },
      fzf_opts = {
        ["--cycle"] = true,
      },
    },
  },
  {
    "mrjones2014/smart-splits.nvim",
    keys = {
      -- stylua: ignore start
      -- Resizing splits
      { "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize left", },
      { "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize down", },
      { "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize up", },
      { "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize right", },

      -- Moving between splits
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to split below" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to split above" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },

      -- Swapping buffers between windows
      { "<leader><leader>h>", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer with left split" },
      { "<leader><leader>j>", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer with split below" },
      { "<leader><leader>k>", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer with split above" },
      { "<leader><leader>l>", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer with right split" },
      -- stylua: ignore end
    },
    enabled = false,
    version = "*",
    priority = 1000,
    lazy = false,
  },
  { "nvim-lua/plenary.nvim", lazy = true },
}

return M
