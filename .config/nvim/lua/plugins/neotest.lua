return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- Test adapters for JS/TS
		"nvim-neotest/neotest-jest",
		"marilari88/neotest-vitest",
	},
	keys = {
		{
			"<leader>tt",
			function()
				require("neotest").run.run()
			end,
			desc = "Run Nearest Test",
		},
		{
			"<leader>tf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Run File Tests",
		},
		{
			"<leader>ta",
			function()
				require("neotest").run.run(vim.uv.cwd())
			end,
			desc = "Run All Tests",
		},
		{
			"<leader>ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Toggle Summary",
		},
		{
			"<leader>to",
			function()
				require("neotest").output.open({ enter = true, auto_close = true })
			end,
			desc = "Show Output",
		},
		{
			"<leader>tO",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "Toggle Output Panel",
		},
		{
			"<leader>tS",
			function()
				require("neotest").run.stop()
			end,
			desc = "Stop Tests",
		},
		{
			"<leader>tw",
			function()
				require("neotest").watch.toggle(vim.fn.expand("%"))
			end,
			desc = "Watch File",
		},
		{
			"<leader>td",
			function()
				require("neotest").run.run({ strategy = "dap" })
			end,
			desc = "Debug Nearest Test",
		},
		{
			"[t",
			function()
				require("neotest").jump.prev({ status = "failed" })
			end,
			desc = "Prev Failed Test",
		},
		{
			"]t",
			function()
				require("neotest").jump.next({ status = "failed" })
			end,
			desc = "Next Failed Test",
		},
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-jest")({
					jestCommand = "npm test --",
					jestConfigFile = function(file)
						if string.find(file, "/packages/") then
							return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
						end
						return vim.fn.getcwd() .. "/jest.config.ts"
					end,
					env = { CI = true },
					cwd = function(file)
						if string.find(file, "/packages/") then
							return string.match(file, "(.-/[^/]+/)src")
						end
						return vim.fn.getcwd()
					end,
				}),
				require("neotest-vitest"),
			},
			status = {
				virtual_text = true,
				signs = true,
			},
			output = {
				open_on_run = false,
			},
			quickfix = {
				open = function()
					require("trouble").open({ mode = "quickfix", focus = false })
				end,
			},
		})
	end,
}
