return {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "nvim-telescope/telescope-ui-select.nvim",
    {
      "nvim-telescope/telescope-live-grep-args.nvim",
      -- This will not install any breaking changes.
      -- For major updates, this must be adjusted manually.
      version = "^1.0.0",
    },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      hidden = true,
      defaults = {
        prompt_prefix = "🔍 ",
        selection_caret = " ",
        path_display = { "smart" },
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.5,
          },
          width = 0.8,
          height = 0.8,
          preview_cutoff = 120,
        },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          i = {
            ["<C-h>"] = "which_key",
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-u>"] = false,
          },
        },
      },
      pickers = {
        find_files = {
          -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob",
            "!**/.git/*",
            "--glob",
            "!**/node_modules/**",
            "--glob",
            "!**/package-lock.json",
            "--glob",
            "!**/build/**",
            "--glob",
            "!**/.next/**",
            "-u",
          },
        },
      },
      extensions = {
        fzf = {
          case_mode = "smart_case", -- or "ignore_case" or "smart_case"
        },
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")
    telescope.load_extension("live_grep_args")

    local builtin = require("telescope.builtin")
    local telescope_extensions = require("telescope").extensions

    local function find_files_from_current_dir()
      local opts = {
        cwd = vim.fn.expand("%:p:h"), -- %:p:h gives the current file's directory
        hidden = true,
      }
      require("telescope.builtin").find_files(opts)
    end

    local function find_files_from_root_dir()
      local opts = {
        cwd = vim.fn.getcwd(),
        hidden = true,
      }
      require("telescope.builtin").find_files(opts)
    end

    -- File Pickers
    vim.keymap.set("n", "<leader>f", find_files_from_current_dir, { desc = "Find Files from current directory" })

    vim.keymap.set("n", "<leader>ff", find_files_from_root_dir, { desc = "Find Files from root directory" })
    vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Fuzzy search through the output of git ls-files" })
    vim.keymap.set(
      "n",
      "<leader>ss",
      builtin.grep_string,
      { desc = "Searches for the string under your cursor or selection in your current working directory" }
    )
    vim.keymap.set("n", "<leader>/", builtin.live_grep, { desc = "Grep (root dir)" })
    vim.keymap.set(
      "n",
      "<leader>//",
      telescope_extensions.live_grep_args.live_grep_args,
      { noremap = true, desc = "Grep (root dir) with args" }
    )

    -- Vim Pickers
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Lists open buffers in current neovim instance" })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Lists previously open files" })
    vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search Help" })
    vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search Keymaps" })
    vim.keymap.set("n", "<leader>sq", builtin.quickfix, { desc = "Lists items in the quickfix list" })
    vim.keymap.set("n", "<leader>sj", builtin.jumplist, { desc = "Lists Jump List entries" })
    vim.keymap.set("n", "<leader>sR", builtin.registers, { desc = "Lists vim registers" })

    -- Neovim LSP Pickers
    vim.keymap.set("n", "<leader>R", builtin.lsp_references, { desc = "Lists vim registers" })
    vim.keymap.set(
      "n",
      "<leader>sd",
      builtin.diagnostics,
      { desc = "Lists Diagnostics for all open buffers or a specific buffer" }
    )
    vim.keymap.set(
      "n",
      "gi",
      builtin.lsp_implementations,
      { desc = "Goto the implementation of the word under the cursor" }
    )
    vim.keymap.set(
      "n",
      "gd",
      builtin.lsp_definitions,
      { desc = "Goto the implementation of the word under the cursor" }
    )

    -- Git Pickers
    vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Lists buffer's git commits with diff preview" })
    vim.keymap.set("n", "<leader>gS", builtin.git_stash, { desc = "Lists stash items in current repository" })
  end,
}
