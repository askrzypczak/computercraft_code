
--when performing a long task on a loop, this will allow programs to flag when they are at a recoverable state.
--easiest way to do recovery is to only allow it when sleeping at home base between iterations.

if not fs.exists("/API/recoveryData") then
  fs.makeDir("/API/recoveryData")
end

local recoverFlagFile = "/API/recoveryData/recoverFlag.lua"
local recoverProgressFile = "/API/recoveryData/recoverFlag.lua"
local recoverCommandsFilename = "/API/recoveryData/recoverCommands.lua"

local function setRecoverable()
  local handle, err = io.open(recoverFlagFile, "w")
  if err then error(err) end
  handle:write("return {recoverable=true}")
  handle:close()
end

local function unSetRecoverable()
  local handle, err = io.open(recoverFlagFile, "w")
  if err then error(err) end
  handle:write("return {recoverable=false}")
  handle:close()
end

local function setRecoverProgress()
  local handle, err = io.open(recoverProgressFile, "w")
  if err then error(err) end
  handle:write("return {inRecovery=true}")
  handle:close()
end

local function startupInit()
  local handle, err = io.open(recoverProgressFile, "w")
  if err then error(err) end
  handle:write("return {inRecovery=false}")
  handle:close()
end

local function recoveryBlock(action)
  setRecoverable()
  action()
  unSetRecoverable()
end

local function checkRecoveryAllowed()
  if fs.exists(recoverFlagFile) then
    local config = dofile(recoverFlagFile)
    return config.recoverable
  end
end
local function checkInRecovery()
  if fs.exists(recoverProgressFile) then
    local config = dofile(recoverProgressFile)
    return config.inRecovery
  end
end


--takes in an array of commands as a lua string, of the format compatible with ScriptRunner/execute
local function generateRecoveryFile(commandString)

  local template = [[
    return{
      commands={
        "]] .. commandString .. [["
      }
    }
  ]]

  local handle, err = io.open(recoverCommandsFilename, "w")
  if err then error(err) end
  handle:write(template)
  handle:close()

end

local function recover(_shell)
  if not checkRecoveryAllowed() then
    print "not in a recoverable state"
    return false
  end
  if not fs.exists(recoverCommandsFilename) then
    print "no recovery file available"
    return false
  else
    setRecoverProgress()
    local execute = dofile("/ScriptRunner/execute.lua").new(_shell, {
      filename = recoverCommandsFilename,
      silent = true
    })
    execute.run()
  end
end



return {
  recovery = {
    recoveryBlock = recoveryBlock,
    generateRecoveryFile = generateRecoveryFile,
    recover = recover,
    checkRecoveryAllowed = checkRecoveryAllowed,
    startupInit = startupInit,
    checkInRecovery = checkInRecovery
  }
}