return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		plugins = { spelling = true },
		defaults = {
			mode = { "n", "v" },
			{ "<leader>a", group = "ai" },
			{ "<leader>b", group = "buffer" },
			{ "<leader>c", group = "code" },
			{ "<leader>f", group = "file/find" },
			{ "<leader>g", group = "git" },
			{ "<leader>s", group = "search" },
			{ "<leader>u", group = "ui" },
			{ "<leader>w", group = "windows" },
			{ "<leader>q", group = "quickfixList/Quit" },
			{ "<leader>h", group = "harpoon" },
			{ "<leader>r", group = "rename" },
			{ "[", group = "prev" },
			{ "]", group = "next" },
			{ "g", group = "goto" },
			{ "gs", group = "surround" },
		},
	},
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)
		wk.add(opts.defaults)
	end,
}
