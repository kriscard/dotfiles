-- Search & Replace (grug-far replaces nvim-spectre which is in maintenance mode)
return {
	"MagicDuck/grug-far.nvim",
	cmd = "GrugFar",
	keys = {
		{
			"<leader>Sr",
			function()
				require("grug-far").open()
			end,
			desc = "Search & Replace",
		},
		{
			"<leader>Sw",
			function()
				require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
			end,
			desc = "Replace Current Word",
		},
		{
			"<leader>Sw",
			function()
				require("grug-far").with_visual_selection()
			end,
			mode = "v",
			desc = "Replace Selection",
		},
		{
			"<leader>Sf",
			function()
				require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
			end,
			desc = "Replace in Current File",
		},
	},
	opts = {
		headerMaxWidth = 80,
	},
}
