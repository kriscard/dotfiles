-- Collection of various small independent plugins/modules
return {
	"echasnovski/mini.nvim",
	event = "VeryLazy",
	config = function()
		-- Better Around/Inside textobjects
		--
		-- Examples:
		--  - va)  - [V]isually select [A]round [)]paren
		--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
		--  - ci'  - [C]hange [I]nside [']quote
		require("mini.ai").setup({ n_lines = 500 })

		-- Add/delete/replace surroundings handled by nvim-surround plugin

		-- Bracket navigation: [b ]b buffers, [c ]c comments, [x ]x conflicts,
		-- [i ]i indent, [j ]j jumplist, [t ]t treesitter, [u ]u undo, [y ]y yank.
		-- Disabled modules below collide with custom keymaps.lua bindings.
		require("mini.bracketed").setup({
			diagnostic = { suffix = "" }, -- custom [d ]d in keymaps.lua
			quickfix = { suffix = "" }, -- custom [q ]q in keymaps.lua
			location = { suffix = "" }, -- custom [l ]l in keymaps.lua
			window = { suffix = "" }, -- [w ]w used for warnings in keymaps.lua
		})
	end,
}
