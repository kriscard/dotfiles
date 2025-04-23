-- LSP Plugins
return {
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by nvim-cmp
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- Map is a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					-- map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					-- Find references for the word under your cursor.
					-- map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					-- map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					-- map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					-- map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					-- map(
					-- 	"<leader>ws",
					-- 	require("telescope.builtin").lsp_dynamic_workspace_symbols,
					-- 	"[W]orkspace [S]ymbols"
					-- )

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
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

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local ts_ls_inlay_hints = {
				includeInlayEnumMemberValueHints = true, -- Shows numeric values next to enum members (e.g., enum Color { Red /* = 0 */ })
				includeInlayFunctionLikeReturnTypeHints = true, -- Displays return type hints for functions (e.g., function getData() /* : string */ {})
				includeInlayFunctionParameterTypeHints = true, -- Shows parameter type hints in function declarations (e.g., function process(data /* : string */))
				includeInlayParameterNameHints = "all", -- Displays parameter names at function call sites (e.g., calculate(/* amount: */ 100))
				includeInlayParameterNameHintsWhenArgumentMatchesName = true, -- Shows parameter names even when they match argument names (e.g., process(/* data: */ data))
				includeInlayPropertyDeclarationTypeHints = true, -- Displays type hints for property declarations (e.g., class User { name /* : string */ })
				includeInlayVariableTypeHints = true, -- Shows type hints for variables (e.g., const user /* : User */ = getUser())
				includeInlayVariableTypeHintsWhenTypeMatchesName = true, -- Displays type hints even when variable name matches type (e.g., const user /* : User */ = new User())
			}

			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							diagnostics = {
								globals = { "vim" },
								disable = { "missing-fields" },
							},
						},
					},
				},
				solargraph = {},
				bashls = {},
				cssls = {},
				graphql = {},
				html = {},
				jsonls = {},
				marksman = {},
				prettier = {},
				prettierd = {},
				prismals = {},
				sqlls = {},
				tailwindcss = {
					filetypes = { "typescriptreact", "javascriptreact", "html", "svelte" },
				},
				-- ts_ls = {
				-- 	settings = {
				-- 		maxTsServerMemory = 12288,
				-- 	},
				-- 	typescript = {
				-- 		inlayHints = ts_ls_inlay_hints,
				-- 	},
				-- 	javascript = {
				-- 		inlayHints = ts_ls_inlay_hints,
				-- 	},
				-- },
				ts_ls = {
					enabled = false,
				},
				vtsls = {
					-- explicitly add default filetypes, so that we can extend
					-- them in related extras
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
						"bun.lockb"
					),
					settings = {
						complete_function_calls = true,
						vtsls = {
							enableMoveToFileCodeAction = true,
							autoUseWorkspaceTsdk = true,
							experimental = {
								maxInlayHintLength = 30,
								completion = {
									enableServerSideFuzzyMatch = true,
								},
							},
						},
						typescript = {
							updateImportsOnFileMove = { enabled = "always" },
							suggest = {
								completeFunctionCalls = true,
							},
							inlayHints = {
								enumMemberValues = { enabled = true },
								functionLikeReturnTypes = { enabled = true },
								parameterNames = { enabled = "literals" },
								parameterTypes = { enabled = true },
								propertyDeclarationTypes = { enabled = true },
								variableTypes = { enabled = false },
							},
							maxTsServerMemory = 12288,
						},
					},
				},
				yamlls = {},
				stylua = {},
				eslint = {
					cmd = { "vscode-eslint-language-server", "--stdio", "--max-old-space-size=12288" },
					settings = {
						-- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
						workingDirectories = { mode = "auto" },
						format = true,
					},
					on_attach = function(_, bufnr)
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufnr,
							command = "EslintFixAll",
						})
					end,
				},
			}

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu.
			require("mason").setup({
				ui = {
					border = "rounded",
				},
			})

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	-- Autoformat
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
			default_format_opts = {
				async = true,
				timeout_ms = 500,
				lsp_format = "fallback",
			},
			format_after_save = {
				async = true,
				timeout_ms = 500,
				lsp_format = "fallback",
			},
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

	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {

			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					{
						"rafamadriz/friendly-snippets",
						config = function()
							require("luasnip.loaders.from_vscode").lazy_load()
						end,
					},
				},
			},
			"hrsh7th/cmp-emoji",
			"saadparwaiz1/cmp_luasnip",
			-- Adds other completion capabilities.
			--  nvim-cmp does not ship with all sources by default. They are split
			--  into multiple repos for maintenance purposes.
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"onsails/lspkind.nvim", -- vs-code like pictograms
			"windwp/nvim-ts-autotag",
			"windwp/nvim-autopairs",
			{ "petertriho/cmp-git", opts = {} },
			{ "roobert/tailwindcss-colorizer-cmp.nvim", opts = {} },
		},
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			table.insert(opts.sources, {
				name = "lazydev",
				group_index = 0, -- set group index to 0 to skip loading LuaLS completions
			})
			table.insert(opts.sources, { name = "emoji" })
		end,
		config = function()
			-- See `:help cmp`
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.event:on("menu_opened", function()
				vim.b.copilot_suggestion_hidden = true
			end)

			cmp.event:on("menu_closed", function()
				vim.b.copilot_suggestion_hidden = false
			end)

			luasnip.config.setup({})
			luasnip.filetype_extend("ruby", { "rails" })
			luasnip.filetype_extend("typescript", { "tsdoc" })
			luasnip.filetype_extend("javascript", { "jsdoc" })
			luasnip.filetype_extend("lua", { "luadoc" })
			luasnip.filetype_extend("python", { "pydoc" })
			luasnip.filetype_extend("rust", { "rustdoc" })
			luasnip.filetype_extend("cs", { "csharpdoc" })
			luasnip.filetype_extend("java", { "javadoc" })
			luasnip.filetype_extend("c", { "cdoc" })
			luasnip.filetype_extend("cpp", { "cppdoc" })
			luasnip.filetype_extend("php", { "phpdoc" })
			luasnip.filetype_extend("kotlin", { "kdoc" })
			luasnip.filetype_extend("ruby", { "rdoc" })
			luasnip.filetype_extend("sh", { "shelldoc" })

			-- setup() is also available as an alias
			-- Setup icons
			lspkind.init({
				mode = "symbol_text",
				preset = "codicons",
				symbol_map = {
					Array = " ",
					Boolean = "󰨙 ",
					Class = " ",
					Codeium = "󰘦 ",
					Color = " ",
					Control = " ",
					Collapsed = " ",
					Constant = "󰏿 ",
					Constructor = " ",
					Copilot = " ",
					Enum = " ",
					EnumMember = " ",
					Event = " ",
					Field = " ",
					File = " ",
					Folder = " ",
					Function = "󰊕 ",
					Interface = " ",
					Key = " ",
					Keyword = " ",
					Method = "󰊕 ",
					Module = " ",
					Namespace = "󰦮 ",
					Null = " ",
					Number = "󰎠 ",
					Object = " ",
					Operator = " ",
					Package = " ",
					Property = " ",
					Reference = " ",
					Snippet = "",
					String = " ",
					Struct = "󰆼 ",
					TabNine = "󰏚 ",
					Text = " ",
					TypeParameter = " ",
					Unit = " ",
					Value = " ",
					Variable = "󰀫 ",
				},
			})

			-- Tailwindcss Colorizer
			require("tailwindcss-colorizer-cmp").setup({

				color_square_width = 2,
			})

			cmp.config.formatting = {
				format = require("tailwindcss-colorizer-cmp").formatter,
			}

			require("nvim-autopairs").setup({})
			-- If you want to automatically add `(` after selecting a function or method
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

			cmp.setup({

				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				opts = function(_, opts)
					local format_kinds = opts.formatting.format

					opts.formatting.format = function(entry, item)
						format_kinds(entry, item) -- add icons
						return require("tailwindcss-colorizer-cmp").formatter(entry, item)
					end
				end,
				-- For an understanding of why these mappings were
				-- chosen, you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				mapping = cmp.mapping.preset.insert({
					-- Select the [n]ext item
					["<C-n>"] = cmp.mapping.select_next_item(),

					-- Select the [p]revious item
					["<C-p>"] = cmp.mapping.select_prev_item(),

					-- Scroll the documentation window [b]ack / [f]orward
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Accept ([y]es) the completion.
					--  This will auto-import if your LSP supports it.
					--  This will expand snippets if the LSP sent a snippet.
					["<C-y>"] = cmp.mapping.confirm({ select = true }),

					-- If you prefer more traditional completion keymaps,
					-- you can uncomment the following lines
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					-- ["<Tab>"] = cmp.mapping.select_next_item(),
					-- ["<S-Tab>"] = cmp.mapping.select_prev_item(),

					-- Manually trigger a completion from nvim-cmp.
					--  Generally you don't need this, because nvim-cmp will display
					--  completions whenever it has completion options available.
					["<C-Space>"] = cmp.mapping.complete({}),

					-- Think of <c-l> as moving to the right of your snippet expansion.
					--  So if you have a snippet that's like:
					--  function $name($args)
					--    $body
					--  end
					--
					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),

					-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
					--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
				}),
				sources = {
					{
						name = "lazydev",
						-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
						group_index = 0,
					},
					{ name = "nvim_lsp" },
					{ name = "copilot" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text", -- show only symbol annotations
						maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
						-- can also be a function to dynamically calculate max width such as
						-- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
						ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
						show_labelDetails = true, -- show labelDetails in menu. Disabled by default

						-- The function below will be called before any actual modifications from lspkind
						-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
						before = function(entry, vim_item)
							return vim_item
						end,
					}),
				},
			})
		end,
	},
}
