-- Autocmd to remove colorcolumn in oil buffers
vim.api.nvim_create_autocmd("FileType", {
	pattern = "oil",
	callback = function()
		vim.opt_local.colorcolumn = ""
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

return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- Load oil module
		local oil = require("oil")

		-- Set up oil with all options combined
		oil.setup({
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
