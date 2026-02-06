-- ══════════════════════════════════════════════════════════════════════════════
-- LSP Configuration
-- ══════════════════════════════════════════════════════════════════════════════
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

	-- LSP Config
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.compat",
			"folke/lazydev.nvim",
		},
		config = function()
			require("lspconfig.ui.windows").default_options.border = "rounded"

			-- ═══════════════════════════════════════════════════════════════════
			-- Helper Functions
			-- ═══════════════════════════════════════════════════════════════════

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
								vim.lsp.buf.execute_command(action.command)
							end
						end
					end
				end
			end

			local function organize_imports_react(bufnr)
				apply_code_actions(bufnr, { "source.fixAll.eslint" }, 3000)
			end

			-- ═══════════════════════════════════════════════════════════════════
			-- LspAttach Autocmd
			-- ═══════════════════════════════════════════════════════════════════

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Buffer-specific LSP mappings
					map("<leader>oi", function()
						organize_imports_react(event.buf)
					end, "[O]rganize [I]mports (ESLint)")

					map("<leader>rf", function()
						vim.lsp.buf.code_action({ context = { only = { "refactor" }, diagnostics = {} } })
					end, "[R]e[f]actor")

					map("<leader>gsd", vim.lsp.buf.definition, "[G]o to [S]ource [D]efinition")
					map("<leader>e", vim.diagnostic.open_float, "Lin[e] diagnostics")

					-- Highlight references on cursor hold
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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

					-- Toggle inlay hints
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- ═══════════════════════════════════════════════════════════════════
			-- Capabilities
			-- ═══════════════════════════════════════════════════════════════════

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, blink_capabilities = pcall(function()
				return require("blink.compat").get_lsp_capabilities()
			end)
			if ok and blink_capabilities then
				capabilities = vim.tbl_deep_extend("force", capabilities, blink_capabilities)
			end

			-- ═══════════════════════════════════════════════════════════════════
			-- Server Configurations
			-- ═══════════════════════════════════════════════════════════════════

			local servers = {
				-- Lua
				lua_ls = {
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
				},

				-- Web Development
				vtsls = {
					filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
					root_dir = require("lspconfig").util.root_pattern(".git", "pnpm-workspace.yaml", "pnpm-lock.yaml", "yarn.lock", "package-lock.json", "bun.lockb", "lerna.json", "nx.json"),
					settings = {
						complete_function_calls = true,
						vtsls = {
							enableMoveToFileCodeAction = false,
							autoUseWorkspaceTsdk = true,
							experimental = {
								maxInlayHintLength = 10,
								completion = { enableServerSideFuzzyMatch = false },
							},
						},
						typescript = {
							updateImportsOnFileMove = { enabled = "always" },
							suggest = {
								completeFunctionCalls = false,
								includeCompletionsForModuleExports = false,
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
							maxTsServerMemory = 4096,
							watchOptions = {
								excludeDirectories = { "**/node_modules", "**/.git", "**/dist", "**/.next", "**/build", "**/coverage", "**/out", "**/.turbo", "**/.cache" },
								excludeFiles = { "**/.eslintrc.js", "**/webpack.config.js", "**/rollup.config.js", "**/vite.config.js" },
							},
						},
						javascript = {
							suggest = {
								completeFunctionCalls = false,
								includeCompletionsForModuleExports = false,
								includeCompletionsForImportStatements = true,
							},
							preferences = {
								importModuleSpecifierPreference = "non-relative",
								includePackageJsonAutoImports = "off",
							},
						},
					},
				},

				eslint = {
					cmd = { "vscode-eslint-language-server", "--stdio", "--max-old-space-size=12288" },
					settings = {
						workingDirectories = { mode = "auto" },
						format = true,
					},
				},

				biome = {
					filetypes = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact", "css" },
					single_file_support = false,
					root_dir = require("lspconfig").util.root_pattern("biome.json", "biome.jsonc"),
				},

				-- CSS/Styling
				cssls = { settings = { css = { lint = { unknownAtRules = "ignore" } } } },
				tailwindcss = { filetypes = { "typescriptreact", "javascriptreact", "html", "svelte" } },
				unocss = { filetypes = { "html", "javascriptreact", "rescript", "typescriptreact", "vue", "svelte", "astro", "css", "postcss", "sass", "scss", "stylus" } },
				stylelint_lsp = {
					filetypes = { "css", "scss", "sass", "less", "postcss" },
					settings = { stylelintplus = { autoFixOnSave = true, autoFixOnFormat = true } },
				},
				emmet_ls = { filetypes = { "html", "css", "scss", "sass", "less" } },

				-- Markup/Data
				html = {},
				jsonls = {},
				yamlls = {},
				graphql = { filetypes = { "graphql" } },

				-- Markdown
				marksman = {},
				ltex = {
					filetypes = { "markdown", "text", "gitcommit" },
					settings = {
						ltex = {
							language = "en-US",
							checkFrequency = "save",
							dictionary = {
								["en-US"] = { "Neovim", "LSP", "treesitter", "dotfiles", "keymaps", "lua", "obsidian", "tmux", "nvim", "config" },
							},
							disabledRules = {
								["en-US"] = { "MORFOLOGIK_RULE_EN_US", "WHITESPACE_RULE", "EN_QUOTES" },
							},
						},
					},
				},
				mdx_analyzer = {
					filetypes = { "mdx" },
					init_options = { typescript = { enabled = true } },
				},

				-- Backend/Infra
				bashls = {},
				prismals = {},
				sqlls = {},
				rust_analyzer = {},
				gopls = {},
				dockerls = {},
				docker_compose_language_service = {},
			}

			-- ═══════════════════════════════════════════════════════════════════
			-- Mason Setup
			-- ═══════════════════════════════════════════════════════════════════

			local ensure_installed = vim.tbl_keys(servers)
			vim.list_extend(ensure_installed, {
				"stylua",
				"prettier",
				"prettierd",
				"unocss-language-server",
				"stylelint-lsp",
				"biome",
				"mdx-analyzer",
				"ltex-ls",
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
						if server_name == "ts_ls" then
							return -- Use vtsls instead
						end
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})

			-- ═══════════════════════════════════════════════════════════════════
			-- Diagnostics
			-- ═══════════════════════════════════════════════════════════════════

			vim.diagnostic.config({
				float = { border = "rounded" },
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
