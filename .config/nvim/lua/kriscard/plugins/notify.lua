local status, nvimnotify = pcall(require, "notify")
if not status then
  return
end

nvimnotify.setup {
  stages = "slide",
  render = "compact",
  fps = 60,
  icons = {
    ERROR = "",
    WARN = "",
    INFO = "",
    DEBUG = "",
    TRACE = "✎",
  },
}
