local U = require("config.util")

---@type boolean?
local session_enabled_user_override = nil

local function should_enable_persistence()
  if session_enabled_user_override ~= nil then
    return session_enabled_user_override
  end

  local cwd = vim.fn.getcwd()

  if vim.o.diff or vim.fn.has("headless") == 1 then
    return false
  end

  if not cwd or cwd == "/" then
    return false
  end

  cwd = cwd:match("(.+)/?$") or cwd

  -- Denylist specific base paths
  local denylist = { "/tmp" }
  for _, denied in ipairs(denylist) do
    if cwd == denied or cwd:find("^" .. denied .. "/") then
      return false
    end
  end

  -- Disable if any part of the path is a hidden dir
  for segment in cwd:gmatch("[^/\\]+") do
    if vim.startswith(segment, ".") then
      return false
    end
  end

  -- Disable if all buffers are outside cwd
  local loaded_bufs = vim.tbl_filter(function(buffer)
    return vim.bo[buffer].buflisted and vim.bo[buffer].buftype == ""
  end, vim.api.nvim_list_bufs())
  if #loaded_bufs == 0 then
    return true
  end

  for _, buf in ipairs(loaded_bufs) do
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname ~= "" and U.is_subpath(cwd, bufname) then
      return true
    end
  end

  return false
end

local function update_session_state()
  local persistence = require("persistence")
  if should_enable_persistence() then
    persistence.start()
  else
    persistence.stop()
  end
end

local persistence_group = U.augroup("persistence_setup")

return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { branch = false },
    config = function(_, opts)
      local persistence = require("persistence")
      persistence.setup(opts)

      vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged", "BufReadPost", "BufDelete" }, {
        group = persistence_group,
        callback = function()
          -- schedule is needed to run the callback after buffers are actually deleted
          vim.schedule(update_session_state)
        end,
      })

      Snacks.toggle({
        name = "Persistence Session",
        get = function()
          if session_enabled_user_override ~= nil then
            return session_enabled_user_override
          end
          return persistence.active()
        end,

        set = function(enabled)
          session_enabled_user_override = enabled
          update_session_state()
        end,
      }):map("<leader>uS")
    end,
  },
}
