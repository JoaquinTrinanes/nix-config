local U = require("config.util")

vim.api.nvim_create_autocmd("FileType", {
  group = U.augroup("enable_treesitter_highlights"),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)

    if not lang then
      return
    end

    if vim.treesitter.language.add(lang) then
      vim.treesitter.start(args.buf, lang)

      if not vim.wo.foldexpr or vim.wo.foldexpr == "0" then
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      end
      if not vim.bo[args.buf].indentexpr then
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end
  end,
})

---@type LazyPluginSpec[]
return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost" },
    opts = function()
      local tsc = require("treesitter-context")
      Snacks.toggle({
        name = "Treesitter Context",
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map("<leader>ut")
      return { mode = "cursor", max_lines = 5 }
    end,
  },
  {
    "folke/ts-comments.nvim",
    opts = {
      lang = {
        -- Fix being unable to uncomment comments
        phpdoc = { "// %s" },
      },
    },
  },
  {
    -- Automatically add closing tags for HTML and JSX
    "windwp/nvim-ts-autotag",
    opts = {},
    lazy = false,
  },
}
