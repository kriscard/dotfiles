-- React-specific keymaps and utilities
return {
	{
		"folke/which-key.nvim",
		opts = function(_, opts)
			opts.spec = opts.spec or {}
			opts.spec[#opts.spec + 1] = {
				{ "<leader>r", group = "React" },
				{ "<leader>re", desc = "Extract component to new file", mode = "v" },
				{ "<leader>rc", desc = "Extract component to current file", mode = "v" },
				{ "<leader>rf", desc = "Refactor", mode = "n" },
				{ "<leader>rh", desc = "Convert to React Hook", mode = "v" },
				{ "<leader>ri", desc = "Add import", mode = "n" },
				{ "<leader>rp", desc = "Add prop-types", mode = "n" },
			}
		end,
	},
}