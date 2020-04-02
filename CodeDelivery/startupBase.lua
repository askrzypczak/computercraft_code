
local shellHelper = dofile("/API/shellHelper.lua").new(shell)
local execute = dofile("/ScriptRunner/execute.lua").new(shell, {
  filename = "/ScriptRunner/startupConfig.lua",
  silent = true
})

shellHelper.setDefaultAliases()
execute.run()
