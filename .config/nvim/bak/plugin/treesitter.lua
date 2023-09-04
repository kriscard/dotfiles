local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
	return
end

local instance, treesitterContext = pcall(require, "treesitter-context")
if not instance then
	return
end

local ft_to_parser = require("nvim-treesitter.parsers").filetype_to_parsername
ft_to_parser.mdx = "markdown"

treesitter.setup({
	highlight = {
		enable = true,
		disable = {},
	},
	indent = {
		enable = true,
		disable = {},
	},
	ensure_installed = {
		"markdown",
		"markdown_inline",
		"tsx",
		"typescript",
		"toml",
		"json",
		"yaml",
		"css",
		"html",
		"lua",
		"yaml",
		"graphql",
		"vim",
		"javascript",
	},
	autotag = {
		enable = true,
	},
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
})

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }

treesitterContext.setup({
	enable = true,
})
