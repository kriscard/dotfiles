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
				"<leader>ha",
				function()
					harpoon:list():add()
				end,
				desc = "Add file",
			},
			{
				"<leader>hh",
				function()
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Quick menu",
			},
			{
				"<leader>hc",
				function()
					harpoon:list():clear()
				end,
				desc = "Clear list",
			},
			{
				"<leader>hp",
				function()
					harpoon:list():prev()
				end,
				desc = "Previous file",
			},
			{
				"<leader>hn",
				function()
					harpoon:list():next()
				end,
				desc = "Next file",
			},
		}

		-- File slots 1-5 under harpoon submenu
		for i = 1, 5 do
			table.insert(keys, {
				"<leader>h" .. i,
				function()
					require("harpoon"):list():select(i)
				end,
				desc = "File " .. i,
			})
		end
		return keys
	end,
}
