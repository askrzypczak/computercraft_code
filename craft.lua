local movement = dofile("movement.lua").movement
local inventory = dofile("inventory.lua").new({range={startIndex=1, endIndex=16}})

local pattern = {
  "minecraft:wheat", "minecraft:wheat", "minecraft:wheat"
}

local input, output = "minecraft:wheat", "minecraft:bread"
local inputDir, outputDir, garbageDir = 0, 2, 3

local function getInput()
  repeat
    movement.faceDir(inputDir)
    turtle.select(1)
    turtle.suck()
    local item = turtle.getItemDetail()
    if item and item.name ~= input then
      movement.faceDir(garbageDir)
      turtle.drop()
    end
    local count = turtle.getItemCount()
    if count == 0 then os.sleep(5) end
  until count > 0
  return turtle.getItemCount()
end

local function dump(dir, itemName)
  movement.faceDir(dir)
  inventory.onEachInventory(
    function(i, item)
      if itemName == nil or item.name == itemName then turtle.drop() end
    end
  )
end

while true do
  print("crafting")
  dump(inputDir)
  local amount = getInput()
  local success = false
  if amount > #pattern then
    for i, item in pairs(pattern) do
      local currentItem = turtle.getItemDetail()
      if currentItem and currentItem.name == item then
        turtle.transferTo(i, math.floor(amount / #pattern))
      else break end
    end
    success = turtle.craft()
    if success then dump(outputDir, output) end
  end
  if not success then
    dump(outputDir, output)
    dump(inputDir, input)
    dump(garbageDir)
    os.sleep(5)
  end
end
