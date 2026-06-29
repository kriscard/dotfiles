-- ══════════════════════════════════════════════════════════════════════════════
-- LSP Plugin Spec (Neovim 0.11+ native API)
-- ══════════════════════════════════════════════════════════════════════════════
-- This file is intentionally thin. Real config lives next to it:
--   • lua/plugins/lsp/servers.lua    — per-server settings + install list
--   • lua/plugins/lsp/attach.lua     — LspAttach autocmd, buffer keymaps
--   • lua/plugins/lsp/ui.lua         — diagnostic + UI surface config
-- And reusable LSP utilities under the kriscard namespace:
--   • lua/kriscard/util/code_action.lua  — async code-action picker
--   • lua/kriscard/util/lsp_action.lua   — direct-action-by-kind helpers
--
-- Lazy.nvim's `{ import = "plugins" }` only auto-loads top-level *.lua files in
-- lua/plugins/, so the lsp/ subdirectory below us isn't treated as plugin specs —
-- those files are plain Lua modules we require() from this file's config().
--
-- We use vim.lsp.config() / vim.lsp.enable() (via mason-lspconfig automatic_enable).
-- nvim-lspconfig is kept on the runtime path so its lsp/<server>.lua defaults are
-- auto-discovered by Neovim 0.11+; we never call require("lspconfig").<name>.setup().

return {
	-- Lua development support (must load before lua_ls attaches).
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- Mason: install LSP servers / formatters / linters.
	{ "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },

	-- nvim-lspconfig: kept solely so its lsp/<server>.lua defaults are on rtp.
	-- We do NOT call its setup() — vim.lsp.config + vim.lsp.enable replace it.
	{ "neovim/nvim-lspconfig" },

	-- LSP wiring (driven off mason-lspconfig + mason-tool-installer).
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
			local servers = require("plugins.lsp.servers")

			require("plugins.lsp.ui").setup()
			require("plugins.lsp.attach").setup()

			-- Wildcard defaults applied to every server.
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			-- Per-server overrides merged on top of nvim-lspconfig defaults + '*'.
			for name, cfg in pairs(servers.specs) do
				vim.lsp.config(name, cfg)
			end

			-- Mason install. automatic_enable replaces the deprecated v1 handlers
			-- block. Exclusions:
			--   • ts_ls — we use vtsls instead
			--   • ltex  — we use harper_ls (faster, Rust); ltex is still on rtp
			--             via nvim-lspconfig's lsp/ltex.lua, so we must explicitly
			--             disable it to prevent it from auto-attaching to markdown.
			require("mason-lspconfig").setup({
				ensure_installed = servers.install,
				automatic_enable = { exclude = { "ts_ls", "ltex" } },
			})
			vim.lsp.enable("ltex", false)

			require("mason-tool-installer").setup({
				auto_update = true,
				run_on_start = false,
				ensure_installed = servers.tools,
			})
		end,
	},
}
