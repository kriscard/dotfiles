return {
	{
		"vuki656/package-info.nvim",
		ft = "json",
		config = function()
			require("package-info").setup({
				autostart = false, -- Disable built-in autostart, we use custom autocmd below
			})
			-- Custom autocmd: only run on real package.json files (not Octo virtual buffers)
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "package.json",
				callback = function()
					local bufname = vim.api.nvim_buf_get_name(0)
					-- Only run if it's a real file (not Octo/fugitive/etc virtual buffer)
					if vim.fn.filereadable(bufname) == 1 then
						require("package-info").show()
					end
				end,
			})
		end,
		keys = {
			-- Show dependency versions
			{ "<leader>Ps", "<cmd>lua require('package-info').show()<CR>", desc = "Show dependency versions" },
			{ "<leader>Pc", "<cmd>lua require('package-info').hide()<CR>", desc = "Hide dependency versions" },
			{ "<leader>Pt", "<cmd>lua require('package-info').toggle()<CR>", desc = "Toggle dependency versions" },
			{ "<leader>Pu", "<cmd>lua require('package-info').update()<CR>", desc = "Update dependency on the line" },
			{ "<leader>Pd", "<cmd>lua require('package-info').delete()<CR>", desc = "Delete dependency on the line" },
			{ "<leader>Pi", "<cmd>lua require('package-info').install()<CR>", desc = "Install a new dependency" },
			{
				"<leader>Pv",
				"<cmd>lua require('package-info').change_version()<CR>",
				desc = "Change dependency version",
			},
			{
				"<leader>Pf",
				function()
					Snacks.picker.grep({ glob = "package.json" })
				end,
				desc = "Find in package.json",
			},
		},
	},
}
