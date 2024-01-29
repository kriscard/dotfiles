-- nvim-cmp configs
return {
  -- customize nvim-cmp configs
  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      -- This is reaaaally not easy to setup :D
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          -- If it's a snippet then jump between fields
          if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          -- otherwise if the completion pop is visible then complete
          elseif cmp.visible() then
            cmp.confirm({ select = false })
          -- if the popup is not visible then open the popup
          elseif has_words_before() then
            cmp.complete()
          -- otherwise fallback
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
}

-- return {
--   "hrsh7th/nvim-cmp",
--   opts = function(_, opts)
--     local has_words_before = function()
--       unpack = unpack or table.unpack
--       local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--       return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
--     end
--
--     local luasnip = require("luasnip")
--     local cmp = require("cmp")
--
--     opts.mapping = vim.tbl_extend("force", opts.mapping, {
--       ["<Tab>"] = cmp.mapping(function(fallback)
--         if cmp.visible() then
--           -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
--           cmp.select_next_item()
--         -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
--         -- this way you will only jump inside the snippet region
--         elseif luasnip.expand_or_jumpable() then
--           luasnip.expand_or_jump()
--         elseif has_words_before() then
--           cmp.complete()
--         else
--           fallback()
--         end
--       end, { "i", "s" }),
--       ["<S-Tab>"] = cmp.mapping(function(fallback)
--         if cmp.visible() then
--           cmp.select_prev_item()
--         elseif luasnip.jumpable(-1) then
--           luasnip.jump(-1)
--         else
--           fallback()
--         end
--       end, { "i", "s" }),
--     })
--   end,
-- }
