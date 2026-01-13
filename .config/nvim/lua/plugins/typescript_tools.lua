return {
	{
		"vuki656/package-info.nvim",
		event = "BufReadPre",
		config = function()
			require("package-info").setup()
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
			{ "<leader>Pf", ":Telescope package_info<CR>", desc = "Find in packages" },
		},
	},
}
