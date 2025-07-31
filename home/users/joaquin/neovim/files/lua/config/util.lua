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

local lsp_attach = vim.api.nvim_create_augroup("lsp_attach", { clear = true })

U.lsp = {}

---@class ExtendedLspConfig: vim.lsp.Config
---@field enabled? boolean

---@param server string
---@param server_config? ExtendedLspConfig
function U.lsp.config(server, server_config)
  server_config = server_config or {}
  local enabled = server_config.enabled ~= false
  vim.lsp.config(server, server_config)

  if server ~= "*" then
    vim.lsp.enable(server, enabled)
  end
end

---@param on_attach fun(client: vim.lsp.Client, buffer: number)
---@param name? string
function U.lsp.on_attach(on_attach, name)
  if name == "*" then
    name = nil
  end
  return vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_attach,
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and (not name or client.name == name) then
        return on_attach(client, buffer)
      end
    end,
  })
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
