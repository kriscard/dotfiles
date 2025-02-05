local picker = "telescope.nvim"

return {
	{
		"epwalsh/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		event = "VeryLazy",
		ft = "markdown",
		dependencies = {
			-- Required.
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
			picker,
		},
		config = function(_, opts)
			-- Setup obsidian.nvim
			require("obsidian").setup(opts)

			-- Create which-key mappings for common commands.
			local wk = require("which-key")
			wk.add({
				{ "<leader>o", group = "Obsisian" },
			})
		end,
		opts = {
			workspaces = {
				{
					name = "kriscard",
					path = "~/obsidian-vault-kriscard",
				},
			},
			completion = {
				nvim_cmp = true,
				min_chars = 2,
			},
			ui = { enable = false },
			templates = {
				subdir = "Templates",
				date_format = "%Y-%m-%d-%a",
				time_format = "%H:%M",
			},
			daily_notes = {
				-- Optional, if you keep daily notes in a separate directory.
				folder = "Daily Notes",
				-- Optional, if you want to change the date format for the ID of daily notes.
				date_format = "%Y-%m-%d",
				-- Optional, if you want to change the date format of the default alias of daily notes.
				alias_format = "%B %-d, %Y",
				-- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
				template = "Daily Notes.md",
			},

			picker = {
				name = picker,
			},
			sort_by = "modified",
			sort_reversed = true,
			open_notes_in = "vsplit",
			log_level = vim.log.levels.INFO,
			new_notes_location = "notes_subdir",

			-- customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
			---@return string
			image_name_func = function()
				-- Prefix image names with timestamp.
				return string.format("%s-", os.time())
			end,

			-- Optional, boolean or a function that takes a filename and returns a boolean.
			-- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
			disable_frontmatter = false,

			-- Optional, alternatively you can customize the frontmatter data.
			---@return table
			note_frontmatter_func = function(note)
				-- Add the title of the note as an alias.
				if note.title then
					note:add_alias(note.title)
				end

				local out = { id = note.id, aliases = note.aliases, tags = note.tags }

				-- `note.metadata` contains any manually added fields in the frontmatter.
				-- So here we just make sure those fields are kept in the frontmatter.
				if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
					for k, v in pairs(note.metadata) do
						out[k] = v
					end
				end

				return out
			end,
		},
	},
}
