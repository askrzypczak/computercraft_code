print "installing package"

if fs.exists("/digger.lua") then
  fs.delete("/digger.lua")
end

fs.copy("/disk/digger.lua", "/digger.lua")

print "done!"
