-- Filetype detection for MDX (must run before plugins)
vim.filetype.add({
	extension = {
		mdx = "mdx",
	},
})

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		ft = { "markdown", "vimwiki", "norg", "rmd", "org", "Avante", "mdx" },
		opts = {
			file_types = { "markdown", "vimwiki", "norg", "rmd", "org", "Avante", "mdx" },
			code = {
				width = "block",
				right_pad = 1,
			},
		},
	},
	{
		"davidmh/mdx.nvim",
		event = "BufEnter *.mdx",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = true,
	},
}
