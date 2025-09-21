return {
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					insert = "<C-g>s",
					insert_line = "<C-g>S",
					normal = "ys",
					normal_cur = "yss",
					normal_line = "yS",
					normal_cur_line = "ySS",
					visual = "S",
					visual_line = "gS",
					delete = "ds",
					change = "cs",
					change_line = "cS",
				},
				aliases = {
					["a"] = ">",
					["b"] = ")",
					["B"] = "}",
					["r"] = "]",
					["q"] = { '"', "'", "`" },
					["s"] = { "}", "]", ")", ">", '"', "'", "`" },
				},
				highlight = {
					duration = 0,
				},
				move_cursor = "begin",
				indent_lines = function(start, stop)
					local b = vim.bo
					if b.expandtab then
						local shiftwidth = b.shiftwidth ~= 0 and b.shiftwidth or b.tabstop
						return string.rep(" ", shiftwidth)
					else
						return "\t"
					end
				end,
			})
		end,
	},
}