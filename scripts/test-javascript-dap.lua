-- Integration: launch a real Node target through Mason's js-debug adapter.
require("lazy").load({ plugins = { "nvim-dap" } })
local dap = require("dap")
local target = vim.fn.tempname() .. ".js"
vim.fn.writefile({ "const answer = 42;", "console.log(answer);" }, target)
local stopped, evaluated, failure = false, false, nil

dap.listeners.after.event_stopped.audit = function(session)
  stopped = true
  session:request("evaluate", { expression = "1 + 1", context = "repl" }, function(err, body)
    failure = err
    evaluated = body and body.result == "2" or false
  end)
end
local ok, err = pcall(function()
  dap.run({
    type = "pwa-node", request = "launch", name = "audit minimal Node",
    program = target, cwd = vim.fn.fnamemodify(target, ":h"),
    runtimeExecutable = vim.fn.exepath("node"),
    stopOnEntry = true, console = "internalConsole",
  })
  assert(vim.wait(20000, function() return evaluated or failure ~= nil end, 50), "DAP launch/evaluate timed out")
  assert(stopped, "target did not stop on entry")
  assert(not failure, vim.inspect(failure))
  assert(evaluated, "debuggee evaluation did not return 2")
end)
dap.listeners.after.event_stopped.audit = nil
if dap.session() then
  dap.terminate()
  vim.wait(5000, function() return dap.session() == nil end, 50)
end
vim.fn.delete(target)
assert(ok, err)
print("PASS: real js-debug launch, stopped event, and debuggee evaluation")
