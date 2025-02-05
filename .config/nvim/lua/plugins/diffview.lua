return {
	"sindrets/diffview.nvim",
	dependencies = "nvim-lua/plenary.nvim",
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
		"DiffviewFileHistory",
	},
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Open Diffview" },
		{ "<leader>gD", "<cmd>DiffviewClose<CR>", desc = "Close Diffview" },
	},
	config = function()
		-- Create DAP directory to fix the missing log file error
		local dap_dir = vim.fn.stdpath("cache") .. "/dap"
		vim.fn.mkdir(dap_dir, "p")

		require("diffview").setup({
			view = {
				-- Updated configuration using the new syntax
				default = {
					layout = "diff2_horizontal",
				},
				merge_tool = {
					layout = "diff3_horizontal",
				},
				file_panel = {
					positioning = "bottom", -- replaces position
					win_config = {
						height = 20, -- height setting moved here
					},
				},
			},
			hooks = {
				view_opened = function()
					---@diagnostic disable-next-line: undefined-field
					local stdout = vim.loop.new_tty(1, false)
					if stdout ~= nil then
						stdout:write(
							("\x1bPtmux;\x1b\x1b]1337;SetUserVar=%s=%s\b\x1b\\"):format(
								"DIFF_VIEW",
								vim.fn.system({ "base64" }, "+4")
							)
						)
						vim.cmd([[redraw]])
					end
				end,
				view_closed = function()
					---@diagnostic disable-next-line: undefined-field
					local stdout = vim.loop.new_tty(1, false)
					if stdout ~= nil then
						stdout:write(
							("\x1bPtmux;\x1b\x1b]1337;SetUserVar=%s=%s\b\x1b\\"):format(
								"DIFF_VIEW",
								vim.fn.system({ "base64" }, "-1")
							)
						)
						vim.cmd([[redraw]])
					end
				end,
			},
		})
	end,
}
