local present, blankline = pcall(require, "indent_blankline")
if not present then
  return
end

blankline.setup {
  show_end_of_line = true,
}
