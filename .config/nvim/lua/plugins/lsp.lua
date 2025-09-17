-- LSP Plugins
return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },

	-- ──────────────────────────────────────────────────────────────────────────────
	-- LSP
	-- ──────────────────────────────────────────────────────────────────────────────
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.compat", -- capabilities shim for Blink
		},
		config = function()
			-- Configure rounded borders for LSP floating windows
			require("lspconfig.ui.windows").default_options.border = "rounded"

			-- Helper: apply first returned code actions for a given context
			local function apply_code_actions(bufnr, only, timeout_ms)
				bufnr = bufnr or vim.api.nvim_get_current_buf()
				local params = vim.lsp.util.make_range_params(0, "utf-8")
				local context = { only = only, diagnostics = vim.diagnostic.get(bufnr) }
				params = vim.tbl_extend("force", params, { context = context })
				local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, timeout_ms or 2000)
				if not results then
					return
				end
				for client_id, res in pairs(results) do
					for _, action in ipairs(res.result or {}) do
						if action.edit then
							vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
						end
						if action.command then
							local client = vim.lsp.get_client_by_id(client_id)
							if client then
								client.request(action.command, bufnr)
							end
						end
					end
				end
			end

			-- Organize imports: VTSLS organize → ESLint fix-all (simple-import-sort)
			local function organize_imports_react(bufnr)
				apply_code_actions(bufnr, { "source.organizeImports" }, 2000) -- VTSLS
				vim.defer_fn(function()
					apply_code_actions(bufnr, { "source.fixAll.eslint" }, 3000) -- ESLint (simple-import-sort)
				end, 100)
			end

			-- Keymaps on LSP attach
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					map("<leader>oi", function()
						organize_imports_react(event.buf)
					end, "[O]rganize [I]mports")
					map("<leader>rf", function()
						vim.lsp.buf.code_action({ context = { only = { "refactor" }, diagnostics = {} } })
					end, "[R]e[f]actor")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("<leader>gsd", vim.lsp.buf.definition, "[G]o to [S]ource [D]efinition")
				end,
			})

			-- Capabilities
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, blink_capabilities = pcall(function()
				return require("blink.compat").get_lsp_capabilities()
			end)
			if ok and blink_capabilities then
				capabilities = vim.tbl_deep_extend("force", capabilities, blink_capabilities)
			end

			-- TS inlay hints preset
			local ts_ls_inlay_hints = {
				includeInlayEnumMemberValueHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
			}

			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
							diagnostics = { globals = { "vim" }, disable = { "missing-fields" } },
						},
					},
				},
				bashls = {},
				cssls = { settings = { css = { lint = { unknownAtRules = "ignore" } } } },
				graphql = {},
				html = {},
				jsonls = {},
				marksman = {},
				prismals = {},
				sqlls = {},
				tailwindcss = { filetypes = { "typescriptreact", "javascriptreact", "html", "svelte" } },
				rust_analyzer = {},
				gopls = {},
				dockerls = {},
				docker_compose_language_service = {},
				-- Keep Emmet out of TSX/JSX
				emmet_ls = { filetypes = { "html", "css", "scss", "sass", "less" } },
				vtsls = {
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx",
					},
					root_dir = require("lspconfig").util.root_pattern(
						".git",
						"pnpm-workspace.yaml",
						"pnpm-lock.yaml",
						"yarn.lock",
						"package-lock.json",
						"bun.lockb",
						"lerna.json",
						"nx.json"
					),
					settings = {
						complete_function_calls = true,
						vtsls = {
							enableMoveToFileCodeAction = true,
							autoUseWorkspaceTsdk = true,
							experimental = {
								maxInlayHintLength = 30,
								completion = { enableServerSideFuzzyMatch = true },
							},
						},
						typescript = {
							updateImportsOnFileMove = { enabled = "always" },
							suggest = {
								completeFunctionCalls = true,
								includeCompletionsForModuleExports = true,
								includeCompletionsForImportStatements = true,
							},
							inlayHints = ts_ls_inlay_hints,
							preferences = {
								importModuleSpecifierPreference = "non-relative",
								includePackageJsonAutoImports = "auto",
							},
							maxTsServerMemory = 12288,
							watchOptions = {
								excludeDirectories = { "**/node_modules", "**/.git", "**/dist", "**/.next", "**/build" },
							},
						},
						javascript = {
							suggest = {
								completeFunctionCalls = true,
								includeCompletionsForModuleExports = true,
								includeCompletionsForImportStatements = true,
							},
							preferences = {
								importModuleSpecifierPreference = "non-relative",
								includePackageJsonAutoImports = "auto",
							},
						},
					},
				},
				mdx_analyzer = { filetypes = { "mdx" } }, -- optional; remove if unused
				biome = {
					filetypes = {
						"javascript",
						"javascriptreact",
						"json",
						"jsonc",
						"typescript",
						"typescriptreact",
						"css",
					},
					single_file_support = false,
					root_dir = require("lspconfig").util.root_pattern("biome.json", "biome.jsonc"),
				},
				yamlls = {},
				unocss = {
					filetypes = {
						"html",
						"javascriptreact",
						"rescript",
						"typescriptreact",
						"vue",
						"svelte",
						"astro",
						"css",
						"postcss",
						"sass",
						"scss",
						"stylus",
					},
				},
				stylelint_lsp = {
					filetypes = { "css", "scss", "sass", "less", "postcss" },
					settings = { stylelintplus = { autoFixOnSave = true, autoFixOnFormat = true } },
				},
				eslint = {
					cmd = { "vscode-eslint-language-server", "--stdio", "--max-old-space-size=12288" },
					settings = {
						workingDirectories = { mode = "auto" },
						format = true,
					},
					on_attach = function(_, bufnr)
						vim.api.nvim_create_autocmd("BufWritePre", { buffer = bufnr, command = "EslintFixAll" })
					end,
				},
			}

			local ensure_installed = vim.tbl_keys(servers)
			vim.list_extend(ensure_installed, {
				"stylua",
				"prettier",
				"prettierd",
				"@unocss/language-server",
				"stylelint-lsp",
				"@biomejs/biome",
			})

			require("mason").setup({ ui = { border = "rounded" } })
			require("mason-tool-installer").setup({
				auto_update = true,
				run_on_start = true,
				start_delay = 3000,
				debounce_hours = 12,
				ensure_installed = ensure_installed,
			})

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						-- prefer vtsls over ts_ls to avoid conflicts
						if server_name == "ts_ls" then
							return
						end
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})

			vim.diagnostic.config({
				float = { border = "rounded" },
				underline = true,
				update_in_insert = false,
				virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
				severity_sort = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = " ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			})
		end,
	},
	-- ──────────────────────────────────────────────────────────────────────────────
	-- Autoformat (Prettier, Stylua)
	-- ──────────────────────────────────────────────────────────────────────────────
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[C]ode [F]ormat",
			},
		},
		opts = {
			notify_on_error = false,
			default_format_opts = { async = true, timeout_ms = 500, lsp_format = "fallback" },
			format_after_save = { async = true, timeout_ms = 500, lsp_format = "fallback" },
			formatters_by_ft = {
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				graphql = { "prettierd", "prettier", stop_after_first = true },
				lua = { "stylua" },
				html = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				mdx = { "prettierd", "prettier", stop_after_first = true },
				astro = { "prettierd", "prettier", stop_after_first = true },
				ruby = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	-- ──────────────────────────────────────────────────────────────────────────────
	-- Snippet Engine & Snippets
	-- ──────────────────────────────────────────────────────────────────────────────
	{
		"L3MON4D3/LuaSnip",
		lazy = true,
		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					local ls = require("luasnip")

					-- Load friendly-snippets but exclude filetypes we want to override
					require("luasnip.loaders.from_vscode").lazy_load({
						exclude = { "typescriptreact", "typescript", "javascript", "javascriptreact" }
					})

					-- Load only custom snippets for the filetypes we want to override
					require("luasnip.loaders.from_vscode").lazy_load({
						paths = { vim.fn.stdpath("config") .. "/snippets" }
					})

					-- For any remaining conflicts, we can clear and reload specific filetypes
					vim.api.nvim_create_autocmd("FileType", {
						pattern = { "typescriptreact", "typescript", "javascript", "javascriptreact" },
						callback = function()
							-- Ensure custom snippets take priority by reloading them
							require("luasnip.loaders.from_vscode").lazy_load({
								paths = { vim.fn.stdpath("config") .. "/snippets" }
							})
						end
					})
				end,
			},
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
	},

	-- ──────────────────────────────────────────────────────────────────────────────
	-- Completion UI (Blink)
	-- ──────────────────────────────────────────────────────────────────────────────
	{
		"saghen/blink.cmp",
		version = "*",
		dependencies = {
			"saghen/blink.compat",
			-- optional extra sources used below:
			"moyiz/blink-emoji.nvim",
			"Kaiser-Yang/blink-cmp-dictionary",
			"Kaiser-Yang/blink-cmp-git",
		},
		opts = {
			keymap = {
				preset = "default",
				["<CR>"] = { "accept", "fallback" }, -- no auto-select
				["<Tab>"] = { "snippet_forward", "accept", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },
				["<C-Space>"] = { "show" },
				["<C-n>"] = { "select_next" },
				["<C-p>"] = { "select_prev" },
				["<C-l>"] = { "snippet_forward" },
				["<C-h>"] = { "snippet_backward" },
			},

			performance = { debounce = 40, throttle = 20, fetching_timeout = 200, max_view_entries = 40 },

			completion = {
				list = { selection = { preselect = false, auto_insert = false } },
				accept = {
					auto_brackets = {
						enabled = true,
						kind_resolution = { enabled = true }, -- ✅ must be a table
						semantic_token_resolution = { enabled = true }, -- ✅ must be a table
					},
				},
				documentation = { auto_show = true, auto_show_delay_ms = 400 },
				ghost_text = { enabled = true, show_with_menu = false },
				menu = {
					draw = {
						columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
					},
				},
			},

			sources = {
				default = { "snippets", "lsp", "path", "buffer", "emoji", "git", "dictionary" },
				per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
				providers = {
					lazydev = { module = "lazydev.integrations.blink" },
					emoji = { module = "blink-emoji" },
					git = { module = "blink-cmp-git" },
					snippets = {
						score_offset = 100, -- Higher score for custom snippets
					},
					dictionary = {
						module = "blink-cmp-dictionary",
						name = "Dict",
						score_offset = 20,
						max_items = 8,
						min_keyword_length = 3,
						opts = {
							dictionary_directories = { vim.fn.expand("~/.config/nvim/dictionaries") },
							dictionary_files = {
								vim.fn.expand("~/.config/nvim/spell/en.utf-8.add"),
								vim.fn.expand("~/.config/nvim/spell/es.utf-8.add"),
							},
						},
					},
				},
			},

			snippets = { preset = "luasnip" },
			appearance = { use_nvim_cmp_as_default = true },
		},
	},
}
