return {
	"mistweaverco/kulala.nvim",
	ft = "http",
	keys = {
		{ "<leader>kr", function() require("kulala").run() end, desc = "Run Request" },
		{ "<leader>ka", function() require("kulala").run_all() end, desc = "Run All Requests" },
		{ "<leader>kp", function() require("kulala").jump_prev() end, desc = "Previous Request" },
		{ "<leader>kn", function() require("kulala").jump_next() end, desc = "Next Request" },
		{ "<leader>ki", function() require("kulala").inspect() end, desc = "Inspect Current Request" },
		{ "<leader>kt", function() require("kulala").toggle_view() end, desc = "Toggle Headers/Body" },
		{ "<leader>kc", function() require("kulala").copy() end, desc = "Copy as cURL" },
		{ "<leader>ke", function() require("kulala").set_selected_env() end, desc = "Select Environment" },
	},
	opts = {
		-- Display mode: "split" or "float"
		display_mode = "split",
		-- Split direction: "vertical" or "horizontal"
		split_direction = "vertical",
		-- Default environment for requests
		default_env = "dev",
		-- Enable debug mode
		debug = false,
	},
}
