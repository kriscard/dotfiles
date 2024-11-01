return {
	"pwntester/octo.nvim",
	cmd = "Octo",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		enable_builtin = true,
		default_merge_method = "squash",
		picker = "telescope",
	},
	config = function()
		require("octo").setup({
			enable_builtin = true,
			file_panel = { use_icons = true },
			mappings = {
				review_diff = {
					select_next_entry = { lhs = "<C-j>", desc = "move to previous changed file" },
					select_prev_entry = { lhs = "<C-k>", desc = "move to next changed file" },
				},
			},
		})
		vim.treesitter.language.register("markdown", "octo")
	end,
	keys = {
		{ "<leader>gi", "<cmd>Octo issue list<CR>", desc = "List Issues (Octo)" },
		{ "<leader>gI", "<cmd>Octo issue search<CR>", desc = "Search Issues (Octo)" },
		{ "<leader>gp", "<cmd>Octo pr list<CR>", desc = "List PRs (Octo)" },
		{ "<leader>gP", "<cmd>Octo pr search<CR>", desc = "Search PRs (Octo)" },
		{ "<leader>gr", "<cmd>Octo repo list<CR>", desc = "List Repos (Octo)" },
		{ "<leader>gS", "<cmd>Octo search<CR>", desc = "Search (Octo)" },

		{ "<leader>a", "", desc = "+assignee (Octo)", ft = "octo" },
		{ "<leader>c", "", desc = "+comment/code (Octo)", ft = "octo" },
		{ "<leader>l", "", desc = "+label (Octo)", ft = "octo" },
		{ "<leader>i", "", desc = "+issue (Octo)", ft = "octo" },
		{ "<leader>r", "", desc = "+react (Octo)", ft = "octo" },
		{ "<leader>p", "", desc = "+pr (Octo)", ft = "octo" },
		{ "<leader>v", "", desc = "+review (Octo)", ft = "octo" },
		{ "@", "@<C-x><C-o>", mode = "i", ft = "octo", silent = true },
		{ "#", "#<C-x><C-o>", mode = "i", ft = "octo", silent = true },
	},
}
