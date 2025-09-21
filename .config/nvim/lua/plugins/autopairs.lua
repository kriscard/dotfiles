return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local autopairs = require("nvim-autopairs")

			autopairs.setup({
				check_ts = true,
				ts_config = {
					lua = { "string", "source" },
					javascript = { "string", "template_string" },
					typescript = { "string", "template_string" },
					javascriptreact = { "string", "template_string" },
					typescriptreact = { "string", "template_string" },
					java = false,
				},
				disable_filetype = { "TelescopePrompt", "spectre_panel" },
				fast_wrap = {
					map = "<M-e>",
					chars = { "{", "[", "(", '"', "'" },
					pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
					offset = 0,
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "PmenuSel",
					highlight_grey = "LineNr",
				},
			})

			-- Integration with blink.cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local ok, blink_cmp = pcall(require, "blink.cmp")
			if ok then
				blink_cmp.setup({
					completion = {
						list = {
							selection = "auto_insert",
						},
					},
				})
			end

			-- Add bracket completion for treesitter
			local ts_conds = require("nvim-autopairs.ts-conds")

			-- press % => %% only while inside a comment or string
			autopairs.add_rules({
				require("nvim-autopairs.rule")("%", "%", "lua"):with_pair(ts_conds.is_ts_node({ "string", "comment" })),
				require("nvim-autopairs.rule")("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node({ "function" })),
			})
		end,
	},
}