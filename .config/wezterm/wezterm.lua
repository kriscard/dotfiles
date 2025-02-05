local wezterm = require("wezterm")

local config = wezterm.config_builder()

local act = wezterm.action

local colors = {
	base = "#faf4ed",
	surface = "#fffaf3",
	overlay = "#f2e9e1",
	muted = "#9893a5",
	subtle = "#797593",
	text = "#575279",
	love = "#b4637a",
	gold = "#ea9d34",
	rose = "#d7827e",
	pine = "#286983",
	foam = "#56949f",
	iris = "#907aa9",
	highlight_low = "#f4ede8",
	highlight_med = "#dfdad9",
	highlight_high = "#cecacd",
}

config.term = "xterm-256color"

config.font = wezterm.font("MonoLisa")
config.font_size = 14.0

config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.show_new_tab_button_in_tab_bar = false

config.underline_position = -7
config.window_padding = {
	bottom = 0,
	top = 4,
}

local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Macchiato"
	else
		return "Catppuccin Latte"
	end
end

config.color_scheme = scheme_for_appearance(get_appearance())

config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.font = wezterm.font("MonoLisa", { weight = "Medium" })
config.font_size = 13
config.line_height = 1.26
config.command_palette_font_size = 16
config.command_palette_fg_color = colors.text
config.command_palette_bg_color = colors.highlight_high
config.harfbuzz_features = { "calt", "dlig", "ss01", "ss02", "ss03", "ss06", "ss07", "ss08", "ss10", "ss15", "ss16" }
config.inactive_pane_hsb = {
	saturation = 1,
	brightness = 0.9,
}

config.mouse_bindings = {
	{
		-- Ctrl-click will open the link under the mouse cursor
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = act.OpenLinkAtMouseCursor,
	},

	-- {
	-- 	event = { Up = { streak = 1, button = "Left" } },
	-- 	mods = "NONE",
	-- 	action = act.CompleteSelection("PrimarySelection"),
	-- },
}

return config
