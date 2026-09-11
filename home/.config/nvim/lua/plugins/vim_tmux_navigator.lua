return {
	"christoomey/vim-tmux-navigator",
	lazy = false,
	init = function()
		-- Keep navigation under one set of mappings for Herdr and tmux.
		vim.g.tmux_navigator_no_mappings = 1
	end,
	config = function()
		local directions = {
			left = { wincmd = "h", tmux = "Left" },
			down = { wincmd = "j", tmux = "Down" },
			up = { wincmd = "k", tmux = "Up" },
			right = { wincmd = "l", tmux = "Right" },
		}

		local function navigate(direction)
			local target = directions[direction]
			local previous_window = vim.api.nvim_get_current_win()

			vim.cmd("wincmd " .. target.wincmd)
			if vim.api.nvim_get_current_win() ~= previous_window then
				return
			end

			if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
				local herdr = vim.env.HERDR_BIN_PATH
				if not herdr or herdr == "" then
					herdr = "herdr"
				end

				-- Target this pane explicitly; --current may refer to another client.
				vim.fn.system({
					herdr,
					"pane",
					"focus",
					"--direction",
					direction,
					"--pane",
					vim.env.HERDR_PANE_ID,
				})
			elseif vim.env.TMUX and vim.env.TMUX ~= "" then
				pcall(vim.cmd, "TmuxNavigate" .. target.tmux)
			end
		end

		local function map(direction, lhs, desc)
			vim.keymap.set("n", lhs, function()
				navigate(direction)
			end, { silent = true, desc = desc })

			-- Preserve the existing behavior of leaving terminal mode before moving.
			vim.keymap.set("t", lhs, "<C-\\><C-n><cmd>MultiplexerNavigate " .. direction .. "<cr>", {
				silent = true,
				desc = desc,
			})
		end

		vim.api.nvim_create_user_command("MultiplexerNavigate", function(args)
			navigate(args.args)
		end, {
			nargs = 1,
			complete = function()
				return { "left", "down", "up", "right" }
			end,
		})

		map("left", "<C-h>", "Navigate left (vim/multiplexer)")
		map("down", "<C-j>", "Navigate down (vim/multiplexer)")
		map("up", "<C-k>", "Navigate up (vim/multiplexer)")
		map("right", "<C-l>", "Navigate right (vim/multiplexer)")

		-- vim-tmux-navigator provides previous-pane navigation only under tmux.
		vim.keymap.set("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", {
			silent = true,
			desc = "Navigate previous (vim/tmux)",
		})
	end,
}
