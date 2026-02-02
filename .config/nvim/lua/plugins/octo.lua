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
					checkout_pr = { lhs = "<leader>po", desc = "checkout PR" },
					merge_pr = { lhs = "<leader>pm", desc = "merge PR" },
					list_commits = { lhs = "<leader>pc", desc = "list commits" },
					list_changed_files = { lhs = "<leader>pf", desc = "list changed files" },
					show_pr_diff = { lhs = "<leader>pd", desc = "show diff" },
					add_reviewer = { lhs = "<leader>pr", desc = "add reviewer" },
					remove_reviewer = { lhs = "<leader>pR", desc = "remove reviewer" },
					close_issue = { lhs = "<leader>px", desc = "close PR" },
					reopen_issue = { lhs = "<leader>pX", desc = "reopen PR" },
					open_in_browser = { lhs = "<leader>pb", desc = "open in browser" },
					add_comment = { lhs = "<leader>ca", desc = "add comment" },
					review_start = { lhs = "<leader>rs", desc = "start review" },
					review_resume = { lhs = "<leader>rr", desc = "resume review" },
				},
				review_diff = {
					select_next_entry = { lhs = "<C-j>", desc = "next file" },
					select_prev_entry = { lhs = "<C-k>", desc = "previous file" },
					add_review_comment = { lhs = "<leader>ca", desc = "add comment" },
					add_review_suggestion = { lhs = "<leader>cs", desc = "add suggestion" },
					focus_files = { lhs = "<leader>e", desc = "focus files" },
					toggle_files = { lhs = "<leader>b", desc = "toggle files" },
					submit_review = { lhs = "<leader>rv", desc = "submit review" },
					discard_review = { lhs = "<leader>rd", desc = "discard review" },
					next_thread = { lhs = "]t", desc = "next thread" },
					prev_thread = { lhs = "[t", desc = "previous thread" },
				},
				review_thread = {
					add_comment = { lhs = "<leader>ca", desc = "add comment" },
					delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
					add_reply = { lhs = "<leader>cr", desc = "add reply" },
					add_suggestion = { lhs = "<leader>cs", desc = "add suggestion" },
					resolve_thread = { lhs = "<leader>rt", desc = "resolve thread" },
					unresolve_thread = { lhs = "<leader>rT", desc = "unresolve thread" },
					next_comment = { lhs = "]c", desc = "next comment" },
					prev_comment = { lhs = "[c", desc = "previous comment" },
					select_next_entry = { lhs = "]q", desc = "next file" },
					select_prev_entry = { lhs = "[q", desc = "previous file" },
					close_review_tab = { lhs = "<C-c>", desc = "close tab" },
				},
			},
		})
		vim.treesitter.language.register("markdown", "octo")
	end,
	keys = {
		-- Global keybindings (work anywhere)
		{ "<leader>pl", "<cmd>Octo pr list<CR>", desc = "List PRs" },
		{ "<leader>ps", "<cmd>Octo pr search<CR>", desc = "Search PRs" },
		{ "<leader>pe", "<cmd>Octo pr edit<CR>", desc = "Open current branch PR" },
		{ "<leader>il", "<cmd>Octo issue list<CR>", desc = "List Issues" },
		{ "<leader>is", "<cmd>Octo issue search<CR>", desc = "Search Issues" },

		-- Review workflow (works from any buffer)
		{ "<leader>rs", "<cmd>Octo review start<CR>", desc = "Start review" },
		{ "<leader>rr", "<cmd>Octo review resume<CR>", desc = "Resume review" },
		{ "<leader>rv", "<cmd>Octo review submit<CR>", desc = "Submit review (prompt)" },
		{ "<leader>rd", "<cmd>Octo review discard<CR>", desc = "Discard review" },
		-- Review submission actions
		{ "<leader>ra", "<cmd>Octo review submit approve<CR>", desc = "Approve PR" },
		{ "<leader>rc", "<cmd>Octo review submit comment<CR>", desc = "Comment only" },
		{ "<leader>rx", "<cmd>Octo review submit request_changes<CR>", desc = "Request changes" },

		-- Comment actions (works from any buffer)
		{ "<leader>ca", "<cmd>Octo comment add<CR>", desc = "Add comment" },
		{ "<leader>cd", "<cmd>Octo comment delete<CR>", desc = "Delete comment" },

		-- PR actions (works from any buffer)
		{ "<leader>pm", "<cmd>Octo pr merge squash<CR>", desc = "Merge (squash)" },
		{ "<leader>px", "<cmd>Octo pr close<CR>", desc = "Close PR" },
		{ "<leader>pb", "<cmd>Octo pr browser<CR>", desc = "Open in browser" },

		-- Which-key groups
		{ "<leader>p", "", desc = "+pr (Octo)" },
		{ "<leader>i", "", desc = "+issue (Octo)" },
		{ "<leader>r", "", desc = "+review (Octo)" },
		{ "<leader>c", "", desc = "+comment (Octo)" },

		-- Auto-complete in insert mode
		{ "@", "@<C-x><C-o>", mode = "i", ft = "octo", silent = true },
		{ "#", "#<C-x><C-o>", mode = "i", ft = "octo", silent = true },

		-- Image preview (uses Snacks.image with markdown treesitter)
		{ "<leader>pi", function() require("snacks").image.hover() end, ft = "octo", desc = "Preview image" },
	},
}
