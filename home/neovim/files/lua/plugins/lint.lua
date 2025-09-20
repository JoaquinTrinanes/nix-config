local U = require("config.util")

---@type LazyPluginSpec[]
return {
  {
    "mfussenegger/nvim-lint",
    opts = function()
      local lint = require("lint")
      local original_terraform_validate = lint.linters.terraform_validate
      lint.linters.terraform_validate = function()
        local terraform_validate = original_terraform_validate()
        terraform_validate.cmd = vim.env.TERRAFORM_BINARY_NAME
          or vim.fn.executable("tofu") == 1 and "tofu"
          or "terraform"
        return terraform_validate
      end
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        php = {},
        nix = { "statix" },
      },
      ---@module "lint"
      ---@class lint.Linter
      ---@field condition fun(ctx: { filename: string, dirname: string }): boolean
      ---@type table<string, lint.Linter>
      linters = {
        shellcheck = {
          condition = function(ctx)
            local name = vim.fs.basename(ctx.filename)
            if name == nil then
              return false
            end
            local is_dotenv = name == ".env" or name == ".envrc" or vim.startswith(name, ".env.")

            return not is_dotenv
          end,
        },
      },
    },
    config = function(_, opts)
      local lint = require("lint")

      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = U.augroup("nvim-lint"),
        callback = U.debounce(function(event)
          local linters = lint._resolve_linter_by_ft(vim.bo.filetype)
          linters = vim.list_extend({}, linters)

          -- Filter out linters that don't exist or don't match the condition.
          local ctx = { filename = vim.api.nvim_buf_get_name(0) }
          ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
          linters = vim.tbl_filter(function(name)
            local linter = lint.linters[name]
            if not linter then
              vim.notify("Linter not found: " .. name, vim.log.levels.WARN, { title = "nvim-lint" })
            end
            return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
          end, linters)

          if #linters > 0 then
            lint.try_lint(linters)
          end
        end, 100),
      })
    end,
  },
}
