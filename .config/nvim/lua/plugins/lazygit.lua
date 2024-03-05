return {
	"kdheepak/lazygit.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("lazy").setup({
			{
				"kdheepak/lazygit.nvim",
				cmd = {
					"LazyGit",
					"LazyGitConfig",
					"LazyGitCurrentFile",
					"LazyGitFilter",
					"LazyGitFilterCurrentFile",
				},
				-- optional for floating window border decoration
			},
		})
	end,
}
