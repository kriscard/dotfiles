local present, diffview = pcall(require, "diffview")
if not present then
  return
end

diffview.setup({
  -- enhanced_diff_hl = true,
  icons = {
    folder_closed = "",
    folder_open = "",
  },
  file_panel = {
    win_config = {
      position = "right",
      width = 30,
    },
    listing_style = "list",
  },
  file_history_panel = {
    win_config = {
      position = "bottom",
      height = 10,
    },
  },
})
