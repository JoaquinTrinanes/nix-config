---@type Wezterm
local wezterm = require("wezterm")

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
						mods = mods,
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

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.check_for_updates = false

local mux = wezterm.mux
wezterm.on("gui-attached", function(domain)
	-- maximize all displayed windows on startup
	local workspace = mux.get_active_workspace()
	for _, window in ipairs(mux.all_windows()) do
		if window:get_workspace() == workspace then
			window:gui_window():maximize()
		end
	end
end)

config.font_size = 14
config.term = "wezterm"

config.enable_wayland = os.getenv("XDG_SESSION_TYPE") == "wayland"

config.color_scheme = "base16"
config.font = wezterm.font_with_fallback({
	{ family = "FiraCode Nerd Font", harfbuzz_features = { "ss05" } },
	{ family = "Maple Mono", harfbuzz_features = { "cv01", "cv02", "cv03", "ss01", "ss04", "ss05" } },
	"DejaVu Sans Mono",
	{ family = "JoyPixels", assume_emoji_presentation = true },
	"Noto Sans Mono CJK HK",
	"Noto Sans Mono CJK JP",
	"Noto Sans Mono CJK SC",
	"Noto Sans Mono CJK TC",
	{ family = "Symbols Nerd Font Mono", assume_emoji_presentation = true },
	"unscii-16-full",
})

config.tab_max_width = 999999

---@diagnostic disable-next-line: assign-type-mismatch
config.default_cursor_style = "SteadyBar"
config.cursor_blink_rate = 0
config.enable_scroll_bar = true
---@diagnostic disable-next-line: assign-type-mismatch
config.audible_bell = "Disabled"
config.unicode_version = 14
config.hide_mouse_cursor_when_typing = false
config.enable_kitty_keyboard = true

config.scrollback_lines = 50000

config.keys = {
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

config.mouse_bindings = {
	{
		event = { Down = { streak = 4, button = "Left" } },
		action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
		mods = "NONE",
	},
	{
		event = { Up = { streak = 4, button = "Left" } },
		action = wezterm.action.Nop,
		mods = "NONE",
	},
}

return config
