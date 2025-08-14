local U = {}

function U.dedup(tbl)
  local seen = {}
  local result = {}

  for _, value in ipairs(tbl) do
    if not seen[value] then
      table.insert(result, value)
      seen[value] = true
    end
  end

  return result
end

---@param name string
---@param opts? vim.api.keyset.create_augroup
function U.augroup(name, opts)
  return vim.api.nvim_create_augroup(name, vim.tbl_deep_extend("force", { clear = true }, opts or {}))
end

U.lsp = {}

local lsp_attach_group = U.augroup("lsp_attach")

---@class ExtendedLspConfig: vim.lsp.Config
---@field enabled? boolean

---@param server string
---@param server_config? ExtendedLspConfig
function U.lsp.config(server, server_config)
  server_config = server_config or {}
  local enabled = server_config.enabled ~= false
  vim.lsp.config(server, server_config)

  vim.lsp.enable(server, enabled)
end

---@param on_attach fun(client: vim.lsp.Client, buffer: number)
---@param name? string
function U.lsp.on_attach(on_attach, name)
  return vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_attach_group,
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and (not name or client.name == name) then
        return on_attach(client, buffer)
      end
    end,
  })
end

---@class PickLSPCommandOpts
---@field prompt_for_args boolean

---Pick and execute an LSP server command from any client
---@param opts PickLSPCommandOpts?
function U.lsp.select_command(opts)
  ---@alias CmdOption { client: vim.lsp.Client, command: string }
  opts = opts or {}
  opts = vim.tbl_deep_extend("force", { prompt_for_args = false }, opts)

  -- Get all LSP clients attached to the current buffer
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  ---@type CmdOption[]
  local all_commands = {}
  for _, client in ipairs(clients) do
    if client:supports_method("workspace/executeCommand") then
      local cmds = client.server_capabilities.executeCommandProvider
      if cmds and cmds.commands then
        for _, c in ipairs(cmds.commands) do
          vim.list_extend(all_commands, { { client = client, command = c } })
        end
      end
    end
  end

  if #all_commands == 0 then
    vim.notify("No executable commands available from attached clients", vim.log.levels.INFO, { title = "LSP" })
    return
  end

  vim.ui.select(
    all_commands,
    {
      prompt = "Select LSP command to run",
      ---@param item CmdOption
      format_item = function(item)
        return string.format("[%s] %s", item.client.name, item.command)
      end,
    },
    ---@param choice CmdOption
    function(choice)
      if choice then
        local args = {}
        if opts.prompt_for_args then
          local input = vim.fn.input("Arguments (comma-separated, leave empty if none): ")
          args = vim.split(input, "%s*,%s*", { trimempty = true })
        end
        choice.client:exec_cmd(
          { command = choice.command, arguments = args },
          { bufnr = 0 },
          function(err, result, context, config)
            if err then
              vim.notify(err.message, vim.log.levels.ERROR, { title = "LSP" })
              return
            end
            if result then
              vim.notify(vim.inspect(result), vim.log.levels.INFO, { title = "LSP" })
              return
            end
            vim.notify(
              string.format("%s finished without output", context.method),
              vim.log.levels.INFO,
              { title = "LSP" }
            )
          end
        )
      end
    end
  )
end

---@param plugin_name string
function U.opts(plugin_name)
  local plugin = require("lazy.core.config").spec.plugins[plugin_name]
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

---@generic T : function
---@param fn T
---@param ms number
---@return T
function U.debounce(fn, ms)
  local timer = vim.uv.new_timer()
  ---@cast timer uv.uv_timer_t

  return function(...)
    local argv = { ... }
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule_wrap(fn)(unpack(argv))
    end)
  end
end

---@param plugin string
function U.has(plugin)
  return require("lazy.core.config").spec.plugins[plugin] ~= nil
end

function U.on_load(name, fn)
  local Config = require("lazy.core.config")
  local is_loaded = Config.plugins[name] and Config.plugins[name]._.loaded

  if is_loaded then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

---@param parent string
---@param child string
---@return boolean
function U.is_subpath(parent, child)
  parent = vim.uv.fs_realpath(parent) or ""
  child = vim.uv.fs_realpath(child) or ""

  if not parent or not child then
    return false
  end

  -- Add trailing slash to parent to avoid partial matches
  if not parent:match("/$") then
    parent = parent .. "/"
  end

  return child == parent or child:sub(1, #parent) == parent
end

return U
