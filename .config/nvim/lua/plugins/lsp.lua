-- ══════════════════════════════════════════════════════════════════════════════
-- LSP Configuration (Neovim 0.11+ native API)
-- ══════════════════════════════════════════════════════════════════════════════
-- Uses vim.lsp.config() / vim.lsp.enable() (via mason-lspconfig automatic_enable).
-- nvim-lspconfig is kept on the runtime path so that its lsp/<server>.lua files
-- (cmd / filetypes / root_markers defaults) are auto-discovered by Neovim 0.11+;
-- we never call require("lspconfig").<name>.setup() ourselves.
return {
	-- Lua development support (must load before lua_ls attaches)
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- Mason: install LSP servers / formatters / linters
	{ "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },

	-- nvim-lspconfig: kept solely so its lsp/<server>.lua defaults are on rtp.
	-- We do NOT call its setup() — vim.lsp.config + vim.lsp.enable replace it.
	{ "neovim/nvim-lspconfig" },

	-- LSP wiring (driven off mason-lspconfig + mason-tool-installer)
	{
		"mason-org/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.compat",
			"folke/lazydev.nvim",
		},
		config = function()
			-- ═══════════════════════════════════════════════════════════════════
			-- LspAttach: per-buffer keymaps and features
			-- ═══════════════════════════════════════════════════════════════════
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Organize imports / ESLint fixAll — single-line replacement for the
					-- old hand-rolled apply_code_actions helper (used deprecated 0.10 APIs).
					map("<leader>oi", function()
						vim.lsp.buf.code_action({
							apply = true,
							context = { only = { "source.fixAll.eslint" }, diagnostics = {} },
						})
					end, "[O]rganize [I]mports (ESLint)")

					map("<leader>rf", function()
						vim.lsp.buf.code_action({ context = { only = { "refactor" }, diagnostics = {} } })
					end, "[R]e[f]actor")

					map("<leader>gsd", vim.lsp.buf.definition, "[G]o to [S]ource [D]efinition")
					map("<leader>e", vim.diagnostic.open_float, "Lin[e] diagnostics")

					-- Styled hover: rounded border, capped width, wrap, mauve-accent
					-- title with a Nerd Font icon. Matches blink.cmp's float surface.
					map("K", function()
						vim.lsp.buf.hover({
							border = "rounded",
							max_width = math.min(80, math.floor(vim.o.columns * 0.7)),
							max_height = math.floor(vim.o.lines * 0.5),
							wrap = true,
							focusable = true,
							title = " 󰋽 Hover ",
							title_pos = "left",
						})
					end, "Hover documentation")

					-- Signature help: same surface, no title (it's brief by design)
					vim.keymap.set({ "i", "s" }, "<C-k>", function()
						vim.lsp.buf.signature_help({
							border = "rounded",
							max_width = math.min(80, math.floor(vim.o.columns * 0.7)),
							wrap = true,
							title = " 󰊕 Signature ",
							title_pos = "left",
						})
					end, { buffer = event.buf, desc = "LSP: Signature help" })

					vim.keymap.set("n", "<leader>rn", function()
						return ":IncRename " .. vim.fn.expand("<cword>")
					end, { buffer = event.buf, expr = true, desc = "LSP: [R]e[n]ame" })

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if not client then
						return
					end

					-- Highlight references on cursor hold
					if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
						local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- Inlay hints
					if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
						vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- ═══════════════════════════════════════════════════════════════════
			-- Global capabilities (blink.cmp adds completion capabilities)
			-- vim.lsp.config('*', ...) sets defaults applied to every server.
			-- ═══════════════════════════════════════════════════════════════════
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			-- ═══════════════════════════════════════════════════════════════════
			-- Per-server overrides (merged on top of nvim-lspconfig's lsp/<name>.lua
			-- defaults and the '*' defaults above).
			-- ═══════════════════════════════════════════════════════════════════

			-- Lua
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
						runtime = { version = "LuaJIT" },
						diagnostics = {
							globals = { "vim", "Snacks", "require" },
							disable = { "missing-fields" },
						},
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			})

			-- TypeScript / JavaScript (vtsls)
			vim.lsp.config("vtsls", {
				filetypes = {
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
				root_markers = { "tsconfig.json", "jsconfig.json", "package.json" },
				settings = {
					complete_function_calls = true,
					vtsls = {
						enableMoveToFileCodeAction = true,
						autoUseWorkspaceTsdk = true,
						experimental = {
							maxInlayHintLength = 10,
							completion = { enableServerSideFuzzyMatch = false },
						},
					},
					typescript = {
						tsserver = { maxTsServerMemory = 4096 },
						updateImportsOnFileMove = { enabled = "always" },
						disableAutomaticTypeAcquisition = true,
						suggest = {
							completeFunctionCalls = false,
							includeCompletionsForModuleExports = true,
							includeCompletionsForImportStatements = true,
						},
						inlayHints = {
							includeInlayEnumMemberValueHints = false,
							includeInlayFunctionLikeReturnTypeHints = false,
							includeInlayFunctionParameterTypeHints = false,
							includeInlayParameterNameHints = "none",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayPropertyDeclarationTypeHints = false,
							includeInlayVariableTypeHints = false,
							includeInlayVariableTypeHintsWhenTypeMatchesName = false,
						},
						preferences = {
							importModuleSpecifierPreference = "non-relative",
							includePackageJsonAutoImports = "off",
							organizeImportsIgnoreCase = false,
							organizeImportsCollation = "ordinal",
							organizeImportsLocale = "en",
							organizeImportsNumericCollation = false,
							organizeImportsAccentCollation = false,
							organizeImportsCaseFirst = "lower",
						},
						watchOptions = {
							excludeDirectories = {
								"**/node_modules",
								"**/.git",
								"**/dist",
								"**/.next",
								"**/build",
								"**/coverage",
								"**/out",
								"**/.turbo",
								"**/.cache",
							},
							excludeFiles = {
								"**/.eslintrc.js",
								"**/webpack.config.js",
								"**/rollup.config.js",
								"**/vite.config.js",
							},
						},
					},
					javascript = {
						suggest = {
							completeFunctionCalls = false,
							includeCompletionsForModuleExports = true,
							includeCompletionsForImportStatements = true,
						},
						preferences = {
							importModuleSpecifierPreference = "non-relative",
							includePackageJsonAutoImports = "off",
						},
					},
				},
			})

			vim.lsp.config("eslint", {
				cmd = { "vscode-eslint-language-server", "--stdio", "--max-old-space-size=4096" },
				settings = {
					workingDirectories = { mode = "auto" },
					format = true,
				},
			})

			vim.lsp.config("biome", {
				filetypes = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact", "css" },
				root_markers = { "biome.json", "biome.jsonc" },
			})

			-- CSS / styling
			vim.lsp.config("cssls", {
				settings = { css = { lint = { unknownAtRules = "ignore" } } },
			})
			vim.lsp.config("tailwindcss", {
				filetypes = { "typescriptreact", "javascriptreact", "html", "svelte" },
			})
			vim.lsp.config("unocss", {
				filetypes = {
					"html", "javascriptreact", "rescript", "typescriptreact",
					"vue", "svelte", "astro", "css", "postcss", "sass", "scss", "stylus",
				},
			})
			vim.lsp.config("stylelint_lsp", {
				filetypes = { "css", "scss", "sass", "less", "postcss" },
				settings = { stylelintplus = { autoFixOnSave = true, autoFixOnFormat = true } },
			})
			vim.lsp.config("emmet_ls", {
				filetypes = { "html", "css", "scss", "sass", "less" },
			})

			-- Markup / data
			vim.lsp.config("graphql", { filetypes = { "graphql" } })

			-- Markdown
			vim.lsp.config("ltex", {
				filetypes = { "markdown", "text", "gitcommit" },
				settings = {
					ltex = {
						language = "en-US",
						checkFrequency = "save",
						dictionary = {
							["en-US"] = {
								"Neovim", "LSP", "treesitter", "dotfiles",
								"keymaps", "lua", "obsidian", "tmux", "nvim", "config",
							},
						},
						disabledRules = {
							["en-US"] = { "MORFOLOGIK_RULE_EN_US", "WHITESPACE_RULE", "EN_QUOTES" },
						},
					},
				},
			})
			vim.lsp.config("mdx_analyzer", {
				filetypes = { "mdx" },
				init_options = { typescript = { enabled = true } },
			})

			-- ═══════════════════════════════════════════════════════════════════
			-- Mason install: LSP servers via mason-lspconfig (with auto-enable),
			-- standalone tools via mason-tool-installer.
			-- ═══════════════════════════════════════════════════════════════════
			local lsp_servers = {
				"lua_ls",
				"vtsls", "eslint", "biome",
				"cssls", "tailwindcss", "unocss", "stylelint_lsp", "emmet_ls",
				"html", "jsonls", "yamlls", "graphql",
				"marksman", "ltex", "mdx_analyzer",
				"bashls", "prismals", "sqlls", "rust_analyzer",
				"dockerls", "docker_compose_language_service",
			}

			require("mason-lspconfig").setup({
				ensure_installed = lsp_servers,
				-- automatic_enable replaces the deprecated v1 `handlers` block.
				-- Excluding ts_ls because we use vtsls instead.
				automatic_enable = { exclude = { "ts_ls" } },
			})

			require("mason-tool-installer").setup({
				auto_update = true,
				run_on_start = false,
				-- Standalone formatters / linters (NOT LSP servers — those go in
				-- mason-lspconfig's ensure_installed). Pass mason package names here.
				ensure_installed = { "stylua", "prettier", "prettierd" },
			})

			-- ═══════════════════════════════════════════════════════════════════
			-- Diagnostics
			-- ═══════════════════════════════════════════════════════════════════
			vim.diagnostic.config({
				float = {
					border = "rounded",
					title = " 󰂃 Diagnostics ",
					title_pos = "left",
					source = "if_many",
				},
				underline = true,
				update_in_insert = false,
				virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
				severity_sort = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = " ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			})
		end,
	},
}
