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

	-- {
	-- 	"lukas-reineke/headlines.nvim",
	-- 	opts = function()
	-- 		local opts = {}
	-- 		for _, ft in ipairs({ "markdown", "norg", "rmd", "org" }) do
	-- 			opts[ft] = {
	-- 				headline_highlights = {},
	-- 				-- disable bullets for now. See https://github.com/lukas-reineke/headlines.nvim/issues/66
	-- 				bullets = {},
	-- 			}
	-- 			for i = 1, 6 do
	-- 				local hl = "Headline" .. i
	-- 				vim.api.nvim_set_hl(0, hl, { link = "Headline", default = true })
	-- 				table.insert(opts[ft].headline_highlights, hl)
	-- 			end
	-- 		end
	-- 		return opts
	-- 	end,
	-- 	ft = { "markdown", "norg", "rmd", "org" },
	-- 	config = function(_, opts)
	-- 		-- PERF: schedule to prevent headlines slowing down opening a file
	-- 		vim.schedule(function()
	-- 			require("headlines").setup(opts)
	-- 			require("headlines").refresh()
	-- 		end)
	-- 	end,
	-- },

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
