local autosession_setup, autosession = pcall(require, "auto-session")
if not autosession_setup then
  return
end


autosession.setup({
  log_level = "error",
  auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
})
