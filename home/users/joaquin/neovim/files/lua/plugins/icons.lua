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

return {
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = { lsp = mini_icons_lsp_override },
  },
}
