return {
	"nvim-telescope/telescope.nvim",
	event = "VeryLazy",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope-ui-select.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			enabled = vim.fn.executable("make") == 1,
		},
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			hidden = true,
			defaults = {
				prompt_prefix = "🔍 ",
				selection_caret = " ",
				path_display = { "smart" },
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.5,
					},
					width = 0.8,
					height = 0.8,
					preview_cutoff = 120,
				},
				sorting_strategy = "ascending",
				winblend = 0,
				mappings = {
					i = {
						["<C-h>"] = "which_key",
						["<esc>"] = actions.close,
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
			pickers = {
				find_files = {
					-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
					find_command = {
						"rg",
						"--files",
						"--hidden",
						"--glob",
						"!**/.git/*",
						"--glob",
						"!**/node_modules/**",
						"--glob",
						"!**/package-lock.json",
						"--glob",
						"!**/build/**",
						"--glob",
						"!**/.next/**",
						"-u",
					},
				},
			},
			extensions = {
				fzf = {
					case_mode = "respect_case", -- or "ignore_case" or "smart_case"
				},
				["ui-select"] = {
					require("telescope.themes").get_dropdown({}),
				},
			},
		})
		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "file_browser")
		pcall(telescope.load_extension, "ui-select")

		local builtin = require("telescope.builtin")

		function vim.find_files_from_project_git_root()
			local function is_git_repo()
				vim.fn.system("git rev-parse --is-inside-work-tree")
				return vim.v.shell_error == 0
			end
			local function get_git_root()
				local dot_git_path = vim.fn.finddir(".git", ".;")
				return vim.fn.fnamemodify(dot_git_path, ":h")
			end
			local opts = {}
			if is_git_repo() then
				opts = {
					cwd = get_git_root(),
				}
			end
			require("telescope.builtin").find_files(opts)
		end

		-- File Pickers
		vim.keymap.set("n", "<leader>ff", vim.find_files_from_project_git_root, { desc = "Find Files" })
		-- vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
		vim.keymap.set(
			"n",
			"<leader>fg",
			builtin.git_files,
			{ desc = "Fuzzy search through the output of git ls-files" }
		)
		vim.keymap.set(
			"n",
			"<leader>ss",
			builtin.grep_string,
			{ desc = "Searches for the string under your cursor or selection in your current working directory" }
		)
		vim.keymap.set("n", "<leader>/", builtin.live_grep, { desc = "Grep (root dir)" })

		-- Vim Pickers
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Lists open buffers in current neovim instance" })
		vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Lists previously open files" })
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search Help" })
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search Keymaps" })
		vim.keymap.set(
			"n",
			"<leader>ss",
			builtin.grep_string,
			{ desc = "Searches for the string under your cursor in current working directory" }
		)
		vim.keymap.set("n", "<leader>ui", builtin.colorscheme, { desc = "Lists available colorschemes" })
		vim.keymap.set("n", "<leader>sq", builtin.quickfix, { desc = "Lists items in the quickfix list" })
		vim.keymap.set("n", "<leader>sj", builtin.jumplist, { desc = "Lists Jump List entries" })
		vim.keymap.set("n", "<leader>sR", builtin.registers, { desc = "Lists vim registers" })

		-- Neovim LSP Pickers
		vim.keymap.set("n", "<leader>sr", builtin.lsp_references, { desc = "Lists vim registers" })
		vim.keymap.set(
			"n",
			"<leader>sd",
			builtin.diagnostics,
			{ desc = "Lists Diagnostics for all open buffers or a specific buffer" }
		)
		vim.keymap.set(
			"n",
			"gr",
			builtin.lsp_implementations,
			{ desc = "Goto the implementation of the word under the cursor" }
		)
		vim.keymap.set(
			"n",
			"gd",
			builtin.lsp_definitions,
			{ desc = "Goto the implementation of the word under the cursor" }
		)
		vim.keymap.set(
			"n",
			"gt",
			builtin.lsp_type_definitions,
			{ desc = "Goto the definition of the type of the word under the cursor" }
		)

		-- Git Pickers
		vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "List git commits with diff preview" })
		vim.keymap.set(
			"n",
			"<leader>gC",
			builtin.git_bcommits,
			{ desc = "Lists buffer's git commits with diff preview" }
		)
		vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Lists buffer's git commits with diff preview" })
		vim.keymap.set("n", "<leader>gS", builtin.git_stash, { desc = "Lists stash items in current repository" })

		-- Treesitter Picker
		vim.keymap.set(
			"n",
			"<leader>tt",
			builtin.treesitter,
			{ desc = "Lists Function names, variables, from Treesitter!" }
		)
	end,
}
