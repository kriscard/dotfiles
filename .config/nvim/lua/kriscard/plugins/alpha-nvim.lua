return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local present, alpha = pcall(require, "alpha")
    if not present then
      return
    end

    local header = {
      type = "text",
      val = {
        [[                                  __]],
        [[     ___     ___    ___   __  __ /\_\    ___ ___]],
        [[    / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\]],
        [[   /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \]],
        [[   \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
        [[    \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
      },
      opts = {
        position = "center",
        hl = "center",
        -- wrap = "overflow";
      },
    }

    local function button(sc, txt, keybind)
      local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")
      local opts = {
        position = "center",
        text = txt,
        shortcut = sc,
        cursor = 6,
        width = 19,
        align_shortcut = "right",
        hl_shortcut = "Number",
        hl = "Function",
      }
      if keybind then
        opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true } }
      end
      return {
        type = "button",
        val = txt,
        on_press = function()
          local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
          vim.api.nvim_feedkeys(key, "normal", false)
        end,
        opts = opts,
      }
    end

    local buttons = {
      type = "group",
      val = {
        button("s", "   Restore                          ", ":SessionManager load_last_session<CR>"),
        button("r", "   Recents                          ", ":Telescope oldfiles<CR>"),
        button("f", "   Search                           ", ":Telescope find_files<CR>"),
        button("e", "   Create                           ", ":ene <BAR> startinsert<CR>"),
        button("w", "   Projects                         ",
          "<cmd>lua require'telescope'.extensions.projects.projects{}<CR>"),
        button("s", "   Settings                         ", ":e ~/.config/nvim/<CR>"),
        button("m", "   Mason                            ", ":Mason<CR>"),
        button("q", "   Quit Neovim                      ", ":qa!<CR>"),
      },
      opts = {
        position = "center",
        spacing = 1,
      },
    }

    local section = {
      header = header,
      buttons = buttons,
    }

    local opts = {
      layout = {
        { type = "padding", val = 1 },
        section.header,
        { type = "padding", val = 1 },
        section.footer,
        { type = "padding", val = 2 },
        section.buttons,
      },
      opts = {
        margin = 44,
      },
    }

    alpha.setup(opts)
  end,
}
