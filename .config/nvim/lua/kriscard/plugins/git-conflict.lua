local status, gitConflict = pcall(require, "git-conflict")
if not status then
  return
end

gitConflict.setup()
