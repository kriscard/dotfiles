return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	event = "VeryLazy",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
	},
	opts = {
		menu = {
			width = vim.api.nvim_win_get_width(0) - 4,
		},
		settings = {
			save_on_toggle = true,
		},
	},

	keys = function()
		local harpoon = require("harpoon")

		local keys = {
			{
				"<leader>H",
				function()
					harpoon:list():add()
				end,
				desc = "[H]arpoon File",
			},
			{
				"<leader>h",
				function()
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "[H]arpoon Quick Menu",
			},
			{
				"<leader>hc",
				function()
					harpoon:list():clear()
				end,
				desc = "[H]arpoon Quick Menu",
			},
		}

		for i = 1, 5 do
			table.insert(keys, {
				"<leader>" .. i,
				function()
					require("harpoon"):list():select(i)
				end,
				desc = "[H]arpoon to File " .. i,
			})
		end
		return keys
	end,
}
