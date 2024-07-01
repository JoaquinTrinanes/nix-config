local M = {}

---@param pane Pane
M.get_process_name = function(pane)
	return string.gsub(pane:get_foreground_process_name(), "(.*[/\\])(.*)", "%2")
end

---@param process string
---@param pane Pane
M.has_foreground_process = function(process, pane)
	return M.get_process_name(pane) == process
end

return M
