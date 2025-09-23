return {
	-- React component extraction
	{
		"napmn/react-extract.nvim",
		enabled = false, -- Temporarily disabled for debugging
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		keys = {
			{
				"<leader>re",
				function()
					require("react-extract").extract_to_new_file()
				end,
				mode = { "v" },
				desc = "Extract component to new file",
			},
			{
				"<leader>rc",
				function()
					require("react-extract").extract_to_current_file()
				end,
				mode = { "v" },
				desc = "Extract component to current file",
			},
		},
		config = function()
			require("react-extract").setup({
				ts_type_generation = true,
			})
		end,
	},

	-- Enhanced JSX/React development
	{
		"neoclide/vim-jsx-improve",
		enabled = false, -- Temporarily disabled for debugging
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},

	-- React hooks snippets and utilities
	{
		"mattn/emmet-vim",
		ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
		config = function()
			vim.g.user_emmet_settings = {
				javascript = {
					extends = "jsx",
				},
				typescript = {
					extends = "tsx",
				},
			}
			vim.g.user_emmet_leader_key = "<C-z>"
		end,
	},

	-- Better React component folding
	{
		"yaegassy/coc-react-refactor",
		enabled = false, -- Disabled for now, requires coc.nvim
	},
}