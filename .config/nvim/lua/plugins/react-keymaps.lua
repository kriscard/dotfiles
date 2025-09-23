-- React-specific keymaps and utilities
return {
	{
		"folke/which-key.nvim",
		opts = function(_, opts)
			opts.spec = opts.spec or {}
			opts.spec[#opts.spec + 1] = {
				{ "<leader>r", group = "React" },
				{ "<leader>rf", desc = "Refactor", mode = "n" },
				{ "<leader>ri", desc = "Add missing import", mode = "n" },
			}
		end,
		keys = {
			{
				"<leader>ri",
				function()
					vim.lsp.buf.code_action({
						filter = function(action)
							return string.match(action.title, "Add import") or
							       string.match(action.title, "Import") or
							       string.match(action.title, "Update import")
						end,
						apply = true,
					})
				end,
				desc = "Add missing import",
				mode = "n",
			},
		},
	},
}