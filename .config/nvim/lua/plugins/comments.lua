-- Use Neovim 0.10+ built-in gc/gcc commenting with treesitter context
-- for correct JSX/TSX comment styles (HTML vs JS regions)
return {
	"JoosepAlviste/nvim-ts-context-commentstring",
	lazy = true,
	opts = { enable_autocmd = false },
	init = function()
		local get_option = vim.filetype.get_option
		---@diagnostic disable-next-line: duplicate-set-field
		vim.filetype.get_option = function(filetype, option)
			return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
				or get_option(filetype, option)
		end
	end,
}
