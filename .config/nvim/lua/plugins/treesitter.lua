-- ══════════════════════════════════════════════════════════════════════════════
-- Treesitter (nvim-treesitter `main` branch — Neovim 0.12 native API)
-- ══════════════════════════════════════════════════════════════════════════════
-- The legacy `master` branch was archived May 2025 and is incompatible with
-- Neovim 0.12's treesitter node API (see set-lang-from-info-string! crash on
-- LSP hover). The `main` branch is a rewrite that uses Neovim core APIs:
--   - parsers installed via require('nvim-treesitter').install(...)
--   - highlighting started via vim.treesitter.start() in a FileType autocmd
--   - indentexpr set per filetype to the experimental indent function
--   - incremental_selection is REMOVED (use mini.ai or roll your own)
return {
	-- ────────────────────────────────────────────────────────────────────
	-- Core: nvim-treesitter (must be eager-loaded; main does not support lazy)
	-- ────────────────────────────────────────────────────────────────────
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local parsers = {
				-- Shells / system
				"bash", "c", "dockerfile", "regex",
				-- Web (markup / styling)
				"html", "css", "scss", "graphql",
				-- JS/TS family
				"javascript", "typescript", "tsx", "jsdoc",
				"astro",
				-- Data / config (jsonc uses the json parser on main branch)
				"json", "yaml", "toml",
				-- Lua
				"lua", "luadoc",
				-- Git ecosystem
				"diff", "git_config", "gitcommit", "git_rebase",
				"gitignore", "gitattributes",
				-- Markdown
				"markdown", "markdown_inline",
				-- Backends
				"python", "rust", "go", "gomod", "gosum",
				"prisma", "gleam",
				-- Treesitter / vim itself
				"query", "vim", "vimdoc",
			}

			-- Install parsers asynchronously (idempotent — no-op if installed).
			-- :TSUpdate (build hook) keeps them in sync with nvim-treesitter.
			require("nvim-treesitter").install(parsers)

			-- Filetypes that should get treesitter highlighting + indent.
			-- nvim-treesitter on main registers parser↔filetype links during
			-- install(), so vim.treesitter.start(buf) picks the right parser
			-- automatically from buffer filetype for most filetypes.
			local filetypes = {
				"bash", "sh", "c", "dockerfile",
				"html", "css", "scss", "graphql",
				"javascript", "javascriptreact",
				"typescript", "typescriptreact", "tsx",
				"astro",
				"json", "jsonc", "yaml", "toml",
				"lua",
				"diff", "gitcommit", "gitconfig", "gitignore", "gitrebase",
				"markdown",
				"python", "rust", "go", "gomod", "gosum",
				"prisma", "gleam",
				"query", "vim", "help",
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = filetypes,
				callback = function(args)
					-- Highlighting (errors silently if parser missing — pcall guards)
					pcall(vim.treesitter.start, args.buf)
					-- Indent (experimental on main, but works for the languages above)
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	-- ────────────────────────────────────────────────────────────────────
	-- Sticky context window (independent of nvim-treesitter master/main)
	-- ────────────────────────────────────────────────────────────────────
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},

	-- ────────────────────────────────────────────────────────────────────
	-- Auto-close / auto-rename HTML/JSX/TSX tags (independent)
	-- ────────────────────────────────────────────────────────────────────
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},

	-- ────────────────────────────────────────────────────────────────────
	-- Treesitter textobjects (main branch — manual keymaps via new API)
	-- ────────────────────────────────────────────────────────────────────
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")
			local swap = require("nvim-treesitter-textobjects.swap")

			-- ── select (visual + operator-pending) ──────────────────────
			-- Maps preserved from the previous master-branch config.
			local select_maps = {
				["aa"] = "@parameter.outer",   ["ia"] = "@parameter.inner",
				["af"] = "@function.outer",    ["if"] = "@function.inner",
				["ac"] = "@class.outer",       ["ic"] = "@class.inner",
				["ao"] = "@block.outer",       ["io"] = "@block.inner",
				["al"] = "@loop.outer",        ["il"] = "@loop.inner",
				["ai"] = "@conditional.outer", ["ii"] = "@conditional.inner",
				["as"] = "@statement.outer",   ["is"] = "@statement.inner",
				["ad"] = "@comment.outer",     ["id"] = "@comment.inner",
				["am"] = "@call.outer",        ["im"] = "@call.inner",
			}
			for lhs, capture in pairs(select_maps) do
				for _, mode in ipairs({ "x", "o" }) do
					vim.keymap.set(mode, lhs, function()
						select.select_textobject(capture, "textobjects")
					end, { desc = "Select " .. capture })
				end
			end

			-- ── move (next / prev start / end) ──────────────────────────
			local function map_move(maps, fn, label)
				for lhs, capture in pairs(maps) do
					for _, mode in ipairs({ "n", "x", "o" }) do
						vim.keymap.set(mode, lhs, function()
							fn(capture, "textobjects")
						end, { desc = label .. " " .. capture })
					end
				end
			end

			map_move({
				["]m"] = "@function.outer",
				["]]"] = "@class.outer",
				["]o"] = "@loop.outer",
				["]s"] = "@statement.outer",
				["]c"] = "@conditional.outer",
			}, move.goto_next_start, "Next start")

			map_move({
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
				["[o"] = "@loop.outer",
				["[s"] = "@statement.outer",
				["[c"] = "@conditional.outer",
			}, move.goto_previous_start, "Prev start")

			map_move({
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			}, move.goto_next_end, "Next end")

			map_move({
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			}, move.goto_previous_end, "Prev end")

			-- ── swap parameters ─────────────────────────────────────────
			vim.keymap.set("n", "<leader>a", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Swap next parameter" })
			vim.keymap.set("n", "<leader>A", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Swap previous parameter" })
		end,
	},
}
