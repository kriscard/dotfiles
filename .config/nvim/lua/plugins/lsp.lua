return {
	"neovim/nvim-lspconfig",
	event = "BufReadPost",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		-- Install neodev for better nvim configuration and plugin authoring via lsp configurations
		"folke/neodev.nvim",
		"nvimtools/none-ls.nvim",
	},
	config = function()
		local masonLspConfig = require("mason-lspconfig")
		local mason = require("mason")
		local null_ls = require("null-ls")

		mason.setup({
			ui = {
				border = "rounded",
			},
		})

		-- Use neodev to configure lua_ls in nvim directories - must load before lspconfig
		require("neodev").setup()

		masonLspConfig.setup({
			automatic_installation = { exclude = { "solargraph" } },
		})

		-- Lsp server list https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
		local servers = {
			solargraph = {},
			bashls = {},
			cssls = {},
			graphql = {},
			html = {},
			jsonls = {},
			lua_ls = {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			},
			marksman = {},
			prismals = {},
			sqlls = {},
			tailwindcss = {},
			tsserver = {},
			yamlls = {},
			eslint = {
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			},
		}

		-- Default handlers for LSP
		local default_handlers = {
			["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
			["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
		}

		-- nvim-cmp supports additional completion capabilities
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local default_capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

		---@diagnostic disable-next-line: unused-local
		local on_attach = function(_client, buffer_number)
			-- Create a command `:Format` local to the LSP buffer
			vim.api.nvim_buf_create_user_command(buffer_number, "Format", function(_)
				vim.lsp.buf.format({
					filter = function(format_client)
						-- Use Prettier to format TS/JS if it's available
						return format_client.name ~= "tsserver" or not null_ls.is_registered("prettier")
					end,
				})
			end, { desc = "LSP: Format current buffer with LSP" })
		end

		-- Iterate over our servers and set them up
		for name, config in pairs(servers) do
			require("lspconfig")[name].setup({
				capabilities = default_capabilities,
				filetypes = config.filetypes,
				handlers = vim.tbl_deep_extend("force", {}, default_handlers, config.handlers or {}),
				on_attach = on_attach,
				settings = config.settings,
			})
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Enable completion triggered by <c-x><c-o>
				vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf }
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gd", function()
					require("telescope.builtin").lsp_definitions({ reuse_win = true })
				end, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gi", function()
					require("telescope.builtin").lsp_implementations({ reuse_win = true })
				end, opts)
				vim.keymap.set("n", "td", function()
					require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
				end, opts)
				vim.keymap.set("n", "rn", vim.lsp.buf.rename, opts)
				vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "gr", function()
					require("telescope.builtin").lsp_references({ reuse_win = true })
				end, opts)
				vim.keymap.set("n", "<space>f", function()
					vim.lsp.buf.format({ async = true })
				end, opts)
			end,
		})

		-- Configure borderd for LspInfo ui
		require("lspconfig.ui.windows").default_options.border = "rounded"
	end,
}
