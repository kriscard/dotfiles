return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope-file-browser.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")
		local fb_actions = telescope.extensions.file_browser.actions

		telescope.setup({
			defaults = {
				path_display = { "truncate " },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
			extensions = {
				file_browser = {
					hidden = true,
					respect_gitignore = true,
					hijack_netrw = true,
					mappings = {
						["i"] = {
							["<A-t>"] = fb_actions.change_cwd,
							["<C-t>"] = actions.select_tab,
						},
					},
				},
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "ignore_case",
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("file_browser")
		telescope.load_extension("harpoon")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>fm", "<cmd>Telescope harpoon marks<cr>", { desc = "Find harpoon marks" })
		keymap.set("n", "<leader>fd", function()
			builtin.diagnostics()
		end)
		keymap.set(
			"n",
			"<leader>fF",
			"<cmd>Telescope file_browser path=%:p:h<cr>",
			{ desc = "Open file browser (current dir)" }
		)
		keymap.set("n", "<leader>fh", function()
			builtin.help_tags()
		end)
		keymap.set("n", "\\\\", function()
			builtin.buffers()
		end)
	end,
}
