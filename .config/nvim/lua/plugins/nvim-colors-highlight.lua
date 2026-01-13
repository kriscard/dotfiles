return {
	{
		"NvChad/nvim-colorizer.lua",
		event = "BufReadPost",
		opts = {
			user_default_options = {
				tailwind = true,
			},
		},
	},
	{
		"brenoprata10/nvim-highlight-colors",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			---Render style
			---@usage 'background'|'foreground'|'virtual'
			render = "background",

			---Highlight hex colors, e.g. '#FFFFFF'
			enable_hex = true,

			---Highlight short hex colors e.g. '#fff'
			enable_short_hex = true,

			---Highlight rgb colors, e.g. 'rgb(0 0 0)'
			enable_rgb = true,

			---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
			enable_hsl = true,

			---Highlight CSS variables, e.g. 'var(--testing-color)'
			enable_var_usage = true,

			---Highlight named colors, e.g. 'green'
			enable_named_colors = true,

			---Highlight tailwind colors, e.g. 'bg-blue-500'
			enable_tailwind = true,
		},
	},
	-- TailwindCSS
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
		},
		opts = function()
			require("cmp").config.formatting = {
				format = require("tailwindcss-colorizer-cmp").formatter,
			}
			-- -- original LazyVim kind icon formatter
			-- local format_kinds = opts.formatting.format
			-- opts.formatting.format = function(entry, item)
			-- 	format_kinds(entry, item) -- add icons
			-- 	return require("tailwindcss-colorizer-cmp").formatter(entry, item)
			-- end
		end,
	},
}
