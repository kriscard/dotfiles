return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	version = "*",
	opts = {
		options = {
			buffer_close_icon = "",
			close_icon = "",
			offsets = {
				{
					filetype = "NvimTree",
					text = "Nvim tree",
					highlight = "FileExplorer",
				},
			},
			separator_style = "slant",
		},
	},
}
