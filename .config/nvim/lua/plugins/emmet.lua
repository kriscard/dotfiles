-- Emmet for HTML/JSX/Vue/Svelte abbreviation expansion
return {
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
}
