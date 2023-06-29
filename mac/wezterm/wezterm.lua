local wezterm = require("wezterm")

local config = {
	color_scheme = 'Gruvbox dark, hard (base16)',
	window_background_opacity = 0.90,
	enable_tab_bar = false,
	colors = {
		-- The default text color
		foreground = 'silver',
		-- The default background color
		background = '0f1216',
	},
	window_decorations = "RESIZE",
	font = wezterm.font("Inconsolata Nerd Font Mono", { weight = "Regular" }),
	font_size = 12,
	native_macos_fullscreen_mode = true,
	macos_window_background_blur = 20,
	keys = {
		{
			key = "n",
			mods = "SHIFT|CTRL",
			action = wezterm.action.ToggleFullScreen,
		},
		{
			key = 't',
			mods = 'CMD',
			action = wezterm.action.SpawnWindow,
		},
	},
	window_padding = {
		left = 10,
		right = 10,
		top = 7,
		bottom = 7,
	},
}

return config
