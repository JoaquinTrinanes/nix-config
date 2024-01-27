local M = {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        -- hijack_netrw_behavior = "open_current",
        hijack_netrw_behavior = "disabled",
      },
    },
  },
}

return M
