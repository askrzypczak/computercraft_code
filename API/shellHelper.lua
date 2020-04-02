
--shell has to be injected due to the way it is handled by the os
local function new(shell)
  if not shell then error("mandatory dependency 'shell' not provided") end

  local function setDefaultAliases()

    for i, filename in pairs(fs.list("/TurtleScripts")) do
      local command = string.match(filename, "(.*)%.lua$")
      print("set alias: ", command)
      shell.setAlias(command, "/TurtleScripts/" .. filename)
    end
  end

  shell.setAlias("execute", "/ScriptRunner/execute.lua")

  return({
    setDefaultAliases = setDefaultAliases
  })
end

return({
  new = new
})