return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		plugins = { spelling = true },
		-- Clean, organized keymap groups
		spec = {
			mode = { "n", "v" },
			-- Primary groups (alphabetically organized)
			{ "<leader>a", group = "ai", icon = { icon = " ", color = "purple" } },
			{ "<leader>b", group = "buffer", icon = { icon = " ", color = "cyan" } },
			{ "<leader>c", group = "code", icon = { icon = " ", color = "yellow" } },
			{ "<leader>d", group = "debug", icon = { icon = " ", color = "red" } },
			{ "<leader>f", group = "find", icon = { icon = " ", color = "green" } },
			{ "<leader>g", group = "git", icon = { icon = " ", color = "orange" } },
			{ "<leader>gh", group = "hunk", icon = { icon = "󰊢 ", color = "orange" } },
			{ "<leader>h", group = "harpoon", icon = { icon = "󱡀 ", color = "blue" } },
			{ "<leader>i", group = "issue", icon = { icon = " ", color = "purple" } },
			{ "<leader>k", group = "http", icon = { icon = "󰖟 ", color = "green" } },
			{ "<leader>P", group = "package", icon = { icon = " ", color = "red" } },
			{ "<leader>S", group = "spectre", icon = { icon = " ", color = "orange" } },
			{ "<leader>o", group = "obsidian", icon = { icon = "󰠗 ", color = "purple" } },
			{ "<leader>p", group = "pr", icon = { icon = " ", color = "cyan" } },
			{ "<leader>q", group = "session", icon = { icon = " ", color = "red" } },
			{ "<leader>r", group = "refactor", icon = { icon = " ", color = "blue" } },
			{ "<leader>s", group = "search", icon = { icon = " ", color = "green" } },
			{ "<leader>t", group = "test", icon = { icon = "󰙨 ", color = "yellow" } },
			{ "<leader>u", group = "ui", icon = { icon = " ", color = "cyan" } },
			{ "<leader>w", group = "window", icon = { icon = " ", color = "blue" } },
			{ "<leader>x", group = "diagnostics", icon = { icon = " ", color = "red" } },
			-- Navigation groups
			{ "[", group = "prev" },
			{ "]", group = "next" },
			{ "g", group = "goto" },
			{ "gs", group = "surround" },
		},
	},
}
