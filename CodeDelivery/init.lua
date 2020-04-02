print "installing package"

--os will throw error if you try to delete these, and thats correct
local protectedFiles = {"disk", "rom"}

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
local files = {"API", "TurtleScripts"}

for i, filename in pairs(files) do
  fs.copy("/disk/" .. filename, "/" .. filename)
end

print "done!"