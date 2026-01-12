return {
	{
		"zbirenbaum/copilot.lua",
		event = "InsertEnter",
		config = function()
			-- Find Node.js 22+ from asdf installs (shim may resolve to wrong version)
			local function get_node_path()
				local asdf_nodejs_dir = vim.fn.expand("$HOME") .. "/.asdf/installs/nodejs"
				local handle = io.popen("ls -1 " .. asdf_nodejs_dir .. " 2>/dev/null | sort -V")
				if handle then
					for version in handle:lines() do
						local major = tonumber(version:match("^(%d+)"))
						if major and major >= 22 then
							local node_bin = asdf_nodejs_dir .. "/" .. version .. "/bin/node"
							if vim.fn.executable(node_bin) == 1 then
								handle:close()
								return node_bin
							end
						end
					end
					handle:close()
				end
				return "node" -- Fallback to system node
			end

			require("copilot").setup({
				copilot_node_command = get_node_path(), -- Auto-detect Node.js version via asdf
				suggestion = {
					enabled = true,
					auto_trigger = true,
					hide_during_completion = true,
					debounce = 75,
					keymap = {
						accept = "<C-l>",
						accept_word = false,
						accept_line = false,
						next = "<C-n>",
						prev = "<C-p>",
						dismiss = "<C-]>",
					},
				},
				panel = { enabled = false },
				filetypes = {
					yaml = false,
					markdown = false,
					help = false,
					gitcommit = false,
					gitrebase = false,
					hgcommit = false,
					svn = false,
					cvs = false,
					["."] = false,
				},
			})
		end,
	},
}
