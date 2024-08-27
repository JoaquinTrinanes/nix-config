---@diagnostic disable: inject-field

local wezterm = require("wezterm")

-- wezterm.add_to_config_reload_watch_list(wezterm.config_dir)
---@param key string
---@param mods "ALT" | "CTRL" | "SHIFT" | "CTRL|SHIFT" | nil
---@param action fun()
---@param get_should_execute fun(win: Window, pane: Pane): boolean
---@param default KeyAssignment?
local conditional_map = function(key, mods, action, get_should_execute, default)
	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(win, pane)
			if get_should_execute(win, pane) then
				win:perform_action(action, pane)
			else
				win:perform_action(default or wezterm.action.DisableDefaultAssignment, pane)
				-- win:perform_action(wezterm.action.SendKey({ key = key, mods = mods }), pane)
			end
		end),
	}
end

---@param pane Pane
local get_process_name = function(pane)
	local process_name = pane:get_foreground_process_name()
	if process_name == nil then
		return nil
	end
	return string.gsub(process_name, "(.*[/\\])(.*)", "%2")
end

---@param process string
---@param pane Pane
local has_foreground_process = function(process, pane)
	return get_process_name(pane) == process
end

local direction_keys = {
	Left = "h",
	Down = "j",
	Up = "k",
	Right = "l",
	-- reverse lookup
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

---@param pane Pane
local has_mux = function(pane)
	local is_zellij = has_foreground_process("zellij", pane)
	local is_tmux = has_foreground_process("tmux", pane)

	-- this is set by the smart-splits.nvim plugin, and unset on ExitPre in Neovim
	local is_vim = pane:get_user_vars().IS_NVIM == "true"

	return is_vim or is_tmux or is_zellij
end

---@param resize_or_move "resize" | "move"
---@param key string
local function split_nav(resize_or_move, key)
	local mods = resize_or_move == "resize" and "ALT" or "CTRL"
	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(win, pane)
			if has_mux(pane) then
				-- pass the keys through
				win:perform_action({
					SendKey = {
						key = key,
						-- zellij doesn't support Ctrl+j, so we override with Alt
						mods = has_foreground_process("zellij", pane) and "ALT" or mods,
					},
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

local zellij_only_map = function(key, mods, action, default)
	return conditional_map(key, mods, action, function(_, pane)
		return has_foreground_process("zellij", pane)
	end, default)
end

-- wezterm.add_to_config_reload_watch_list(wezterm.config_dir .. "/colors/flavours.toml")

---@type Config
local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.check_for_updates = false

config.term = "wezterm"

config.front_end = "OpenGL"
if os.getenv("VK_ICD_FILENAMES") then
	config.front_end = "WebGpu"
end

-- if enabled and on WebGpu, fails with 'Failed to create window: no compatible adapter found' error
config.webgpu_force_fallback_adapter = false

config.webgpu_power_preference = "LowPower"

-- fixes crashing when using fractional scaling
config.adjust_window_size_when_changing_font_size = true

-- start maximized
wezterm.on("gui-startup", function()
	local _, _, window = wezterm.mux.spawn_window({})
	window:gui_window():maximize()
end)

config.enable_wayland = os.getenv("XDG_SESSION_TYPE") == "wayland"

config.color_scheme = "base16"
config.font = wezterm.font_with_fallback({
	{ family = "FiraCode Nerd Font", harfbuzz_features = { "ss05" } },
	"DejaVu Sans Mono",
	{ family = "JoyPixels", assume_emoji_presentation = true },
	"Noto Sans Mono CJK HK",
	"Noto Sans Mono CJK JP",
	"Noto Sans Mono CJK SC",
	"Noto Sans Mono CJK TC",
	{ family = "Symbols Nerd Font Mono", assume_emoji_presentation = true },
	"unscii-16-full",
})

-- test
-- config.font_rules = {
-- 	{
-- 		intensity = "Bold",
-- 		italic = true,
-- 		font = wezterm.font({
-- 			family = "VictorMono Nerd Font",
-- 			weight = "Bold",
-- 			style = "Italic",
-- 		}),
-- 	},
-- 	{
-- 		italic = true,
-- 		intensity = "Half",
-- 		font = wezterm.font({
-- 			family = "VictorMono Nerd Font",
-- 			weight = "DemiBold",
-- 			style = "Italic",
-- 		}),
-- 	},
-- 	{
-- 		italic = true,
-- 		intensity = "Normal",
-- 		font = wezterm.font({
-- 			family = "VictorMono Nerd Font",
-- 			style = "Italic",
-- 		}),
-- 	},
-- }

config.tab_max_width = 999999

-- config.window_decorations = "INTEGRATED_BUTTONS | RESIZE | TITLE"
-- config.window_decorations = "RESIZE|TITLE"
config.hide_tab_bar_if_only_one_tab = false -- true
config.use_fancy_tab_bar = false

config.font_size = 16
---@diagnostic disable-next-line: assign-type-mismatch
config.default_cursor_style = "SteadyBar"
config.cursor_blink_rate = 0
config.enable_scroll_bar = true
---@diagnostic disable-next-line: assign-type-mismatch
config.audible_bell = "Disabled"
config.unicode_version = 15
config.hide_mouse_cursor_when_typing = false
config.enable_kitty_keyboard = true

config.keys = {
	zellij_only_map(
		"c",
		"CTRL|SHIFT",
		wezterm.action.SendKey({ key = "c", mods = "ALT" }),
		wezterm.action.CopyTo("Clipboard")
	),
	-- mux.zellij_map("t", "ALT", wezterm.action.DisableDefaultAssignment),
	{
		key = "\\",
		mods = "CTRL|ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "|",
		mods = "CTRL|ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "CTRL|ALT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "f",
		mods = "ALT",
		action = wezterm.action.TogglePaneZoomState,
	},
	{
		key = "l",
		mods = "CTRL|ALT",
		action = wezterm.action.RotatePanes("Clockwise"),
	},
	{
		key = "h",
		mods = "CTRL|ALT",
		action = wezterm.action.RotatePanes("CounterClockwise"),
	},
	{ key = "p", mods = "CTRL|SHIFT", action = wezterm.action.ActivateCommandPalette },
	{ key = "s", mods = "ALT", action = wezterm.action.CharSelect({ copy_on_select = true }) },

	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),

	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
}

-- local ok, smart_splits = pcall(wezterm.plugin.require, "https://github.com/mrjones2014/smart-splits.nvim")
-- if ok then
-- 	smart_splits.apply_to_config(config, {
-- 		-- directional keys to use in order of: left, down, up, right
-- 		direction_keys = { "h", "j", "k", "l" },
-- 		-- modifier keys to combine with direction_keys
-- 		modifiers = {
-- 			move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
-- 			resize = "ALT", -- modifier to use for pane resize, e.g. META+h to resize to the left
-- 		},
-- 	})
-- end

return config
