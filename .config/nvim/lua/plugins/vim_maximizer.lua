return {
	"szw/vim-maximizer",
	cmd = "MaximizerToggle",
	keys = {
		{ "<leader>m", "<cmd>MaximizerToggle!<CR>", desc = "Toggle Maximizer" },
	},
	init = function()
		vim.g.maximizer_set_default_mapping = 0
	end,
}
