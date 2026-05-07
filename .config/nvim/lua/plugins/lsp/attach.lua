-- Single LspAttach autocmd. Per-buffer keymaps and capability-gated features.
-- Capability gating uses client:supports_method(), which respects dynamic
-- registration — a server that registers a capability only after attach (e.g.
-- inlayHint after workspace settle) will still get its hooks set up.

local M = {}

local methods = vim.lsp.protocol.Methods

-- LSP shouldn't attach to plugin-managed virtual buffers (Octo PR drafts,
-- Diffview hunks, Fugitive blame). They're not real source files; LSP features
-- are noise at best, errors at worst. dmmulroy/.dotfiles uses this pattern.
local VIRTUAL_BUFFER_PREFIXES = { "octo://", "diffview://", "fugitive://", "gitsigns://" }

local function is_virtual_buffer(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	for _, prefix in ipairs(VIRTUAL_BUFFER_PREFIXES) do
		if bufname:sub(1, #prefix) == prefix then
			return true
		end
	end
	return false
end

local function map(buf, mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
end

local function buffer_keymaps(buf)
	local action = require("kriscard.util.lsp_action")

	-- ─── Picker-based ───────────────────────────────────────────────────────────
	-- ESLint fixAll (slow, file-wide; single-shot)
	map(buf, "n", "<leader>oi", function()
		vim.lsp.buf.code_action({
			apply = true,
			context = { only = { "source.fixAll.eslint" }, diagnostics = {} },
		})
	end, "[O]rganize [I]mports (ESLint)")

	-- Refactor-only code actions (vtsls)
	map(buf, "n", "<leader>rf", function()
		vim.lsp.buf.code_action({ context = { only = { "refactor" }, diagnostics = {} } })
	end, "[R]e[f]actor")

	-- ─── Direct kind keymaps (bypass picker, instant feedback) ──────────────────
	-- Each fires exactly one kind to vtsls; servers that don't register the kind
	-- return [] without computing anything. Wall-clock ~50–150ms.
	map(buf, "n", "<leader>cM", action.kind("source.addMissingImports.ts"), "Add [M]issing imports (TS)")
	map(buf, "n", "<leader>cF", action.kind("source.fixAll.ts"), "[F]ix all (TS)")
	map(buf, "n", "<leader>cR", action.kind("source.removeUnused.ts"), "[R]emove unused (TS)")
	map(buf, "n", "<leader>cO", action.organize_imports_ts, "[O]rganize imports (TS, two-step)")

	-- Source definition (skips type aliases — useful in TS)
	map(buf, "n", "<leader>gsd", vim.lsp.buf.definition, "[G]o to [S]ource [D]efinition")

	-- Line diagnostics (float)
	map(buf, "n", "<leader>e", vim.diagnostic.open_float, "Lin[e] diagnostics")

	-- Styled hover: rounded border, capped width, mauve-accent title.
	map(buf, "n", "K", function()
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

	-- Signature help (insert + select modes)
	vim.keymap.set({ "i", "s" }, "<C-k>", function()
		vim.lsp.buf.signature_help({
			border = "rounded",
			max_width = math.min(80, math.floor(vim.o.columns * 0.7)),
			wrap = true,
			title = " 󰊕 Signature ",
			title_pos = "left",
		})
	end, { buffer = buf, desc = "LSP: Signature help" })

	-- Rename (delegates to inc-rename plugin)
	vim.keymap.set("n", "<leader>rn", function()
		return ":IncRename " .. vim.fn.expand("<cword>")
	end, { buffer = buf, expr = true, desc = "LSP: [R]e[n]ame" })

	-- Health check for the LSP subsystem (new in 0.12)
	map(buf, "n", "<leader>lh", "<cmd>checkhealth vim.lsp<cr>", "[L]SP [H]ealth check")
end

-- CursorHold reference highlights — only wire if the client supports it.
local function setup_document_highlight(buf)
	local hi = vim.api.nvim_create_augroup("kriscard-lsp-highlight", { clear = false })
	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
		buffer = buf,
		group = hi,
		callback = vim.lsp.buf.document_highlight,
	})
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = buf,
		group = hi,
		callback = vim.lsp.buf.clear_references,
	})
	vim.api.nvim_create_autocmd("LspDetach", {
		group = vim.api.nvim_create_augroup("kriscard-lsp-detach", { clear = true }),
		callback = function(e2)
			vim.lsp.buf.clear_references()
			vim.api.nvim_clear_autocmds({ group = "kriscard-lsp-highlight", buffer = e2.buf })
		end,
	})
end

local function setup_inlay_hints(buf)
	vim.lsp.inlay_hint.enable(true, { bufnr = buf })
	map(buf, "n", "<leader>th", function()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
	end, "[T]oggle Inlay [H]ints")
end

-- vtsls-specific commands (LazyVim parity). Skips type aliases, finds file-wide
-- references, switches TS workspace version. These are vtsls workspace commands
-- (not standard LSP), so they only attach when vtsls is the client.
local function setup_vtsls_keymaps(client, buf)
	local action = require("kriscard.util.lsp_action")

	-- gD: source definition (skips type-alias indirection — better than vim.lsp.buf.definition for TS)
	map(buf, "n", "gD", function()
		local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
		action.execute(client, buf, {
			command = "typescript.goToSourceDefinition",
			arguments = { params.textDocument.uri, params.position },
			title = "Source Definitions",
		})
	end, "[G]oto Source [D]efinition (TS)")

	-- gR: list all references in the current file
	map(buf, "n", "gR", function()
		action.execute(client, buf, {
			command = "typescript.findAllFileReferences",
			arguments = { vim.uri_from_bufnr(buf) },
			title = "File References",
		})
	end, "File [R]eferences (TS)")

	-- <leader>cV: pick TS workspace version (useful in monorepos)
	map(buf, "n", "<leader>cV", function()
		client:request("workspace/executeCommand", {
			command = "typescript.selectTypeScriptVersion",
		}, function() end, buf)
	end, "Select TS [V]ersion")
end

-- Oxlint provides :LspOxlintFixAll as a buffer-local user command (registered
-- by nvim-lspconfig's lsp/oxlint.lua on_attach). Bind a parallel to <leader>oi.
local function setup_oxlint_keymaps(buf)
	map(buf, "n", "<leader>oO", "<cmd>LspOxlintFixAll<cr>", "[O]xlint fix all")
end

function M.setup()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("kriscard-lsp-attach", { clear = true }),
		callback = function(event)
			local buf = event.buf

			-- Detach from plugin-managed virtual buffers. vim.schedule so the
			-- detach doesn't race with the rest of LspAttach setup.
			if is_virtual_buffer(buf) then
				vim.schedule(function()
					vim.lsp.buf_detach_client(buf, event.data.client_id)
				end)
				return
			end

			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if not client then
				return
			end

			buffer_keymaps(buf)

			-- Per-client keymaps (only register where the server is active)
			if client.name == "vtsls" then
				setup_vtsls_keymaps(client, buf)
			elseif client.name == "oxlint" then
				setup_oxlint_keymaps(buf)
			end

			if client:supports_method(methods.textDocument_documentHighlight, buf) then
				setup_document_highlight(buf)
			end

			if client:supports_method(methods.textDocument_inlayHint, buf) then
				setup_inlay_hints(buf)
			end
		end,
	})
end

return M
