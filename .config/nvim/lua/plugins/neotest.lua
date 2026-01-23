---@diagnostic disable: missing-fields
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
		{
			"<leader>tT",
			function()
				-- Find and run companion test file from source file
				local current_dir = vim.fn.expand("%:p:h")
				local filename = vim.fn.expand("%:t:r") -- filename without extension

				-- Possible test file locations
				local test_patterns = {
					current_dir .. "/" .. filename .. ".test.tsx",
					current_dir .. "/" .. filename .. ".spec.tsx",
					current_dir .. "/" .. filename .. ".test.ts",
					current_dir .. "/" .. filename .. ".spec.ts",
					current_dir .. "/__tests__/" .. filename .. ".test.tsx",
					current_dir .. "/__tests__/" .. filename .. ".spec.tsx",
					current_dir .. "/__tests__/" .. filename .. ".test.ts",
					current_dir .. "/__tests__/" .. filename .. ".spec.ts",
				}

				for _, test_file in ipairs(test_patterns) do
					if vim.fn.filereadable(test_file) == 1 then
						require("neotest").run.run(test_file)
						return
					end
				end

				vim.notify("No test file found for " .. filename, vim.log.levels.WARN)
			end,
			desc = "Run Companion Test File",
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
				require("neotest-vitest")({
					-- Find project root by looking for package.json
					cwd = function(file)
						-- For monorepos with packages directory
						if string.find(file, "/packages/") then
							return string.match(file, "(.-/[^/]+/)src")
						end
						-- Find nearest package.json going up the directory tree
						local root = vim.fn.fnamemodify(file, ":p:h")
						while root ~= "/" do
							if vim.fn.filereadable(root .. "/package.json") == 1 then
								return root
							end
							root = vim.fn.fnamemodify(root, ":h")
						end
						return vim.fn.getcwd()
					end,
					-- Filter node_modules for faster discovery
					filter_dir = function(name)
						return name ~= "node_modules"
					end,
				}),
			},
			status = {
				enabled = true,
				virtual_text = true,
				signs = true,
			},
			output = {
				enabled = true,
				open_on_run = false,
			},
			quickfix = {
				enabled = true,
				open = function()
					require("trouble").open({ mode = "quickfix", focus = false })
				end,
			},
		})
	end,
}
