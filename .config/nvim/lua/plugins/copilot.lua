return {
	{
		"zbirenbaum/copilot.lua",
		event = "InsertEnter",
		config = function()
			-- Dynamically find Node.js via asdf
			local function get_node_path()
				local asdf_node = vim.fn.expand("$HOME") .. "/.asdf/shims/node"
				if vim.fn.executable(asdf_node) == 1 then
					return asdf_node
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
