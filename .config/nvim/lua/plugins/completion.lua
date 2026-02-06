return {
	"saghen/blink.cmp",
	version = "*",
	dependencies = {
		"saghen/blink.compat",
		"moyiz/blink-emoji.nvim",
		"Kaiser-Yang/blink-cmp-dictionary",
		"Kaiser-Yang/blink-cmp-git",
	},
	opts = {
		keymap = {
			preset = "default",
			["<CR>"] = { "accept", "fallback" },
			["<Tab>"] = { "snippet_forward", "accept", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "fallback" },
			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide" },
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },
		},

		completion = {
			list = {
				selection = { preselect = true, auto_insert = true },
				max_items = 200,
			},
			accept = { auto_brackets = { enabled = true } },
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				window = { border = "rounded" },
			},
			ghost_text = { enabled = true },
			menu = {
				border = "rounded",
				scrollbar = false,
				draw = {
					treesitter = { "lsp" },
					columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
				},
			},
		},

		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer", "emoji" },
			per_filetype = {
				gitcommit = { "git", "buffer" },
				markdown = { "obsidian", "lsp", "path", "snippets", "buffer", "dictionary", "emoji" },
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				emoji = {
					module = "blink-emoji",
					name = "emoji",
					score_offset = -15,
					min_keyword_length = 2,
				},
				git = {
					module = "blink-cmp-git",
					name = "git",
					score_offset = 10,
					enabled = function()
						return vim.bo.filetype == "gitcommit"
					end,
				},
				dictionary = {
					module = "blink-cmp-dictionary",
					name = "dict",
					score_offset = -10,
					max_items = 5,
					min_keyword_length = 3,
					enabled = function()
						return vim.tbl_contains({ "markdown", "text", "gitcommit" }, vim.bo.filetype)
					end,
				},
			},
		},

		signature = {
			enabled = true,
			window = { border = "rounded" },
		},
		fuzzy = { sorts = { "exact", "score", "sort_text" } },
		cmdline = { enabled = true },
		snippets = { preset = "luasnip" },
		appearance = { nerd_font_variant = "mono" },
	},
}
