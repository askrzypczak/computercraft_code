print "uploading package to floppy"

local files = {"digger.lua", "movement.lua", "refuel.lua", "harvester.lua", "inventory.lua", "craft.lua", "woodcutter.lua", "bootConfig.lua", "recovery.lua"}

for key, filename in pairs(files) do
  if fs.exists("/disk/" .. filename) then
    fs.delete("/disk/" .. filename)
  end
  fs.copy(filename, "/disk/" .. filename)
end

local diskStartup = "init.lua"

if fs.exists("/disk/startup") then
  fs.delete("/disk/startup")
end
fs.copy(diskStartup, "/disk/startup")


print "done!"
