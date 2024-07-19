return {
  {

    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufEnter" },
    dependencies = {
      -- Additional text objects for treesitter
      "nvim-treesitter/nvim-treesitter-textobjects",
      "windwp/nvim-ts-autotag",
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    -- @type TSConfig
    -- @diagnostic disable-next-line: missing-fields
    config = function()
      local treesitterConfig = require("nvim-treesitter.configs")

      ---@diagnostic disable-next-line: missing-fields
      treesitterConfig.setup({
        highlight = { enable = true },
        indent = { enable = true },
        autotag = {
          enable = true,
        },
        auto_install = true,
        ensure_installed = {
          "astro",
          "bash",
          "c",
          "cmake",
          "cpp",
          "css",
          "diff",
          "dockerfile",
          "gitignore",
          "go",
          "gomod",
          "gosum",
          "gowork",
          "graphql",
          "html",
          "http",
          "javascript",
          "jsdoc",
          "json",
          "json5",
          "jsonc",
          "lua",
          "luadoc",
          "luap",
          "markdown",
          "markdown_inline",
          "prisma",
          "python",
          "query",
          "regex",
          "ruby",
          "sql",
          "svelte",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
        },
      })
      -- MDX
      vim.filetype.add({
        extension = {
          mdx = "mdx",
        },
      })
      vim.treesitter.language.register("markdown", "mdx")
    end,
  },
  {
    "nvim-treesitter/playground",
  },
}
