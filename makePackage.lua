print "uploading package to floppy"

local files = {"digger.lua", "init.lua", "movement.lua", "refuel.lua", "harvester.lua", "inventory.lua", "craft.lua"}

for key, filename in pairs(files) do
  if fs.exists("/disk/" .. filename) then
    fs.delete("/disk/" .. filename)
  end
  fs.copy(filename, "/disk/" .. filename)
end

print "done!"
