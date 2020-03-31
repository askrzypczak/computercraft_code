print "installing package"

local files = {"digger.lua", "movement.lua", "refuel.lua", "harvester.lua", "inventory.lua", "craft.lua"}

for key, filename in pairs(files) do
  if fs.exists("/" .. filename) then
    fs.delete("/" .. filename)
  end
  fs.copy("/disk/" .. filename, "/" .. filename)
end

print "done!"