
--shell has to be injected due to the way it is handled by the os
local function new(shell)
  if not shell then error("mandatory dependency 'shell' not provided") end

  local function setDefaultAliases()

    local function findScripts(dirname)
      for i, filename in pairs(fs.list(dirname)) do
        local command = string.match(filename, "(.*)%.lua$")
        if command then
          print("set alias: ", command)
          shell.setAlias(command, "/TurtleScripts/" .. filename)
        else 
          print("could not set alias for file", filename)
        end
      end
    end

    findScripts("/TurtleScripts")
    
    shell.setAlias("execute", "/ScriptRunner/execute.lua")
    print("set alias: ", "execute")
    
    shell.setAlias("do", "/ScriptRunner/do.lua")
    print("set alias: ", "do")
  end


  return({
    setDefaultAliases = setDefaultAliases
  })
end

return({
  new = new
})