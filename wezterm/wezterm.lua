local wezterm = require("wezterm")
config = wezterm.config_builder()

config.automatically_reload_config = true
config.adjust_window_size_when_changing_font_size = false
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.color_scheme = "Catppuccin Macchiato"
-- config.font = "JetBrainsMono Nerd Font"
config.font_size = 19
config.font = wezterm.font_with_fallback({
	{
		family = "JetBrainsMono Nerd Font",
		weight = "Medium",
		harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
	},
	{ family = "Terminus", weight = "Bold" },
	"Noto Color Emoji",
})
config.bold_brightens_ansi_colors = false

config.window_background_opacity = 0.85
config.macos_window_background_blur = 13

local enable_background = true
-- local enable_background = false
if enable_background then
	config.background = {
		{
			source = {
				File = "path/to/your/pnj-or-jpg/file",
			},
			opacity = 0.30,
			height = "100%",
			width = "105%",
		},
		{
			source = {
				Color = "#23273C",
			},
			width = "100%",
			height = "100%",
			opacity = 0.75,
		},
	}
end

-- Définir CTRL+A comme touche "Leader" (comme dans tmux)
config.leader = { key = "<", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- Diviser verticalement avec Leader + v
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	-- Diviser horizontalement avec Leader + h
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	-- Zoomer/Agrandir le volet actuel avec Leader + z
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},
}

return config
