return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		-- Load on markdown files OR when using Obsidian commands
		ft = "markdown",
		cmd = { "Obsidian" },
		event = {
			-- Load when opening files in the vault
			"BufReadPre " .. vim.fn.expand("~") .. "/obsidian-vault-kriscard/*.md",
			"BufNewFile " .. vim.fn.expand("~") .. "/obsidian-vault-kriscard/*.md",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"folke/snacks.nvim", -- for picker
		},
		config = function(_, opts)
			require("obsidian").setup(opts)

			-- Create which-key mappings
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
					-- Workspace-specific overrides
					overrides = {
						notes_subdir = "1 - Notes",
					},
				},
			},

			-- Notes directory configuration
			notes_subdir = "1 - Notes",
			new_notes_location = "notes_subdir",

			-- ══════════════════════════════════════════════════════════════════════
			-- Completion (Blink.cmp integration)
			-- ══════════════════════════════════════════════════════════════════════
			completion = {
				nvim_cmp = false,
				blink = true,
				min_chars = 2,
			},

			-- ══════════════════════════════════════════════════════════════════════
			-- Wiki Links & Markdown Links
			-- ══════════════════════════════════════════════════════════════════════
			-- Prefer wiki links [[note]] over markdown links [note](note.md)
			preferred_link_style = "wiki",

			-- How to generate wiki link IDs
			wiki_link_func = "prepend_note_id", -- prepend_note_id, prepend_note_path, use_alias_only, use_path_only

			-- Frontmatter configuration
			frontmatter = {
				enabled = true,
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

			-- Note ID generation (for new notes)
			note_id_func = function(title)
				-- Clean title for file name
				local suffix = ""
				if title ~= nil then
					-- If title is provided, transform it to valid filename
					suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
				else
					-- If no title, use timestamp
					suffix = tostring(os.time())
				end
				return suffix
			end,

			-- Note path function (where new notes are created)
			note_path_func = function(spec)
				local path = spec.dir / tostring(spec.id)
				return path:with_suffix(".md")
			end,

			-- ══════════════════════════════════════════════════════════════════════
			-- Templates
			-- ══════════════════════════════════════════════════════════════════════
			templates = {
				subdir = "Templates", -- Must be 'subdir' not 'folder'
				date_format = "%Y-%m-%d",
				time_format = "%H:%M",
				-- Template substitutions
				substitutions = {
					yesterday = function()
						return os.date("%Y-%m-%d", os.time() - 86400)
					end,
					tomorrow = function()
						return os.date("%Y-%m-%d", os.time() + 86400)
					end,
					week = function()
						return os.date("%Y-W%W")
					end,
				},
			},

			-- ══════════════════════════════════════════════════════════════════════
			-- Daily Notes
			-- ══════════════════════════════════════════════════════════════════════
			daily_notes = {
				folder = "1 - Notes/Daily Notes",
				date_format = "%Y-%m-%d",
				alias_format = "%B %-d, %Y", -- e.g., "January 15, 2025"
				template = "Daily Notes.md",
				default_tags = { "daily" },
			},

			-- ══════════════════════════════════════════════════════════════════════
			-- Picker (Snacks.pick integration)
			-- ══════════════════════════════════════════════════════════════════════
			picker = {
				name = "snacks.pick",
				note_mappings = {
					new = "<C-x>",
					insert_link = "<C-l>",
				},
				tag_mappings = {
					tag_note = "<C-x>",
					insert_tag = "<C-l>",
				},
			},

			-- ══════════════════════════════════════════════════════════════════════
			-- Search & Sort
			-- ══════════════════════════════════════════════════════════════════════
			search = {
				sort_by = "modified",
				sort_reversed = true,
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
				-- Image naming function
				img_name_func = function()
					return string.format("img-%s", os.date("%Y%m%d%H%M%S"))
				end,
				-- Image text function for embedding
				img_text_func = function(client, path)
					path = client:vault_relative_path(path) or path
					return string.format("![[%s]]", path.name)
				end,
			},

			-- ══════════════════════════════════════════════════════════════════════
			-- Callbacks
			-- ══════════════════════════════════════════════════════════════════════
			callbacks = {
				-- Called after note creation
				post_setup = function(client)
					-- Custom highlight groups for Obsidian
					vim.api.nvim_set_hl(0, "ObsidianTodo", { bold = true, fg = "#f5a97f" })
					vim.api.nvim_set_hl(0, "ObsidianDone", { bold = true, fg = "#a6da95" })
				end,
			},

			-- ══════════════════════════════════════════════════════════════════════
			-- Open Configuration
			-- ══════════════════════════════════════════════════════════════════════
			open_notes_in = "vsplit",
			open = {
				use_advanced_uri = true,
				func = vim.ui.open,
			},

			-- Logging
			log_level = vim.log.levels.INFO,
		},
	},
}
