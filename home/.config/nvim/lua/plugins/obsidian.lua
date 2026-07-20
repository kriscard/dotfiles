return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		-- Load on Markdown files or when using Obsidian commands.
		ft = "markdown",
		cmd = { "Obsidian" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"folke/snacks.nvim", -- picker and image support
			"folke/which-key.nvim",
		},
		config = function(_, opts)
			require("obsidian").setup(opts)

			-- Create which-key mappings
			local wk = require("which-key")
			wk.add({
				{ "<leader>o", group = "Obsidian" },
			})
		end,
		---@module "obsidian"
		---@type obsidian.config
		opts = {
			-- Disable legacy commands (use new command structure)
			legacy_commands = false,

			workspaces = {
				{
					name = "kriscard",
					path = "~/obsidian-vault-kriscard",
				},
			},

			-- Notes directory configuration
			notes_subdir = "0 - Inbox",
			new_notes_location = "notes_subdir",

			-- ══════════════════════════════════════════════════════════════════════
			-- Wiki Links & Markdown Links
			-- ══════════════════════════════════════════════════════════════════════
			-- Link configuration (replaces deprecated wiki_link_func / preferred_link_style)
			link = {
				style = "wiki",    -- "wiki" for [[note]] or "markdown" for [note](note.md)
				format = "shortest", -- "shortest", "relative", or "absolute"
			},

			-- Frontmatter configuration
			frontmatter = {
				enabled = true,
				sort = { "id", "aliases", "tags", "created" },
				func = function(note)
					local out = {
						id = note.id,
						aliases = note.aliases,
						tags = note.tags,
						created = os.date("%Y-%m-%d %H:%M"),
					}
					-- Preserve existing frontmatter
					if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
						for k, v in pairs(note.metadata) do
							out[k] = v
						end
					end
					return out
				end,
			},

			-- Readable UTF-8 IDs with collision handling and a timestamp fallback.
			note_id_func = function(title, dir)
				return require("obsidian.builtin").title_id(title, dir)
			end,

			-- ══════════════════════════════════════════════════════════════════════
			-- Templates
			-- ══════════════════════════════════════════════════════════════════════
			templates = {
				folder = "Templates",
				date_format = "YYYY-MM-DD",
				time_format = "HH:mm",
				-- Template substitutions
				substitutions = {
					yesterday = function()
						return os.date("%Y-%m-%d", os.time() - 86400)
					end,
					tomorrow = function()
						return os.date("%Y-%m-%d", os.time() + 86400)
					end,
					week = function()
						return os.date("%G-W%V")
					end,
				},
			},

			-- ══════════════════════════════════════════════════════════════════════
			-- Daily Notes
			-- ══════════════════════════════════════════════════════════════════════
			daily_notes = {
				folder = "2 - Areas/Daily Ops",
				date_format = "YYYY/YYYY-MM-DD",
				alias_format = "MMMM D, YYYY", -- e.g., "January 15, 2025"
				template = "Daily Notes.md",
				default_tags = { "daily" },
				workdays_only = true,
			},

			-- ══════════════════════════════════════════════════════════════════════
			-- Picker (Snacks integration)
			-- ══════════════════════════════════════════════════════════════════════
			picker = {
				name = "snacks.picker",
			},

			-- ══════════════════════════════════════════════════════════════════════
			-- Checkbox Configuration
			-- ══════════════════════════════════════════════════════════════════════
			checkbox = {
				order = { " ", ">", "x", "~", "!" },
			},

			-- ══════════════════════════════════════════════════════════════════════
			-- UI Configuration
			-- ══════════════════════════════════════════════════════════════════════
			ui = {
				enable = true,
				update_debounce = 200,
				max_file_length = 5000, -- Disable UI for large files
				bullets = { char = "•", hl_group = "ObsidianBullet" },
				external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
				reference_text = { hl_group = "ObsidianRefText" },
				highlight_text = { hl_group = "ObsidianHighlightText" },
				tags = { hl_group = "ObsidianTag" },
				block_ids = { hl_group = "ObsidianBlockID" },
				hl_groups = {
					ObsidianTodo = { bold = true, fg = "#f5a97f" },
					ObsidianDone = { bold = true, fg = "#a6da95" },
					ObsidianRightArrow = { bold = true, fg = "#8bd5ca" },
					ObsidianTilde = { bold = true, fg = "#8087a2" },
					ObsidianImportant = { bold = true, fg = "#ed8796" },
					ObsidianBullet = { bold = true, fg = "#8aadf4" },
					ObsidianRefText = { underline = true, fg = "#c6a0f6" },
					ObsidianExtLinkIcon = { fg = "#c6a0f6" },
					ObsidianTag = { italic = true, fg = "#8bd5ca" },
					ObsidianBlockID = { italic = true, fg = "#8087a2" },
					ObsidianHighlightText = { bg = "#eed49f", fg = "#1e2030" },
				},
			},

			-- ══════════════════════════════════════════════════════════════════════
			-- Attachments (images, files)
			-- ══════════════════════════════════════════════════════════════════════
			attachments = {
				folder = "Attachments",
				img_name_func = function()
					return string.format("img-%s", os.date("%Y%m%d%H%M%S"))
				end,
			},

			open_notes_in = "vsplit",
		},
	},
}
