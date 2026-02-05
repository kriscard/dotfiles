return {
	"catppuccin/nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			integrations = {
				blink_cmp = true,
				bufferline = true,
				cmp = true,
				copilot_vim = true,
				dap = true,
				dap_ui = true,
				diffview = true,
				gitsigns = true,
				harpoon = true,
				illuminate = true,
				mason = true,
				mini = { enabled = true },
				native_lsp = { enabled = true },
				neotree = true,
				noice = true,
				notify = true,
				octo = true,
				snacks = true,
				symbols_outline = true,
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
				}
			end,
		})

		vim.cmd.colorscheme("catppuccin-macchiato")
	end,
}
