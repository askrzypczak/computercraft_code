
--when performing a long task on a loop, this will allow programs to flag when they are at a recoverable state.
--easiest way to do recovery is to only allow it when sleeping at home base between iterations.

local function setRecoverable()
  local handle, err = io.open("recoverConfig", "w")
  if err then error(err) end
  handle.write("return {recoverable=true}")
  handle.close()
end

local function unSetRecoverable()
  local handle, err = io.open("recoverConfig", "w")
  if err then error(err) end
  handle.write("return {recoverable=false}")
  handle.close()
end

local function recoveryBlock(action)
  setRecoverable()
  action()
  unSetRecoverable()
end

return {
  recovery = {
    recoveryBlock = recoveryBlock
  }
}