return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	config = function()
		local lazy_status = require("lazy.status")
		local macchiato = require("catppuccin.palettes").get_palette("macchiato")

		-- Display a status when recording a macro
		local function macro_recording()
			local recording_register = vim.fn.reg_recording()
			if recording_register == "" then
				return ""
			else
				return "Recording @" .. recording_register
			end
		end

		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "catppuccin",
				globalstatus = true,
				disabled_filetypes = { statusline = { "dashboard" } },
			},
			sections = {
				lualine_c = {
					{ "filename", path = 1 },
				},
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = macchiato.peach },
					},
					{
						macro_recording,
						color = { fg = macchiato.red },
					},
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
			},
		})
	end,
}
