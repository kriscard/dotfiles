-- Async code-action picker.
-- Native vim.lsp.buf.code_action waits for ALL attached LSPs (1000ms cap) before
-- opening the picker. We fan out manually, apply per-server filters per the LSP
-- 3.18 spec, and open the picker once kept clients respond — backstop only if a
-- client truly hangs.
--
-- ESLint specifics (see vscode-eslint-language-server source):
--   • The server returns two kinds: `quickfix` (cached, fast) and
--     `source.fixAll.eslint` (full lint pass, slow ~200–600ms).
--   • Asking with `context.only = { "quickfix" }` skips the slow path.
--   • Quickfixes only exist for diagnostics on the cursor line — if there are
--     none, the request returns []. We skip the round-trip in that case.
--   • Use <leader>oi for the explicit slow `source.fixAll.eslint` one-shot.
--
-- Visual mode delegates to native (correct visual-range handling > minor speedup).

local M = {}

local methods = vim.lsp.protocol.Methods

-- Hard backstop: open the picker even if a kept client never responds.
M.hard_cap_ms = 2000

-- Servers fully excluded from the fan-out (kept for forward use; empty by default).
M.skip = {}

local function apply_action(client, bufnr, action)
	local function do_apply(a)
		if a.edit then
			vim.lsp.util.apply_workspace_edit(a.edit, client.offset_encoding)
		end
		if a.command then
			local cmd = type(a.command) == "table" and a.command or a
			client:exec_cmd(cmd, { bufnr = bufnr })
		end
	end
	if not action.edit and client:supports_method(methods.codeAction_resolve) then
		client:request(methods.codeAction_resolve, action, function(err, resolved)
			do_apply((not err and resolved) or action)
		end, bufnr)
	else
		do_apply(action)
	end
end

-- Per-client request shaping. Eslint gets context.only = { "quickfix" } so the
-- server skips computing source.fixAll.eslint. Other servers get the unfiltered
-- context (vtsls's refactors, biome's suggested fixes, etc.).
local function context_for(client_name, lsp_diagnostics)
	local ctx = {
		diagnostics = lsp_diagnostics,
		triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked,
	}
	if client_name == "eslint" then
		ctx.only = { "quickfix" }
	end
	return ctx
end

function M.run()
	local mode = vim.api.nvim_get_mode().mode
	if mode == "v" or mode == "V" then
		return vim.lsp.buf.code_action()
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	local lnum = vim.api.nvim_win_get_cursor(win)[1] - 1

	-- Cursor-line diagnostics: collect LSP-format payload + flag whether eslint
	-- has anything to say here. Skipping eslint when it doesn't saves a round-trip.
	local diagnostics = {}
	local has_eslint_diag = false
	for _, d in ipairs(vim.diagnostic.get(bufnr, { lnum = lnum })) do
		if d.user_data and d.user_data.lsp then
			table.insert(diagnostics, d.user_data.lsp)
		end
		if d.source == "eslint" then
			has_eslint_diag = true
		end
	end

	local clients = vim.tbl_filter(function(c)
		if M.skip[c.name] then
			return false
		end
		if c.name == "eslint" and not has_eslint_diag then
			return false
		end
		return true
	end, vim.lsp.get_clients({ bufnr = bufnr, method = methods.textDocument_codeAction }))

	if #clients == 0 then
		vim.notify("No code action providers", vim.log.levels.WARN)
		return
	end

	local items = {}
	local pending = #clients
	local opened = false

	local function open_picker()
		if opened then
			return
		end
		opened = true
		if #items == 0 then
			vim.notify("No code actions", vim.log.levels.INFO)
			return
		end
		vim.ui.select(items, {
			prompt = "Code action:",
			format_item = function(it)
				return string.format("[%s] %s", it.client_name, it.action.title)
			end,
		}, function(choice)
			if not choice then
				return
			end
			local client = vim.lsp.get_client_by_id(choice.client_id)
			if client then
				apply_action(client, bufnr, choice.action)
			end
		end)
	end

	vim.defer_fn(open_picker, M.hard_cap_ms)

	for _, client in ipairs(clients) do
		local params = vim.lsp.util.make_range_params(win, client.offset_encoding)
		params.context = context_for(client.name, diagnostics)
		client:request(methods.textDocument_codeAction, params, function(err, result)
			pending = pending - 1
			if not err and result then
				for _, action in ipairs(result) do
					-- Spec 3.16+: actions can be marked disabled with a reason.
					-- Skip them — they'd just clutter the picker.
					if not action.disabled then
						table.insert(items, {
							client_id = client.id,
							client_name = client.name,
							action = action,
						})
					end
				end
			end
			if pending == 0 then
				open_picker()
			end
		end, bufnr)
	end
end

return M
