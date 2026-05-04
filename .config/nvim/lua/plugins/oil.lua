-- Buffer-mode toggle: oil has no built-in toggle for buffer mode
-- (only toggle_float()). Open if not in oil, close (return to previous
-- buffer) if currently in oil.
local function toggle_oil()
	if vim.bo.filetype == "oil" then
		require("oil").close()
	else
		vim.cmd("Oil")
	end
end

return {
	"stevearc/oil.nvim",
	cmd = "Oil",
	keys = {
		{ "<leader>fe", toggle_oil, desc = "[F]ile [E]xplorer (Oil)" },
		{ "<leader>-", toggle_oil, desc = "Open Oil" },
	},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- Autocmd: cleaner display in oil buffers — no colorcolumn, no
		-- relative numbers (the descending count from cursor is noise in a
		-- file picker), no list chars.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			callback = function()
				vim.opt_local.colorcolumn = ""
				vim.opt_local.relativenumber = false
				vim.opt_local.number = false
				vim.opt_local.list = false
			end,
		})

		-- Helper function to parse git command output
		local function parse_output(proc)
			local result = proc:wait()
			local ret = {}
			if result.code == 0 then
				for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
					-- Remove trailing slash
					line = line:gsub("/$", "")
					ret[line] = true
				end
			end
			return ret
		end

		-- Build git status cache
		local function new_git_status()
			return setmetatable({}, {
				__index = function(self, key)
					local ignore_proc = vim.system(
						{ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
						{
							cwd = key,
							text = true,
						}
					)
					local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
						cwd = key,
						text = true,
					})
					local ret = {
						ignored = parse_output(ignore_proc),
						tracked = parse_output(tracked_proc),
					}
					rawset(self, key, ret)
					return ret
				end,
			})
		end

		-- Toggle file detail view
		local detail = false

		-- Initialize git status cache
		local git_status = new_git_status()

		-- Load oil module
		local oil = require("oil")

		-- Set up oil with all options combined
		oil.setup({
			-- Send deleted files to system trash instead of permanent rm
			delete_to_trash = true,

			-- Floating window styling: rounded border, mauve title, capped sizing
			-- to match the hover/blink.cmp surface (base bg, surface1 border).
			float = {
				padding = 2,
				max_width = math.min(100, math.floor(vim.o.columns * 0.7)),
				max_height = math.min(40, math.floor(vim.o.lines * 0.8)),
				border = "rounded",
				win_options = { winblend = 0 },
				preview_split = "auto",
				get_win_title = function(winid)
					local bufnr = vim.api.nvim_win_get_buf(winid)
					local dir = require("oil").get_current_dir(bufnr)
					if not dir then
						return " 󰉋 Oil "
					end
					local home = vim.env.HOME
					if home and vim.startswith(dir, home) then
						dir = "~" .. dir:sub(#home + 1)
					end
					-- Trim trailing slash; if still long, show last 2 components
					dir = dir:gsub("/$", "")
					if #dir > 50 then
						local parts = vim.split(dir, "/")
						if #parts >= 2 then
							dir = ".../" .. parts[#parts - 1] .. "/" .. parts[#parts]
						end
					end
					return " 󰉋 " .. dir .. " "
				end,
			},

			-- Preview pane: opens to the right by default in buffer mode,
			-- updates as cursor moves, skips huge files to keep things fast.
			preview_win = {
				update_on_cursor_moved = true,
				preview_method = "fast_scratch",
				disable_preview = function(filename)
					local stat = vim.uv.fs_stat(filename)
					return stat ~= nil and stat.size > 1024 * 1024 -- skip files > 1 MB
				end,
				win_options = {},
			},

			-- Confirmation dialog (the "DELETE .DS_Store [Y]es [N]o" prompt) —
			-- without these the dialog renders as bare text on the buffer.
			confirmation = {
				border = "rounded",
				win_options = { winblend = 0 },
				min_width = { 40, 0.4 },
				max_width = 0.6,
				min_height = { 5, 0.1 },
				max_height = 0.9,
			},

			-- Progress popup (long copy/move ops) matches the same style
			progress = {
				border = "rounded",
				win_options = { winblend = 0 },
				minimized_border = "none",
				max_width = 0.6,
				min_width = { 40, 0.4 },
				max_height = { 10, 0.9 },
				min_height = { 5, 0.1 },
			},

			-- ssh prompt styling (rare but consistent)
			ssh = { border = "rounded" },

			-- :h help popup styling
			keymaps_help = { border = "rounded" },

			-- Cleaner buffer display (Oil's defaults are already good — repeated
			-- here so they survive future user-level tweaks to global options)
			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},

			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-w>"] = "actions.select_vsplit",
				["<C-enter>"] = "actions.select_split", -- this is used to navigate left
				["<C-t>"] = "actions.select_tab",
				["<C-p>"] = "actions.preview",
				["<C-x>"] = "actions.close",
				["<C-r>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = "actions.tcd",
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["gd"] = { -- Toggle file detail view
					desc = "Toggle file detail view",
					callback = function()
						detail = not detail
						if detail then
							require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
						else
							require("oil").set_columns({ "icon" })
						end
					end,
				},
			},
			use_default_keymaps = false,
			columns = {
				"icon",
			},
			view_options = {
				-- Show files and directories that start with "."
				show_hidden = true,
				-- Natural sort: file2.lua before file10.lua. "fast" disables
				-- on huge dirs to keep things snappy.
				natural_order = "fast",
				-- Custom function for determining hidden files
				is_hidden_file = function(name, bufnr)
					local dir = oil.get_current_dir(bufnr)
					local is_dotfile = vim.startswith(name, ".") and name ~= ".."
					-- if no local directory (e.g. for ssh connections), just hide dotfiles
					if not dir then
						return is_dotfile
					end
					-- dotfiles are considered hidden unless tracked
					if is_dotfile then
						return not git_status[dir].tracked[name]
					else
						-- Check if file is gitignored
						return git_status[dir].ignored[name]
					end
				end,
			},
		})

		-- Add the refresh hook after setup
		-- This avoids errors if the structure of oil.actions differs
		vim.defer_fn(function()
			-- Try to hook into refresh, but avoid errors
			local success, actions = pcall(require, "oil.actions")
			if
				success
				and actions
				and actions.refresh
				and type(actions.refresh) == "table"
				and actions.refresh.callback
			then
				local orig_refresh = actions.refresh.callback
				actions.refresh.callback = function(...)
					git_status = new_git_status()
					orig_refresh(...)
				end
			end
		end, 100)
	end,
}
