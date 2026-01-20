return {
	"christoomey/vim-tmux-navigator",
	event = "VeryLazy",
	init = function()
		-- Disable plugin's default mappings - we'll create our own
		vim.g.tmux_navigator_no_mappings = 1
	end,
	config = function()
		-- Normal mode: use TmuxNavigate commands (handles vim splits + tmux panes)
		vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { silent = true })
		vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { silent = true })
		vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { silent = true })
		vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { silent = true })
		vim.keymap.set("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", { silent = true })

		-- Terminal mode: exit terminal mode, then navigate
		-- Uses <C-\><C-n> to exit, then runs TmuxNavigate (handles both vim splits + tmux panes)
		vim.keymap.set("t", "<C-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<cr>", { silent = true })
		vim.keymap.set("t", "<C-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<cr>", { silent = true })
		vim.keymap.set("t", "<C-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<cr>", { silent = true })
		vim.keymap.set("t", "<C-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<cr>", { silent = true })
	end,
}
