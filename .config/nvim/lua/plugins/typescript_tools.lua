return {
	{
		"vuki656/package-info.nvim",
		event = "BufReadPre",
		config = function()
			require("package-info").setup()
		end,
		keys = {
			-- Show dependency versions
			{ "<leader>Ns", "<cmd>lua require('package-info').show()<CR>", desc = "Show dependency versions" },
			{ "<leader>Nc", "<cmd>lua require('package-info').hide()<CR>", desc = "Hide dependency versions" },
			{ "<leader>NT", "<cmd>lua require('package-info').toggle()<CR>", desc = "Toggle dependency versions" },
			{ "<leader>Nu", "<cmd>lua require('package-info').update()<CR>", desc = "Update dependency on the line" },
			{ "<leader>Nd", "<cmd>lua require('package-info').delete()<CR>", desc = "Delete dependency on the line" },
			{ "<leader>Ni", "<cmd>lua require('package-info').install()<CR>", desc = "Install a new dependency" },
			{
				"<leader>Np",
				"<cmd>lua require('package-info').change_version()<CR>",
				desc = "Install a different dependency version",
			},
			{ "<leader>Nt", ":Telescope package_info<CR>", desc = "Telescope package info" },
		},
	},
}
