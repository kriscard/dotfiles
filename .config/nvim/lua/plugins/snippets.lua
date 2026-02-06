-- ══════════════════════════════════════════════════════════════════════════════
-- Snippets (LuaSnip + friendly-snippets)
-- ══════════════════════════════════════════════════════════════════════════════
return {
	"L3MON4D3/LuaSnip",
	lazy = true,
	dependencies = {
		{
			"rafamadriz/friendly-snippets",
			config = function()
				-- Load friendly-snippets but exclude filetypes we want to override
				require("luasnip.loaders.from_vscode").lazy_load({
					exclude = { "typescriptreact", "typescript", "javascript", "javascriptreact" },
				})

				-- Load only custom snippets for the filetypes we want to override
				require("luasnip.loaders.from_vscode").lazy_load({
					paths = { vim.fn.stdpath("config") .. "/snippets" },
				})

				-- For any remaining conflicts, we can clear and reload specific filetypes
				vim.api.nvim_create_autocmd("FileType", {
					pattern = { "typescriptreact", "typescript", "javascript", "javascriptreact" },
					callback = function()
						-- Ensure custom snippets take priority by reloading them
						require("luasnip.loaders.from_vscode").lazy_load({
							paths = { vim.fn.stdpath("config") .. "/snippets" },
						})
					end,
				})
			end,
		},
	},
	opts = {
		history = true,
		delete_check_events = "TextChanged",
	},
}
