return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	enabled = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",

			-- `build` is used to run some command when the plugin is installed/updated.
			-- This is only run then, not every time Neovim starts up.
			build = "make",

			-- `cond` is a condition used to determine whether this plugin should be
			-- installed and loaded.
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		{
			"nvim-telescope/telescope-live-grep-args.nvim",
			-- This will not install any breaking changes.
			-- For major updates, this must be adjusted manually.
			version = "^1.0.0",
		},
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				prompt_prefix = "🔍 ",
				selection_caret = " ",
				path_display = { "smart" },
				layout_strategy = "horizontal",
				mappings = {
					i = {
						["<c-enter>"] = "to_fuzzy_refine",
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
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
				fzf = {
					case_mode = "respect_case", -- or "ignore_case" or "smart_case"
				},
			},
		})

		-- Enable Telescope extensions if they are installed
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		-- See `:help telescope.builtin`
		local builtin = require("telescope.builtin")
		local telescope_extensions = require("telescope").extensions

		local function find_files_from_current_dir()
			local opts = {
				cwd = vim.fn.expand("%:p:h"), -- %:p:h gives the current file's directory
			}
			require("telescope.builtin").find_files(opts)
		end

		local function find_files_from_root_dir()
			local opts = {
				cwd = vim.fn.getcwd(),
			}
			require("telescope.builtin").find_files(opts)
		end

		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
		vim.keymap.set("n", "<leader>ff", find_files_from_current_dir, { desc = "[S]earch [F]iles current directory" })
		vim.keymap.set("n", "<leader>fF", find_files_from_root_dir, { desc = "[S]earch [F]iles root directory" })
		vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "[S]earch git [F]iles" })
		vim.keymap.set("n", "<leader>ss", function()
			builtin.spell_suggest(require("telescope.themes").get_dropdown({ previewer = false }))
		end, { desc = "[S]earch [S]pelling suggestions" })
		vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
		vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
		vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
		vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
		vim.keymap.set("n", "<leader>td", ":TodoTelescope<CR>", { desc = "[Search] [T]odo comments" })

		-- Slightly advanced example of overriding default behavior and theme
		vim.keymap.set("n", "<leader>/", function()
			-- You can pass additional configuration to Telescope to change the theme, layout, etc.
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })
		vim.keymap.set(
			"n",
			"<leader>sG",
			telescope_extensions.live_grep_args.live_grep_args,
			{ noremap = true, desc = "Grep (root dir) with args" }
		)

		-- It's also possible to pass additional configuration options.
		--  See `:help telescope.builtin.live_grep()` for information about particular keys
		vim.keymap.set("n", "<leader>s/", function()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[S]earch [/] in Open Files" })

		-- Shortcut for searching your Neovim configuration files
		vim.keymap.set("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files" })
	end,
}
