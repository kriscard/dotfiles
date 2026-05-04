return {
	"catppuccin/nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			integrations = {
				blink_cmp = true,
				bufferline = true,
				copilot_vim = true,
				dap = true,
				dap_ui = true,
				diffview = true,
				gitsigns = true,
				harpoon = true,
				mason = true,
				mini = { enabled = true },
				native_lsp = { enabled = true },
				noice = true,
				notify = true,
				octo = true,
				snacks = true,
				treesitter = true,
				treesitter_context = true,
				trouble = true,
				which_key = true,
			},
		custom_highlights = function(colors)
				return {
					-- Blink completion: match editor bg so rounded border corners blend
					BlinkCmpMenu = { bg = colors.base },
					BlinkCmpMenuBorder = { fg = colors.surface1, bg = colors.base },
					BlinkCmpMenuSelection = { bg = colors.surface0 },
					BlinkCmpDoc = { bg = colors.base },
					BlinkCmpDocBorder = { fg = colors.surface1, bg = colors.base },
					BlinkCmpSignatureHelp = { bg = colors.base },
					BlinkCmpSignatureHelpBorder = { fg = colors.surface1, bg = colors.base },

					-- Native LSP floats (vim.lsp.buf.hover, signature_help, diagnostics) —
					-- styled to match blink so the hover popup feels like part of the
					-- same UI surface. surface1 border + base bg + mauve title accent.
					NormalFloat = { bg = colors.base },
					FloatBorder = { fg = colors.surface1, bg = colors.base },
					FloatTitle = { fg = colors.mauve, bg = colors.base, bold = true },

					-- Diagnostic floats: keep severity color but unify bg with hover
					DiagnosticFloatingError = { fg = colors.red, bg = colors.base },
					DiagnosticFloatingWarn = { fg = colors.yellow, bg = colors.base },
					DiagnosticFloatingHint = { fg = colors.teal, bg = colors.base },
					DiagnosticFloatingInfo = { fg = colors.sky, bg = colors.base },

					-- Active parameter in signature help — use mauve accent
					LspSignatureActiveParameter = { fg = colors.mauve, bold = true, underline = true },
				}
			end,
		})

		vim.cmd.colorscheme("catppuccin-macchiato")
	end,
}
