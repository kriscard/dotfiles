return {
	"mfussenegger/nvim-dap",
	dependencies = {
		-- Creates a beautiful debugger UI
		"rcarriga/nvim-dap-ui",

		-- Required dependency for nvim-dap-ui
		"nvim-neotest/nvim-nio",

		-- Installs the debug adapters for you
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",

		-- Add your own debuggers here
		"mxsdev/nvim-dap-vscode-js",
	},
	keys = function(_, keys)
		local dap = require("dap")
		local dapui = require("dapui")
		return {
			-- Standard debug commands with more intuitive keys
			{ "<F5>", dap.continue, desc = "Debug: Start/Continue" },
			{ "<F9>", dap.toggle_breakpoint, desc = "Debug: Toggle Breakpoint" },
			{ "<F10>", dap.step_over, desc = "Debug: Step Over" },
			{ "<F11>", dap.step_into, desc = "Debug: Step Into" },
			{ "<F12>", dap.step_out, desc = "Debug: Step Out" },

			-- Additional useful commands with leader key
			{ "<leader>db", dap.toggle_breakpoint, desc = "Debug: Toggle Breakpoint" },
			{
				"<leader>dB",
				function()
					dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Debug: Set Conditional Breakpoint",
			},
			{
				"<leader>dl",
				function()
					dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
				end,
				desc = "Debug: Set Log Point",
			},
			{ "<leader>dr", dap.repl.open, desc = "Debug: Open REPL" },
			{ "<leader>dt", dapui.toggle, desc = "Debug: Toggle UI" },

			-- Session management
			{ "<leader>ds", dap.continue, desc = "Debug: Start/Continue" },
			{ "<leader>dq", dap.close, desc = "Debug: Quit Session" },
			{ "<leader>dR", dap.run_last, desc = "Debug: Run Last Session" },
			{
				"<leader>dp",
				function()
					dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
				end,
				desc = "Debug: Set Log Point",
			},

			-- Workspace management
			{
				"<leader>dw",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Debug: Hover Variables",
			},
			{
				"<leader>df",
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.frames)
				end,
				desc = "Debug: Show Frames",
			},
			{
				"<leader>ds",
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.scopes)
				end,
				desc = "Debug: Show Scopes",
			},

			unpack(keys),
		}
	end,
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- Setup mason-nvim-dap
		require("mason-nvim-dap").setup({
			ensure_installed = { "node2" },
			automatic_installation = true,
			handlers = {
				function(config)
					require("mason-nvim-dap").default_setup(config)
				end,
			},
		})

		-- Setup dap-vscode-js
		require("dap-vscode-js").setup({
			node_path = "node",
			debugger_path = vim.fn.expand("~/.local/share/nvim/vscode-js-debug"),
			debugger_cmd = { "js-debug-adapter" },
			adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
			log_file_path = vim.fn.stdpath("cache") .. "/dap_vscode_js.log",
			log_file_level = vim.log.levels.DEBUG,
			log_console_level = vim.log.levels.ERROR,
		})

		-- Configure language specific settings
		for _, language in ipairs({ "typescript", "javascript" }) do
			require("dap").configurations[language] = {
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
					runtimeArgs = {
						"./node_modules/jest/bin/jest.js",
						"--runInBand",
					},
					rootPath = "${workspaceFolder}",
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
					internalConsoleOptions = "neverOpen",
				},
			}
		end

		-- Dap UI setup
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

		-- Set up DAP UI listeners
		dap.listeners.after.event_initialized["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		-- Add error handling
		dap.listeners.after.event_error["error_handler"] = function(_, body)
			vim.notify("DAP Error: " .. vim.inspect(body), vim.log.levels.ERROR)
		end
	end,
}
