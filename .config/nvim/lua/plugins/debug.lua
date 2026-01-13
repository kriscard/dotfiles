return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",
		"mxsdev/nvim-dap-vscode-js",
	},
	keys = {
		-- Standard debug commands with function keys
		{ "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
		{ "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
		{ "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
		{ "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
		{ "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },

		-- Leader key mappings
		{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
		{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional Breakpoint" },
		{ "<leader>dl", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "Log Point" },
		{ "<leader>dr", function() require("dap").repl.open() end, desc = "Open REPL" },
		{ "<leader>dt", function() require("dapui").toggle() end, desc = "Toggle UI" },
		{ "<leader>ds", function() require("dap").continue() end, desc = "Start/Continue" },
		{ "<leader>dq", function() require("dap").close() end, desc = "Quit Session" },
		{ "<leader>dR", function() require("dap").run_last() end, desc = "Run Last Session" },
		{ "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Hover Variables" },
		{
			"<leader>df",
			function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end,
			desc = "Show Frames",
		},
		{
			"<leader>dS",
			function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end,
			desc = "Show Scopes",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("mason-nvim-dap").setup({
			ensure_installed = { "node2" },
			automatic_installation = true,
			handlers = {
				function(config)
					require("mason-nvim-dap").default_setup(config)
				end,
			},
		})

		require("dap-vscode-js").setup({
			node_path = "node",
			debugger_path = vim.fn.expand("~/.local/share/nvim/vscode-js-debug"),
			debugger_cmd = { "js-debug-adapter" },
			adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
			log_file_path = vim.fn.stdpath("cache") .. "/dap_vscode_js.log",
			log_file_level = vim.log.levels.DEBUG,
			log_console_level = vim.log.levels.ERROR,
		})

		for _, language in ipairs({ "typescript", "javascript" }) do
			dap.configurations[language] = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach",
					processId = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "launch",
					name = "Debug Jest Tests",
					runtimeExecutable = "node",
					runtimeArgs = { "./node_modules/jest/bin/jest.js", "--runInBand" },
					rootPath = "${workspaceFolder}",
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
					internalConsoleOptions = "neverOpen",
				},
			}
		end

		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
			controls = {
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
		})

		dap.listeners.after.event_initialized["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		dap.listeners.after.event_error["error_handler"] = function(_, body)
			vim.notify("DAP Error: " .. vim.inspect(body), vim.log.levels.ERROR)
		end
	end,
}
