---@param buf? number
local function is_autoformat_enabled(buf)
  buf = buf == nil and 0 or buf
  local gaf = vim.g.autoformat
  local baf = vim.b[buf].autoformat

  -- If the buffer has a local value, use that
  if baf ~= nil then
    return baf
  end

  -- Otherwise use the global value if set, or true by default
  return gaf == nil or gaf
end

---@param enable? boolean
---@param buf? boolean
local function enable_autoformat(enable, buf)
  if enable == nil then
    enable = true
  end
  if buf then
    vim.b.autoformat = enable
  else
    vim.g.autoformat = enable
    vim.b.autoformat = nil
  end
end

---@param buf? number
local function info(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local gaf = vim.g.autoformat == nil or vim.g.autoformat
  local baf = vim.b[buf].autoformat
  local enabled = is_autoformat_enabled(buf)
  local lines = {
    "# Status",
    ("- [%s] global **%s**"):format(gaf and "x" or " ", gaf and "enabled" or "disabled"),
    ("- [%s] buffer **%s**"):format(
      enabled and "x" or " ",
      baf == nil and "inherit" or baf and "enabled" or "disabled"
    ),
  }
  local conform_formatters = require("conform").list_formatters(buf)

  local have = false
  lines[#lines + 1] = "\n# " .. "conform.nvim" .. (true and " ***(active)***" or "")
  for _, formatter in ipairs(conform_formatters) do
    have = true
    lines[#lines + 1] = ("- [%s] **%s**"):format(formatter.available and "x" or " ", formatter.name)
  end
  if not have then
    lines[#lines + 1] = "\n***No formatters available for this buffer.***"
  end

  vim.notify(table.concat(lines, "\n"), {
    level = enabled and vim.log.levels.INFO or vim.log.levels.WARN,
  })
end

vim.api.nvim_create_user_command("FormatInfo", function()
  info()
end, { desc = "Show info about the formatters for the current buffer" })

---@param local_to_buffer? boolean
local function snacks_toggle(local_to_buffer)
  return require("snacks").toggle({
    name = "Auto Format (" .. (local_to_buffer and "Buffer" or "Global") .. ")",
    get = function()
      if not local_to_buffer then
        return vim.g.autoformat == nil or vim.g.autoformat
      end
      return is_autoformat_enabled()
    end,
    set = function(state)
      enable_autoformat(state, local_to_buffer)
      info()
    end,
  })
end

snacks_toggle():map("<leader>uf")
snacks_toggle(true):map("<leader>uF")

---@type conform.FiletypeFormatter
local biomePrettierFormatters = { "prettier_cwd", "biome-check", stop_after_first = true }

---@type LazyPluginSpec[]
return {
  {
    "stevearc/conform.nvim",
    lazy = true,
    cmd = "ConformInfo",
    event = { "BufWritePre" },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format()
        end,
        mode = { "n", "v" },
        desc = "Format",
      },
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      default_format_opts = {
        async = false,
        lsp_format = "fallback",
      },
      format_on_save = function(bufnr)
        if not is_autoformat_enabled(bufnr) then
          return
        end
        return {}
      end,
      formatters_by_ft = {
        astro = biomePrettierFormatters,
        css = biomePrettierFormatters,
        graphql = biomePrettierFormatters,
        html = biomePrettierFormatters,
        javascript = biomePrettierFormatters,
        javascriptreact = biomePrettierFormatters,
        json = biomePrettierFormatters,
        jsonc = biomePrettierFormatters,
        svelte = biomePrettierFormatters,
        typescript = biomePrettierFormatters,
        typescriptreact = biomePrettierFormatters,

        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        php = { "pint", "php_cs_fixer", stop_after_first = true },
        blade = { "prettier" },
        typst = { "typstyle" },
        terraform = { "tofu_fmt", "terraform_fmt", stop_after_first = true },
        nix = { "nixfmt" },
        nu = { "topiary_nu" },
        ["_"] = {
          "trim_whitespace",
          lsp_format = "prefer",
        },
      },
      formatters = {
        sqlfluff = { require_cwd = false },
        topiary_nu = {
          command = "topiary",
          args = { "format", "--language", "nu" },
        },
        injected = {
          ---@type conform.InjectedFormatterOptions
          options = { ignore_errors = true },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      local prettier_cwd = vim.deepcopy(require("conform.formatters.prettier"))

      prettier_cwd = vim.tbl_deep_extend("force", prettier_cwd, { require_cwd = true })

      opts.formatters = opts.formatters or {}
      opts.formatters.prettier_cwd = prettier_cwd
    end,
  },
}
