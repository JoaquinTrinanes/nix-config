local U = require("config.util")

---@type LazyPluginSpec[]
return {
  { "echasnovski/mini.extra", lazy = true },
  -- Better text-objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          -- g = LazyVim.mini.ai_buffer, -- buffer
          g = gen_ai_spec.buffer(),
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      U.on_load("which-key.nvim", function()
        vim.schedule(function()
          local objects = {
            { " ", desc = "whitespace" },
            { '"', desc = '" string' },
            { "'", desc = "' string" },
            { "(", desc = "() block" },
            { ")", desc = "() block with ws" },
            { "<", desc = "<> block" },
            { ">", desc = "<> block with ws" },
            { "?", desc = "user prompt" },
            { "U", desc = "use/call without dot" },
            { "[", desc = "[] block" },
            { "]", desc = "[] block with ws" },
            { "_", desc = "underscore" },
            { "`", desc = "` string" },
            { "a", desc = "argument" },
            { "b", desc = ")]} block" },
            { "c", desc = "class" },
            { "d", desc = "digit(s)" },
            { "e", desc = "CamelCase / snake_case" },
            { "f", desc = "function" },
            { "g", desc = "entire file" },
            { "i", desc = "indent" },
            { "o", desc = "block, conditional, loop" },
            { "q", desc = "quote `\"'" },
            { "t", desc = "tag" },
            { "u", desc = "use/call" },
            { "{", desc = "{} block" },
            { "}", desc = "{} with ws" },
          }

          ---@type wk.Spec[]
          local ret = { mode = { "o", "x" } }
          ---@type table<string, string>
          local mappings = vim.tbl_extend("force", {}, {
            around = "a",
            inside = "i",
            around_next = "an",
            inside_next = "in",
            around_last = "al",
            inside_last = "il",
          }, opts.mappings or {})
          mappings.goto_left = nil
          mappings.goto_right = nil

          for name, prefix in pairs(mappings) do
            name = name:gsub("^around_", ""):gsub("^inside_", "")
            ret[#ret + 1] = { prefix, group = name }
            for _, obj in ipairs(objects) do
              local desc = obj.desc
              if prefix:sub(1, 1) == "i" then
                desc = desc:gsub(" with ws", "")
              end
              ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
            end
          end
          require("which-key").add(ret, { notify = false })
        end)
      end)
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts_extend = { "library" },
    specs = {
      {
        "saghen/blink.cmp",
        optional = true,
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
          sources = {
            per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
            providers = {
              lazydev = {
                name = "LazyDev",
                module = "lazydev.integrations.blink",
                score_offset = 100, -- show at a higher priority than lsp
              },
            },
          },
        },
      },
    },
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim" },
      },
    },
  },
}
