return {
	{
		"zbirenbaum/copilot.lua",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				copilot_node_command = vim.fn.expand("$HOME") .. "/.asdf/installs/nodejs/22.20.0/bin/node", -- Hardcoded to v22 for copilot while projects can use different versions
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
