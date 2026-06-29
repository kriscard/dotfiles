-- Direct code-action-by-kind helpers (LazyVim pattern).
--
-- Per LSP 3.18 spec, context.only filters which kinds the server computes — so
-- passing one specific kind is the fastest path because the server skips work
-- for every other kind. Use these for actions you'd pick blindly anyway:
-- "add missing imports", "fix all", "remove unused".
--
-- Kinds use `.` hierarchy with prefix matching. `source.addMissingImports` would
-- match `.ts`, `.eslint`, `.biome`, etc. We use the `.ts` suffix to scope to vtsls
-- explicitly.

local M = {}

-- Returns a function that fires textDocument/codeAction with a single kind and
-- auto-applies the result. Empty diagnostics — we want the kind, not the
-- per-line diag context.
function M.kind(name)
	return function()
		vim.lsp.buf.code_action({
			apply = true,
			context = { only = { name }, diagnostics = {} },
		})
	end
end

-- TS import organize, two-step (nicknisi pattern). source.organizeImports alone
-- moves the existing imports around but doesn't drop unused ones first; chaining
-- removeUnusedImports → organizeImports gives a clean result. Defer the second
-- step so the first edit settles before the next request is built.
function M.organize_imports_ts()
	vim.lsp.buf.code_action({
		apply = true,
		context = { only = { "source.removeUnusedImports.ts" }, diagnostics = {} },
	})
	vim.defer_fn(function()
		vim.lsp.buf.code_action({
			apply = true,
			context = { only = { "source.organizeImports.ts" }, diagnostics = {} },
		})
	end, 100)
end

-- Run a vtsls-style workspace/executeCommand (e.g. typescript.goToSourceDefinition)
-- and dispatch the returned Location[] sensibly: jump for one result, qflist for
-- many, notify for none. Mirrors LazyVim's `LazyVim.lsp.execute({ open = true })`.
---@param client vim.lsp.Client
---@param bufnr integer
---@param opts { command: string, arguments?: any[], title?: string }
function M.execute(client, bufnr, opts)
	client:request("workspace/executeCommand", {
		command = opts.command,
		arguments = opts.arguments,
	}, function(err, result)
		if err then
			vim.notify(("LSP %s failed: %s"):format(opts.command, err.message or "unknown"), vim.log.levels.ERROR)
			return
		end
		if not result or (type(result) == "table" and #result == 0) then
			vim.notify(("No results for %s"):format(opts.title or opts.command), vim.log.levels.INFO)
			return
		end
		if type(result) == "table" and result[1] then
			if #result == 1 then
				vim.lsp.util.show_document(result[1], client.offset_encoding, { focus = true })
			else
				vim.fn.setqflist({}, " ", {
					title = opts.title or opts.command,
					items = vim.lsp.util.locations_to_items(result, client.offset_encoding),
				})
				vim.cmd("copen")
			end
		end
	end, bufnr)
end

return M
