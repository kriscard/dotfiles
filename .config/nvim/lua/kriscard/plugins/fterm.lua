local present, fterm = pcall(require, "FTerm")
if not present then
  return
end

fterm.setup({
  dimensions = {
    height = 0.8,
    width = 0.8,
    x = 0.5,
    y = 0.3,
  },
  border = "single",
})
