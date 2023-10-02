return {
	"lukas-reineke/indent-blankline.nvim",
	event = "VeryLazy",
	main = "ibl",
	show_start = false,
	show_end = false,
	opts = {
		indent = { char = "▏" },
		exclude = {
			filetypes = {
				"help",
				"markdown",
				"alpha",
				"sagahover",
				"NvimTree",
				"mason",
				"toggleterm",
				"lazy",
				"noice",
			},
			buftypes = { "fzf", "help", "terminal", "nofile" },
		},
	},
}
