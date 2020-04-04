
--when performing a long task on a loop, this will allow programs to flag when they are at a recoverable state.
--easiest way to do recovery is to only allow it when sleeping at home base between iterations.

if not fs.exists("./recoveryData") then
  fs.makeDir("./recoveryData")
end

local recoverConfigFilename = "./recoveryData/recoverConfig.lua"
local recoverCommandsFilename = "./recoveryData/recoverCommands.lua"

local function setRecoverable()
  local handle, err = io.open(recoverConfigFilename, "w")
  if err then error(err) end
  handle.write("return {recoverable=true}")
  handle.close()
end

local function unSetRecoverable()
  local handle, err = io.open(recoverConfigFilename, "w")
  if err then error(err) end
  handle.write("return {recoverable=false}")
  handle.close()
end

local function checkRecoveryAllowed()
  if fs.exists(recoverConfigFilename) then
    local config = dofile(recoverConfigFilename)
    return config.recoverable
  end
end


--takes in an array of commands as a lua string, of the format compatible with ScriptRunner/execute
local function registerRecoveryMethod(commands)
  local handle, err = io.open(recoverCommandsFilename, "w")
  if err then error(err) end
  handle.write([[return{
    commands=]] .. commands .. [[
  }]])
  handle.close()
end

local function executeRecoveryMethod(_shell)
  if not checkRecoveryAllowed() then
    print("not in a recoverable state")
    return
  end
  if fs.exists(recoverCommandsFilename) then
    local execute = dofile("/ScriptRunner/execute.lua").new(_shell, {
      filename = recoverCommandsFilename,
      silent = true
    })
    execute.run()
  else
    print "no recovery file available"
  end
end



return {
  recovery = {
    setRecoverable = setRecoverable,
    unSetRecoverable = unSetRecoverable,
    registerRecoveryMethod = registerRecoveryMethod,
    executeRecoveryMethod = executeRecoveryMethod,
    checkRecoveryAllowed = checkRecoveryAllowed
  }
}