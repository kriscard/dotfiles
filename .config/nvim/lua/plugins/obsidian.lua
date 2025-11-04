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
				date_format = "%Y-%m-%d-%a",
				time_format = "%H:%M",
			},
			daily_notes = {
				-- Optional, if you keep daily notes in a separate directory.
				folder = "1 - Notes/Daily Notes",
				-- Optional, if you want to change the date format for the ID of daily notes.
				date_format = "%Y-%m-%d",
				-- Optional, if you want to change the date format of the default alias of daily notes.
				alias_format = "%B %-d, %Y",
				-- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
				template = "Daily Notes.md",
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
			sort_by = "modified",
			sort_reversed = true,
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
