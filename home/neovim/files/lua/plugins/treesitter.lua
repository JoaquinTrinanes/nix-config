local U = require("config.util")

local filetypes = {
  angular = { "htmlangular" },
  bash = { "sh" },
  bibtex = { "bib" },
  c_sharp = { "cs", "csharp", "c-sharp" },
  commonlisp = { "lisp" },
  cooklang = { "cook" },
  devicetree = { "dts" },
  diff = { "gitdiff" },
  eex = { "eelixir" },
  elixir = { "ex" },
  embedded_template = { "eruby" },
  erlang = { "erl" },
  facility = { "fsd" },
  faust = { "dsp" },
  gdshader = { "gdshaderinc" },
  git_config = { "gitconfig" },
  git_rebase = { "gitrebase" },
  glimmer = { "handlebars", "html.handlebars" },
  godot_resource = { "gdresource" },
  haskell = { "hs" },
  haskell_persistent = { "haskellpersistent" },
  idris = { "idris2" },
  ini = { "confini", "dosini" },
  janet_simple = { "janet" },
  javascript = { "javascriptreact", "ecma", "ecmascript", "jsx", "js" },
  javascript_glimmer = { "javascript.glimmer" },
  latex = { "tex" },
  linkerscript = { "ld" },
  m68k = { "asm68k" },
  make = { "automake" },
  markdown = { "pandoc" },
  muttrc = { "neomuttrc" },
  ocaml_interface = { "ocamlinterface" },
  perl = { "pl" },
  poe_filter = { "poefilter" },
  powershell = { "ps1" },
  properties = { "jproperties" },
  python = { "py", "gyp" },
  qmljs = { "qml" },
  runescript = { "clientscript" },
  scala = { "sbt" },
  slang = { "shaderslang" },
  sqp = { "mysqp" },
  ssh_config = { "sshconfig" },
  starlark = { "bzl" },
  surface = { "sface" },
  systemverilog = { "verilog" },
  t32 = { "trace32" },
  tcl = { "expect" },
  terraform = { "terraform-vars" },
  textproto = { "pbtxt" },
  tlaplus = { "tla" },
  tsx = { "typescriptreact", "typescript.tsx" },
  typescript = { "ts" },
  typescript_glimmer = { "typescript.glimmer" },
  typst = { "typ" },
  udev = { "udevrules" },
  uxntal = { "tal", "uxn" },
  v = { "vlang" },
  vhs = { "tape" },
  xml = { "xsd", "xslt", "svg" },
  xresources = { "xdefaults" },
}

for lang, ft in pairs(filetypes) do
  vim.treesitter.language.register(lang, ft)
end

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
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = false,
    branch = "main",
    ---@module 'nvim-treesitter-textobjects'
    ---@type TSTextObjects.UserConfig
    opts = {
      move = { set_jumps = true },
      select = { lookahead = true, include_surrounding_whitespace = false },
    },
  },
  { "echasnovski/mini.extra", lazy = true },
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
}
