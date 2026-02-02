return {
	"catppuccin/nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			integrations = {
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
			float = {
				transparent = false,
				solid = false,
			},
		})

		vim.cmd.colorscheme("catppuccin-macchiato")
	end,
}
