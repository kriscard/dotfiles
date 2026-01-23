return {
	"pwntester/octo.nvim",
	cmd = "Octo",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/snacks.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("octo").setup({
			enable_builtin = true,
			default_merge_method = "squash",
			picker = "snacks",
			file_panel = { use_icons = true },
			mappings = {
				pull_request = {
					approve_pr = { lhs = "<leader>pa", desc = "approve PR" },
				},
				review_diff = {
					select_next_entry = { lhs = "<C-j>", desc = "move to next changed file" },
					select_prev_entry = { lhs = "<C-k>", desc = "move to previous changed file" },
					add_review_comment = { lhs = "<leader>ca", desc = "add review comment", mode = { "n", "x" } },
					add_review_suggestion = { lhs = "<leader>sa", desc = "add suggestion", mode = { "n", "x" } },
					submit_review = { lhs = "<leader>rs", desc = "submit review" },
					discard_review = { lhs = "<leader>rd", desc = "discard review" },
					focus_files = { lhs = "<leader>e", desc = "focus file panel" },
					toggle_files = { lhs = "<leader>b", desc = "toggle file panel" },
				},
			},
		})
		vim.treesitter.language.register("markdown", "octo")
	end,
	keys = {
		-- Global keybindings (work anywhere)
		{ "<leader>pl", "<cmd>Octo pr list<CR>", desc = "List PRs" },
		{ "<leader>ps", "<cmd>Octo pr search<CR>", desc = "Search PRs" },
		{ "<leader>il", "<cmd>Octo issue list<CR>", desc = "List Issues" },
		{ "<leader>is", "<cmd>Octo issue search<CR>", desc = "Search Issues" },

		-- PR actions (in octo buffer)
		{ "<leader>po", "<cmd>Octo pr checkout<CR>", desc = "Checkout PR", ft = "octo" },
		{ "<leader>pd", "<cmd>Octo pr diff<CR>", desc = "View diff", ft = "octo" },
		{ "<leader>pf", "<cmd>Octo pr changes<CR>", desc = "View changed files", ft = "octo" },
		{ "<leader>pm", "<cmd>Octo pr merge squash<CR>", desc = "Merge (squash)", ft = "octo" },
		{ "<leader>px", "<cmd>Octo pr close<CR>", desc = "Close PR", ft = "octo" },
		{ "<leader>pb", "<cmd>Octo pr browser<CR>", desc = "Open in browser", ft = "octo" },

		-- Comments
		{ "<leader>ca", "<cmd>Octo comment add<CR>", desc = "Add comment", ft = "octo" },
		{ "<leader>cd", "<cmd>Octo comment delete<CR>", desc = "Delete comment", ft = "octo" },

		-- Review workflow
		{ "<leader>rs", "<cmd>Octo review start<CR>", desc = "Start review", ft = "octo" },
		{ "<leader>rr", "<cmd>Octo review resume<CR>", desc = "Resume review", ft = "octo" },
		{ "<leader>rd", "<cmd>Octo review discard<CR>", desc = "Discard review", ft = "octo" },
		{ "<leader>ra", "<cmd>Octo review submit approve<CR>", desc = "Approve", ft = "octo" },
		{ "<leader>rc", "<cmd>Octo review submit comment<CR>", desc = "Comment only", ft = "octo" },
		{ "<leader>rx", "<cmd>Octo review submit request_changes<CR>", desc = "Request changes", ft = "octo" },

		-- Which-key groups
		{ "<leader>p", "", desc = "+pr (Octo)", ft = "octo" },
		{ "<leader>c", "", desc = "+comment (Octo)", ft = "octo" },
		{ "<leader>r", "", desc = "+review (Octo)", ft = "octo" },
		{ "<leader>i", "", desc = "+issue (Octo)", ft = "octo" },

		-- Auto-complete in insert mode
		{ "@", "@<C-x><C-o>", mode = "i", ft = "octo", silent = true },
		{ "#", "#<C-x><C-o>", mode = "i", ft = "octo", silent = true },
	},
}
