-- Filetype detection for MDX (must run before plugins)
vim.filetype.add({
	extension = {
		mdx = "mdx",
	},
})

return {
	-- ══════════════════════════════════════════════════════════════════════════════
	-- Render Markdown - Beautiful markdown rendering in Neovim
	-- ══════════════════════════════════════════════════════════════════════════════
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		ft = { "markdown", "vimwiki", "norg", "rmd", "org", "Avante", "mdx", "codecompanion" },
		keys = {
			{ "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown render" },
		},
		opts = {
			file_types = { "markdown", "vimwiki", "norg", "rmd", "org", "Avante", "mdx", "codecompanion" },

			-- Render modes (normal, insert, etc.)
			render_modes = { "n", "c", "t" }, -- Normal, command, terminal

			-- Code blocks with language labels
			code = {
				enabled = true,
				sign = true,
				style = "full", -- full, normal, language, none
				position = "left",
				language_pad = 1,
				language_name = true,
				width = "block",
				left_pad = 1,
				right_pad = 1,
				min_width = 40,
				border = "thin", -- thin, thick, none
				above = "▄",
				below = "▀",
				highlight = "RenderMarkdownCode",
				highlight_inline = "RenderMarkdownCodeInline",
				highlight_language = nil, -- Use treesitter
			},

			-- Headings with visual distinction
			heading = {
				enabled = true,
				sign = true,
				position = "overlay",
				icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
				signs = { "󰫎 " },
				width = "full",
				left_margin = 0,
				left_pad = 0,
				right_pad = 0,
				min_width = 0,
				border = false,
				border_virtual = false,
				border_prefix = false,
				above = "▄",
				below = "▀",
				backgrounds = {
					"RenderMarkdownH1Bg",
					"RenderMarkdownH2Bg",
					"RenderMarkdownH3Bg",
					"RenderMarkdownH4Bg",
					"RenderMarkdownH5Bg",
					"RenderMarkdownH6Bg",
				},
				foregrounds = {
					"RenderMarkdownH1",
					"RenderMarkdownH2",
					"RenderMarkdownH3",
					"RenderMarkdownH4",
					"RenderMarkdownH5",
					"RenderMarkdownH6",
				},
			},

			-- Bullet points with custom icons
			bullet = {
				enabled = true,
				icons = { "●", "○", "◆", "◇" },
				left_pad = 0,
				right_pad = 0,
				highlight = "RenderMarkdownBullet",
			},

			-- Checkboxes with visual states
			checkbox = {
				enabled = true,
				position = "inline",
				unchecked = {
					icon = "󰄱 ",
					highlight = "RenderMarkdownUnchecked",
					scope_highlight = nil,
				},
				checked = {
					icon = "󰱒 ",
					highlight = "RenderMarkdownChecked",
					scope_highlight = nil,
				},
				custom = {
					todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
					important = { raw = "[!]", rendered = "󰓎 ", highlight = "DiagnosticWarn" },
					canceled = { raw = "[~]", rendered = "󰰱 ", highlight = "Comment" },
					forwarded = { raw = "[>]", rendered = "󰁔 ", highlight = "RenderMarkdownInfo" },
					scheduling = { raw = "[<]", rendered = "󰃰 ", highlight = "RenderMarkdownHint" },
					question = { raw = "[?]", rendered = "󰘥 ", highlight = "DiagnosticInfo" },
					star = { raw = "[*]", rendered = "󰓏 ", highlight = "RenderMarkdownWarn" },
					info = { raw = "[i]", rendered = "󰋼 ", highlight = "RenderMarkdownInfo" },
				},
			},

			-- Tables with borders
			pipe_table = {
				enabled = true,
				preset = "round", -- none, round, double, heavy
				style = "full", -- none, normal, full
				cell = "padded", -- overlay, raw, padded
				padding = 1,
				min_width = 0,
				border = {
					"╭",
					"┬",
					"╮",
					"├",
					"┼",
					"┤",
					"╰",
					"┴",
					"╯",
					"│",
					"─",
				},
				alignment_indicator = "━",
				head = "RenderMarkdownTableHead",
				row = "RenderMarkdownTableRow",
				filler = "RenderMarkdownTableFill",
			},

			-- Callouts/admonitions (Obsidian style)
			callout = {
				note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
				tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
				important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
				warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
				caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
				abstract = { raw = "[!ABSTRACT]", rendered = "󰨸 Abstract", highlight = "RenderMarkdownInfo" },
				summary = { raw = "[!SUMMARY]", rendered = "󰨸 Summary", highlight = "RenderMarkdownInfo" },
				tldr = { raw = "[!TLDR]", rendered = "󰨸 TL;DR", highlight = "RenderMarkdownInfo" },
				info = { raw = "[!INFO]", rendered = "󰋽 Info", highlight = "RenderMarkdownInfo" },
				todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "RenderMarkdownInfo" },
				hint = { raw = "[!HINT]", rendered = "󰌶 Hint", highlight = "RenderMarkdownSuccess" },
				success = { raw = "[!SUCCESS]", rendered = "󰄬 Success", highlight = "RenderMarkdownSuccess" },
				check = { raw = "[!CHECK]", rendered = "󰄬 Check", highlight = "RenderMarkdownSuccess" },
				done = { raw = "[!DONE]", rendered = "󰄬 Done", highlight = "RenderMarkdownSuccess" },
				question = { raw = "[!QUESTION]", rendered = "󰘥 Question", highlight = "RenderMarkdownWarn" },
				help = { raw = "[!HELP]", rendered = "󰘥 Help", highlight = "RenderMarkdownWarn" },
				faq = { raw = "[!FAQ]", rendered = "󰘥 FAQ", highlight = "RenderMarkdownWarn" },
				attention = { raw = "[!ATTENTION]", rendered = "󰀪 Attention", highlight = "RenderMarkdownWarn" },
				failure = { raw = "[!FAILURE]", rendered = "󰅚 Failure", highlight = "RenderMarkdownError" },
				fail = { raw = "[!FAIL]", rendered = "󰅚 Fail", highlight = "RenderMarkdownError" },
				missing = { raw = "[!MISSING]", rendered = "󰅚 Missing", highlight = "RenderMarkdownError" },
				danger = { raw = "[!DANGER]", rendered = "󱐌 Danger", highlight = "RenderMarkdownError" },
				error = { raw = "[!ERROR]", rendered = "󱐌 Error", highlight = "RenderMarkdownError" },
				bug = { raw = "[!BUG]", rendered = "󰨰 Bug", highlight = "RenderMarkdownError" },
				example = { raw = "[!EXAMPLE]", rendered = "󰉹 Example", highlight = "RenderMarkdownHint" },
				quote = { raw = "[!QUOTE]", rendered = "󱆨 Quote", highlight = "RenderMarkdownQuote" },
				cite = { raw = "[!CITE]", rendered = "󱆨 Cite", highlight = "RenderMarkdownQuote" },
			},

			-- Links rendering
			link = {
				enabled = true,
				footnote = {
					superscript = true,
					prefix = "",
					suffix = "",
				},
				image = "󰥶 ",
				email = "󰀓 ",
				hyperlink = "󰌹 ",
				highlight = "RenderMarkdownLink",
				wiki = { icon = "󱗖 ", highlight = "RenderMarkdownWikiLink" },
				custom = {
					web = { pattern = "^http[s]?://", icon = "󰖟 ", highlight = "RenderMarkdownLink" },
					github = { pattern = "^https://github%.com", icon = " ", highlight = "RenderMarkdownLink" },
					youtube = { pattern = "youtube%.com", icon = "󰗃 ", highlight = "RenderMarkdownLink" },
					obsidian = { pattern = "^obsidian://", icon = "󰠗 ", highlight = "RenderMarkdownLink" },
				},
			},

			-- Horizontal rules
			dash = {
				enabled = true,
				icon = "─",
				width = "full",
				highlight = "RenderMarkdownDash",
			},

			-- Block quotes
			quote = {
				enabled = true,
				icon = "▋",
				repeat_linebreak = false,
				highlight = "RenderMarkdownQuote",
			},

			-- LaTeX math rendering (if you use it)
			latex = {
				enabled = true,
				converter = "latex2text",
				highlight = "RenderMarkdownMath",
				top_pad = 0,
				bottom_pad = 0,
			},

			-- Sign column icons
			sign = {
				enabled = true,
				highlight = "RenderMarkdownSign",
			},

			-- Window options when rendering
			win_options = {
				conceallevel = {
					default = vim.api.nvim_get_option_value("conceallevel", {}),
					rendered = 3,
				},
				concealcursor = {
					default = vim.api.nvim_get_option_value("concealcursor", {}),
					rendered = "",
				},
			},

			-- Performance tuning
			debounce = 100,
			max_file_size = 10.0, -- MB

			-- Anti-conceal on cursor line
			anti_conceal = {
				enabled = true,
				above = 0,
				below = 0,
			},

			-- Inline image rendering via Snacks.image (Ghostty/Kitty protocol)
			image = {
				enabled = true,
				render = function(ctx)
					return require("snacks.image").render({
						buf = ctx.buf,
						src = ctx.src,
						pos = { ctx.row, ctx.col },
					})
				end,
			},
		},
	},

	-- ══════════════════════════════════════════════════════════════════════════════
	-- MDX support
	-- ══════════════════════════════════════════════════════════════════════════════
	{
		"davidmh/mdx.nvim",
		event = "BufEnter *.mdx",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = true,
	},

	-- ══════════════════════════════════════════════════════════════════════════════
	-- Markdown Preview - Live preview in browser
	-- ══════════════════════════════════════════════════════════════════════════════
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = "cd app && npx --yes yarn install",
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview toggle" },
		},
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_theme = "dark"
			vim.g.mkdp_auto_close = 0 -- Don't auto-close when switching buffers
			vim.g.mkdp_combine_preview = 1 -- Reuse preview window
		end,
	},
}
