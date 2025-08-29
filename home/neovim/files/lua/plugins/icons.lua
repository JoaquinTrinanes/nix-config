local kind_icons = {
  array = " ",
  boolean = "󰨙 ",
  class = " ",
  codeium = "󰘦 ",
  color = " ",
  control = " ",
  collapsed = " ",
  constant = "󰏿 ",
  constructor = " ",
  copilot = " ",
  enum = " ",
  enummember = " ",
  event = " ",
  field = " ",
  file = " ",
  folder = " ",
  ["function"] = "󰊕 ",
  interface = " ",
  key = " ",
  keyword = " ",
  method = "󰊕 ",
  module = " ",
  namespace = "󰦮 ",
  null = " ",
  number = "󰎠 ",
  object = " ",
  operator = " ",
  package = " ",
  property = " ",
  reference = " ",
  snippet = "󱄽 ",
  string = " ",
  struct = "󰆼 ",
  supermaven = " ",
  tabnine = "󰏚 ",
  text = " ",
  typeparameter = " ",
  unit = " ",
  value = " ",
  variable = "󰀫 ",
}

local mini_icons_lsp_override = {}

for kind, icon in pairs(kind_icons) do
  mini_icons_lsp_override[kind] = { glyph = icon }
end

---@type LazyPluginSpec[]
return {
  {
    "nvim-mini/mini.icons",
    opts = {
      style = vim.o.termguicolors and "glyph" or "ascii",
      lsp = mini_icons_lsp_override,
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
