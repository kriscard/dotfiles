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
				review_thread = {
					-- Review management
					start_review = { lhs = "<leader>rs", desc = "start review" },
					resume_review = { lhs = "<leader>rr", desc = "resume review" },
					submit_review = { lhs = "<leader>rv", desc = "submit review" },
					discard_review = { lhs = "<leader>rd", desc = "discard review" },
					-- Comments
					add_comment = { lhs = "<leader>ca", desc = "add comment" },
					delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
					add_reply = { lhs = "<leader>cr", desc = "add reply" },
					-- Threads
					resolve_thread = { lhs = "<leader>rt", desc = "resolve thread" },
					unresolve_thread = { lhs = "<leader>rT", desc = "unresolve thread" },
					-- Navigation
					goto_next_comment = { lhs = "]c", desc = "next comment" },
					goto_previous_comment = { lhs = "[c", desc = "previous comment" },
					goto_next_thread = { lhs = "]t", desc = "next thread" },
					goto_previous_thread = { lhs = "[t", desc = "previous thread" },
					-- Panel control
					focus_files = { lhs = "<leader>e", desc = "focus files panel" },
					toggle_files = { lhs = "<leader>b", desc = "toggle files panel" },
					close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
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

		-- Which-key groups
		{ "<leader>p", "", desc = "+pr (Octo)" },
		{ "<leader>i", "", desc = "+issue (Octo)" },
		{ "<leader>r", "", desc = "+review (Octo)", ft = "octo" },

		-- Auto-complete in insert mode
		{ "@", "@<C-x><C-o>", mode = "i", ft = "octo", silent = true },
		{ "#", "#<C-x><C-o>", mode = "i", ft = "octo", silent = true },

		-- Image preview (uses Snacks.image with markdown treesitter)
		{ "<leader>pi", function() Snacks.image.hover() end, ft = "octo", desc = "Preview image" },
	},
}
