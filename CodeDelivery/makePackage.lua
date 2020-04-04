print "uploading package to floppy"



--do a clean install, deleting everything
for i, filename in pairs(fs.list("/disk/")) do
  fs.delete("/disk/" .. filename)
end


--folders should work the same as files
local files = {"API", "TurtleScripts", "ScriptRunner", "Config", "/CodeDelivery/startupBase.lua"}

for key, filename in pairs(files) do
  fs.copy(filename, "/disk/" .. filename)
end

local diskStartup = "/CodeDelivery/init.lua"

if fs.exists("/disk/startup") then
  fs.delete("/disk/startup")
end
fs.copy(diskStartup, "/disk/startup")


print "done!"
