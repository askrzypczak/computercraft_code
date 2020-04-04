
local shellHelper = dofile("/API/shellHelper.lua").new(shell)
local execute = dofile("/ScriptRunner/execute.lua").new(shell, {
  filename = "/ScriptRunner/startupConfig.lua",
  silent = true
})
local recovery = dofile("/API/recovery.lua").recovery

shellHelper.setDefaultAliases()

if recovery.checkRecoveryAllowed() then
  recovery.recover(shell)
else
  execute.run()
end
