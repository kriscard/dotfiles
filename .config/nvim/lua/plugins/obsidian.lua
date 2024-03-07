local picker = "telescope.nvim"

return {
	{
		"lukas-reineke/headlines.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = "VeryLazy",
		opts = {
			markdown = {
				headline_highlights = { "Headline1", "Headline2", "Headline3" },
				bullet_highlights = { "Headline1", "Headline2", "Headline3" },
				bullets = { "❯", "❯", "❯", "❯" },
				dash_string = "⎯",
				fat_headlines = false,
			},
		},
		config = function(_, opts)
			local bg = "#2B2B2B"

			vim.api.nvim_set_hl(0, "Headline1", { fg = "#33ccff", bg = bg })
			vim.api.nvim_set_hl(0, "Headline2", { fg = "#00bfff", bg = bg })
			vim.api.nvim_set_hl(0, "Headline3", { fg = "#0099cc", bg = bg })
			vim.api.nvim_set_hl(0, "CodeBlock", { bg = bg })
			vim.api.nvim_set_hl(0, "Dash", { fg = "#D19A66", bold = true })

			require("headlines").setup(opts)
		end,
	},

	{
		"epwalsh/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		event = "VeryLazy",
		ft = "markdown",
		dependencies = {
			-- Required.
			"nvim-lua/plenary.nvim",
			"nvim-cmp",
			picker,
		},
		config = function(_, opts)
			-- Setup obsidian.nvim
			require("obsidian").setup(opts)

			-- Create which-key mappings for common commands.
			local wk = require("which-key")

			wk.register({
				["<leader>o"] = {
					name = "Obsidian",
					o = { "<cmd>ObsidianOpen<cr>", "Open note" },
					n = { "<cmd>ObsidianNew<cr>", "New note" },
					t = { "<cmd>ObsidianTemplate<cr>", "Templates list" },
					b = { "<cmd>ObsidianBacklinks<cr>", "Backlinks" },
					p = { "<cmd>ObsidianPasteImg<cr>", "Paste image" },
					q = { "<cmd>ObsidianQuickSwitch<cr>", "Quick switch" },
					s = { "<cmd>ObsidianSearch<cr>", "Search" },
					ww = { "<cmd>ObsidianWorkspace work<cr>", "Switch workspaces" },
					wc = { "<cmd>ObsidianWorkspace code<cr>", "Switch workspaces" },
				},
			})
		end,
		opts = {
			workspaces = {
				{
					name = "code",
					path = "~/obsidian-vault-code",
				},
				{
					name = "work",
					path = "~/obsidian-vault-work",
				},
			},
			completion = {
				nvim_cmp = true,
				min_chars = 2,
			},
			templates = {
				subdir = "Templates",
				date_format = "%Y-%m-%d-%a",
				time_format = "%H:%M",
			},
			picker = {
				name = picker,
			},
			sort_by = "modified",
			sort_reversed = true,
			open_notes_in = "vsplit",
			log_level = vim.log.levels.INFO,
			new_notes_location = "notes_subdir",

			-- customize how note IDs are generated given an optional title.
			---@param title string|?
			---@return string
			note_id_func = function(title)
				-- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
				-- In this case a note with the title 'My new note' will be given an ID that looks
				-- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
				local suffix = ""
				if title ~= nil then
					-- If title is given, transform it into valid file name.
					suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
				else
					-- If title is nil, just add 4 random uppercase letters to the suffix.
					for _ = 1, 4 do
						suffix = suffix .. string.char(math.random(65, 90))
					end
				end
				return tostring(os.time()) .. "-" .. suffix
			end,

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
