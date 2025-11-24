return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		event = "VeryLazy",
		ft = "markdown",
		dependencies = {
			-- Required.
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
			"folke/snacks.nvim", -- for	picker
		},
		config = function(_, opts)
			-- Setup obsidian.nvim
			require("obsidian").setup(opts)

			-- Create which-key mappings for common commands.
			local wk = require("which-key")
			wk.add({
				{ "<leader>o", group = "Obsidian" },
			})
		end,
		opts = {
			-- Disable legacy commands (use new command structure)
			legacy_commands = false,
			workspaces = {
				{
					name = "kriscard",
					path = "~/obsidian-vault-kriscard",
				},
			},
			completion = {
				nvim_cmp = false,
				blink = true,
				min_chars = 2,
			},
			templates = {
				subdir = "Templates",
				date_format = "%Y-%m-%d",
				time_format = "%H:%M",
			},
			daily_notes = {
				folder = "1 - Notes/Daily Notes",
				date_format = "%Y-%m-%d",
				template = "Daily Notes.md",
				default_tags = { "daily" },
			},

			picker = {
				name = "snacks.pick", -- Use 'snacks' picker
				note_mappings = {
					new = "<C-x>", -- Create new note from picker
					insert_link = "<C-l>", -- Insert link to selected note
				},
				tag_mappings = {
					tag_note = "<C-x>", -- Tag note in picker
					insert_tag = "<C-l>", -- Insert selected tag
				},
			},
			search = {
				sort_by = "modified",
				sort_reversed = true,
			},
			open_notes_in = "vsplit",
			log_level = vim.log.levels.INFO,
			new_notes_location = "notes_subdir",

			-- Open configuration - for opening notes in Obsidian app
			open = {
				use_advanced_uri = true, -- Open files with line numbers in Obsidian app
				func = vim.ui.open,
			},
		},
	},
}
