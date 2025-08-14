local U = require("config.util")

local M = {}

---@type LazyKeysLspSpec[]
local _keys = {}

---@class CustomLazyKeysLspFields
---@field has? vim.lsp.protocol.Method.ClientToServer|vim.lsp.protocol.Method.ClientToServer[]
---@field cond? boolean|fun():boolean

---@class LazyKeysLspSpec : LazyKeysSpec, CustomLazyKeysLspFields

---@class LazyKeysLsp : LazyKeys, CustomLazyKeysLspFields

---@param buffer integer
---@param method vim.lsp.protocol.Method.ClientToServer|vim.lsp.protocol.Method.ClientToServer[]
local function supports_method(buffer, method)
  if type(method) == "table" then
    for _, m in ipairs(method) do
      if supports_method(buffer, m) then
        return true
      end
    end
    return false
  end
  local clients = vim.lsp.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    if client:supports_method(method) then
      return true
    end
  end
  return false
end

---@return LazyKeysLsp[]
local function resolve_keymaps(buffer)
  local Keys = require("lazy.core.handler.keys")
  if not Keys.resolve then
    return {}
  end
  local spec = vim.tbl_extend("force", {}, _keys)
  local opts = U.opts("nvim-lspconfig")
  local clients = vim.lsp.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
    vim.list_extend(spec, maps)
  end
  return Keys.resolve(spec)
end

function M.on_attach(_, buffer)
  local Keys = require("lazy.core.handler.keys")
  local keymaps = resolve_keymaps(buffer)

  for _, keys in pairs(keymaps) do
    local has = not keys.has or supports_method(buffer, keys.has)
    local cond = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))

    if has and cond then
      local opts = Keys.opts(keys)
      ---@diagnostic disable-next-line: inject-field
      opts.cond = nil
      ---@diagnostic disable-next-line: inject-field
      opts.has = nil
      ---@cast opts vim.keymap.set.Opts
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
    end
  end
end

---@param spec LazyKeysLspSpec[]
function M.add(spec)
  vim.list_extend(_keys, spec)
end

return M
