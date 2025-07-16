local U = require("config.util")

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
        nix = { "statix", "deadnix" },
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
      local events = { "BufWritePost", "BufReadPost", "InsertLeave" }

      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      vim.api.nvim_create_autocmd(events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = U.debounce(function()
          require("lint").try_lint()
        end, 100),
      })
    end,
  },
}
