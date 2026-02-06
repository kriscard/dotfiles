return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ timeout_ms = 3000, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[C]ode [F]ormat",
		},
	},
	opts = {
		notify_on_error = true,
		default_format_opts = { timeout_ms = 3000, lsp_format = "fallback" },
		format_after_save = { timeout_ms = 3000, lsp_format = "fallback" },
		formatters = {
			stylua = {
				command = vim.fn.stdpath("data") .. "/mason/bin/stylua",
				args = { "--stdin-filepath", "$FILENAME", "-" },
				stdin = true,
			},
		},
		formatters_by_ft = {
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			jsonc = { "prettierd", "prettier", stop_after_first = true },
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
}
