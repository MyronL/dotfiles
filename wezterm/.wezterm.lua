-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "tokyonight_night"
config.font = wezterm.font("MesloLGS Nerd Font Mono", { weight = "Medium" })
config.font_size = 16
config.line_height = 1.1

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.native_macos_fullscreen_mode = true

config.window_close_confirmation = "NeverPrompt"

config.default_cursor_style = "SteadyBar"

config.window_padding = {
	left = 10,
	right = 5,
	top = 5,
	bottom = 0,
}

config.window_frame = {
	border_top_height = "0.25cell",
}

return config
