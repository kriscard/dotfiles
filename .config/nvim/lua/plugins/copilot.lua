return {
	"zbirenbaum/copilot.lua",
	event = { "BufEnter" },
	config = function()
		require("copilot").setup({
			suggestion = {
				enabled = false,
			},
			panel = { enabled = false },
		})
	end,
}
