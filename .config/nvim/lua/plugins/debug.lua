-- return {
-- 	"mfussenegger/nvim-dap",
-- 	event = "BufRead",
-- 	dependencies = {
-- 		"rcarriga/nvim-dap-ui",
-- 		"theHamsta/nvim-dap-virtual-text",
-- 		"nvim-telescope/telescope-dap.nvim",
-- 		"nvim-neotest/nvim-nio",
-- 		"mxsdev/nvim-dap-vscode-js",
-- 	},
-- 	config = function()
-- 		local dap = require("dap")
-- 		local dapui = require("dapui")
--
-- 		require("dap-vscode-js").setup({
-- 			debugger_path = vim.fn.expand("~/vscode-js-debug"),
-- 			debugger_cmd = { "js-debug-adapter" },
-- 			adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost", "node" },
-- 		})
--
-- 		-- Helper function to find an available port
-- 		local function find_available_port()
-- 			local socket = vim.loop.new_tcp()
-- 			socket:bind("127.0.0.1", 0)
-- 			local port = socket:getsockname().port
-- 			socket:close()
-- 			return port
-- 		end
--
-- 		for _, language in ipairs({ "typescript", "javascript", "typescriptreact" }) do
-- 			dap.configurations[language] = {
-- 				{
-- 					type = "pwa-node",
-- 					request = "launch",
-- 					name = "Launch file",
-- 					program = "${file}",
-- 					cwd = "${workspaceFolder}",
-- 					port = find_available_port,
-- 				},
-- 				{
-- 					type = "pwa-node",
-- 					request = "attach",
-- 					name = "Attach",
-- 					processId = require("dap.utils").pick_process,
-- 					cwd = "${workspaceFolder}",
-- 					port = find_available_port,
-- 				},
-- 				{
-- 					type = "pwa-node",
-- 					request = "launch",
-- 					name = "Debug Jest Tests",
-- 					runtimeExecutable = "node",
-- 					runtimeArgs = {
-- 						"./node_modules/jest/bin/jest.js",
-- 						"--runInBand",
-- 					},
-- 					rootPath = "${workspaceFolder}",
-- 					cwd = "${workspaceFolder}",
-- 					console = "integratedTerminal",
-- 					internalConsoleOptions = "neverOpen",
-- 					port = find_available_port,
-- 				},
-- 			}
-- 		end
--
-- 		dapui.setup()
--
-- 		dap.listeners.after.event_initialized["dapui_config"] = function()
-- 			dapui.open()
-- 		end
-- 		dap.listeners.before.event_terminated["dapui_config"] = function()
-- 			dapui.close()
-- 		end
-- 		dap.listeners.before.event_exited["dapui_config"] = function()
-- 			dapui.close()
-- 		end
--
-- 		-- Error handling
-- 		dap.listeners.after.event_error["error_handler"] = function(session, body)
-- 			vim.notify("DAP Error: " .. vim.inspect(body), vim.log.levels.ERROR)
-- 		end
--
-- 		-- Key mappings
-- 		local function map(mode, lhs, rhs, opts)
-- 			local options = { noremap = true, silent = true }
-- 			if opts then
-- 				options = vim.tbl_extend("force", options, opts)
-- 			end
-- 			vim.api.nvim_set_keymap(mode, lhs, rhs, options)
-- 		end
--
-- 		map("n", "<leader>dt", "<cmd>lua require'dapui'.toggle()<CR>")
-- 		map("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>")
-- 		map("n", "<leader>dc", "<cmd>lua require'dap'.continue()<CR>")
-- 		map("n", "<leader>dr", "<cmd>lua require'dap'.run_last()<CR>")
-- 		map("n", "<leader>ds", "<cmd>lua require'dap'.continue()<CR>")
-- 	end,
-- }
--
-- -- require("dapui").setup()
-- -- require("dap-vscode-js").setup()
-- -- require("nvim-dap-virtual-text").setup()
-- -- vim.fn.sign_define(
-- -- 	"DapBreakpoint",
-- -- 	{ text = "🔴", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
-- -- )
-- --
-- -- -- Debugger
-- -- vim.api.nvim_set_keymap("n", "<leader>dt", ":DapUiToggle<CR>", { noremap = true })
-- -- vim.api.nvim_set_keymap("n", "<leader>db", ":DapToggleBreakpoint<CR>", { noremap = true })
-- -- vim.api.nvim_set_keymap("n", "<leader>dc", ":DapContinue<CR>", { noremap = true })
-- -- vim.api.nvim_set_keymap("n", "<leader>dr", ":lua require('dapui').open({reset = true})<CR>", { noremap = true })
-- -- vim.api.nvim_set_keymap("n", "<leader>ht", ":lua require('harpoon.ui').toggle_quick_menu()<CR>", { noremap = true })
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
			-- Basic debugging keymaps, feel free to change to your liking!
			{ "<F5>", dap.continue, desc = "Debug: Start/Continue" },
			{ "<F1>", dap.step_into, desc = "Debug: Step Into" },
			{ "<F2>", dap.step_over, desc = "Debug: Step Over" },
			{ "<F3>", dap.step_out, desc = "Debug: Step Out" },
			{ "<leader>b", dap.toggle_breakpoint, desc = "Debug: Toggle Breakpoint" },
			{
				"<leader>B",
				function()
					dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Debug: Set Breakpoint",
			},
			-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
			{ "<F7>", dapui.toggle, desc = "Debug: See last session result." },
			unpack(keys),
		}
	end,
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("dap-vscode-js").setup({
			node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
			debugger_path = "(runtimedir)/site/pack/packer/opt/vscode-js-debug", -- Path to vscode-js-debug installation.
			debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
			adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
			log_file_path = "(stdpath cache)/dap_vscode_js.log", -- Path for file logging
			log_file_level = 0, -- Logging level for output to file. Set to false to disable file logging.
			log_console_level = vim.log.levels.ERROR, -- Logging level for output to console. Set to false to disable console output.
		})

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
					-- trace = true, -- include debugger info
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
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup({
			-- Set icons to characters that are more likely to work in every terminal.
			--    Feel free to remove or use ones that you like more! :)
			--    Don't feel like these are good choices.
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
	end,
}
