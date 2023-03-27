local status, notify = pcall(require, "notify")
if not status then
  return
end

notify.setup {
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
