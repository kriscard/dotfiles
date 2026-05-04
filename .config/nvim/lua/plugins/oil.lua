-- Buffer-mode toggle: oil has no built-in toggle for buffer mode (only
-- toggle_float). Open Oil if not in oil, close (return to previous buffer)
-- if currently in oil.
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
		-- Cleaner display in oil buffers — no colorcolumn, no relative
		-- numbers (the descending count from cursor is noise in a file
		-- picker). Plain absolute line numbers stay (inherited from global).
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			callback = function()
				vim.opt_local.colorcolumn = ""
				vim.opt_local.relativenumber = false
			end,
		})

		-- Git-aware hidden-file logic. Caches `git ls-files --ignored ...`
		-- and `git ls-tree HEAD` per directory so dotfiles that ARE tracked
		-- (e.g. .gitignore, .zshenv) stay visible while gitignored files hide.
		local function parse_output(proc)
			local result = proc:wait()
			local ret = {}
			if result.code == 0 then
				for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
					ret[(line:gsub("/$", ""))] = true
				end
			end
			return ret
		end

		local function new_git_status()
			return setmetatable({}, {
				__index = function(self, key)
					local ignore_proc = vim.system(
						{ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
						{ cwd = key, text = true }
					)
					local tracked_proc =
						vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, { cwd = key, text = true })
					local ret = {
						ignored = parse_output(ignore_proc),
						tracked = parse_output(tracked_proc),
					}
					rawset(self, key, ret)
					return ret
				end,
			})
		end

		local git_status = new_git_status()
		local detail = false
		local oil = require("oil")

		oil.setup({
			-- Send to Trash instead of permanent rm (macOS-aware)
			delete_to_trash = true,
			columns = { "icon" },
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-w>"] = "actions.select_vsplit",
				["<C-enter>"] = "actions.select_split",
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
				["gd"] = {
					desc = "Toggle file detail view",
					callback = function()
						detail = not detail
						oil.set_columns(detail and { "icon", "permissions", "size", "mtime" } or { "icon" })
					end,
				},
			},
			use_default_keymaps = false,
			view_options = {
				show_hidden = true,
				natural_order = "fast",
				is_hidden_file = function(name, bufnr)
					local dir = oil.get_current_dir(bufnr)
					local is_dotfile = vim.startswith(name, ".") and name ~= ".."
					if not dir then
						return is_dotfile
					end
					if is_dotfile then
						return not git_status[dir].tracked[name]
					end
					return git_status[dir].ignored[name]
				end,
			},
		})

		-- Refresh the git-status cache when the user hits :Oil refresh
		vim.defer_fn(function()
			local ok, actions = pcall(require, "oil.actions")
			if ok and actions and actions.refresh and type(actions.refresh) == "table" and actions.refresh.callback then
				local orig = actions.refresh.callback
				actions.refresh.callback = function(...)
					git_status = new_git_status()
					orig(...)
				end
			end
		end, 100)
	end,
}
