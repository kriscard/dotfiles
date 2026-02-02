return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		menu = {
			width = vim.api.nvim_win_get_width(0) - 4,
		},
		settings = {
			save_on_toggle = true,
		},
	},
	keys = {
		{ "<leader>ha", function() require("harpoon"):list():add() end, desc = "Add file" },
		{ "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Quick menu" },
		{ "<leader>hc", function() require("harpoon"):list():clear() end, desc = "Clear list" },
		{ "<leader>hp", function() require("harpoon"):list():prev() end, desc = "Previous file" },
		{ "<leader>hn", function() require("harpoon"):list():next() end, desc = "Next file" },
		{ "<leader>h1", function() require("harpoon"):list():select(1) end, desc = "File 1" },
		{ "<leader>h2", function() require("harpoon"):list():select(2) end, desc = "File 2" },
		{ "<leader>h3", function() require("harpoon"):list():select(3) end, desc = "File 3" },
		{ "<leader>h4", function() require("harpoon"):list():select(4) end, desc = "File 4" },
		{ "<leader>h5", function() require("harpoon"):list():select(5) end, desc = "File 5" },
	},
}
