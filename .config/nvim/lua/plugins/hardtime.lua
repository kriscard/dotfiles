return {
	"m4xshen/hardtime.nvim",
	enabled = false,
	dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
	opts = {
		disabled_filetypes = { "qf", "netrw", "NvimTree", "lazy", "mason", "oil" },
		disabled_keys = {
			["<Up>"] = {},
			["<Space>"] = { "n", "x" },
		},
		hints = {
			["d[tTfF].i"] = {
				message = function(keys)
					return "Use c" .. keys:sub(2, 3) .. " instead of " .. keys
				end,
				length = 4,
			},
		},
	},
}
