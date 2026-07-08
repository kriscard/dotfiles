return {
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		keys = {
			{ "ys", mode = "n", desc = "Add surround" },
			{ "yss", mode = "n", desc = "Add surround to line" },
			{ "yS", mode = "n", desc = "Add surround on new lines" },
			{ "ySS", mode = "n", desc = "Add surround to line on new lines" },
			{ "ds", mode = "n", desc = "Delete surround" },
			{ "cs", mode = "n", desc = "Change surround" },
			{ "cS", mode = "n", desc = "Change surround on new lines" },
			{ "S", mode = "x", desc = "Surround selection" },
			{ "<C-g>s", mode = "i", desc = "Add surround" },
			{ "<C-g>S", mode = "i", desc = "Add surround on new lines" },
		},
		config = function()
			require("nvim-surround").setup({
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
					-- nvim-surround expects this callback to indent the affected range.
					-- It does not consume a returned indent string.
					if
						start < stop
						and (b.equalprg ~= "" or b.indentexpr ~= "" or b.cindent or b.smartindent or b.lisp)
					then
						vim.cmd(string.format("silent normal! %dG=%dG", start, stop))
					end
				end,
			})
		end,
	},
}
