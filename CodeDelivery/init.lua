print "installing package"

local setDefaultAliases = dofile("/disk/API/shellHelper.lua").new(shell).setDefaultAliases

--os will throw error if you try to delete rom and disk, and thats correct
local protectedFiles = {"disk", "rom", "Config"}

--do a clean install, deleting everything
for i, filename in pairs(fs.list("/")) do
  local okToDelete = true
  for j, protected in pairs(protectedFiles) do
    if filename == protected then okToDelete = false end
  end
  if okToDelete then
    fs.delete("/" .. filename)
  end
end

--folders should work the same as files
local files = {"API", "TurtleScripts", "ScriptRunner"}

for i, filename in pairs(files) do
  fs.copy("/disk/" .. filename, "/" .. filename)
end


local startup = "/disk/CodeDelivery/startupBase.lua"

if fs.exists("/startup") then
  fs.delete("/startup")
end
fs.copy(startup, "/startup")

if not fs.exists("/Config") then
  fs.copy("/disk/Config", "/Config")
end


setDefaultAliases()

print "done!"