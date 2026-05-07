-- Diagnostic + LSP UI surface (floats, signs, virtual text).
-- Mirrors LazyVim's vim.diagnostic.config — the de-facto convention. Overlapping
-- diagnostics from multiple sources (e.g., vtsls + eslint + oxlint all flagging
-- unused vars) are shown with `source = "if_many"` prefixes. To reduce overlap,
-- disable redundant rules at the linter/tsconfig level, not in the editor.
-- Hover and signature_help styling lives next to its keymap in attach.lua.

local M = {}

function M.setup()
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
end

return M
