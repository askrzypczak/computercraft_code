local tArgs = {...}

print "initializing..."
if #tArgs == 0 or tArgs[1] == "help" then
  textutils.pagedPrint(
    [[usage: Provide 2 arguments: repeatAmount incrementStart

    repeatAmount: int
      the turtle will move forward <repeatAmount> times while facing in the backwards direction.
      youu will need to clear the way for it.
      it will place redstone torches behind itself.

    every 34 blocks it will replace the block under itself with a powered rail.
    
    incrementStart: optional input, will offset the counter used to get 34 spaces between rails.]]  
  )
  return
end

local torchName = "minecraft:redstone_torch"
local poweredRailName = "minecraft:powered_rail"
local repeatAmount = tonumber(tArgs[1]) or 0
local incrementStart = tonumber(tArgs[2]) or 0

local whitelistItems = {
  ["minecraft:rail"] = true,
}

local movement = dofile("/API/movement.lua").movement
local inventory = dofile("/API/inventory.lua").new({range={startIndex=3, endIndex=16}})
local fuel = dofile("/API/refuel.lua").new(inventory, {fuelSlot = 1})
local digger = dofile("/API/digger.lua").new(inventory, fuel, {whitelistItems = whitelistItems, digSlot = 2})






local function placeItem(itemName, face)
  local placed = false
  repeat
    inventory.onEachInventory(function(i, item) 
      if item.name == itemName then
        digger.dig(face)
        turtle.select(i)
        if face == "down" then
          turtle.placeDown()
        else
          turtle.place()
        end
        placed = true
        return true
      end
    end)
    if not placed then 
      print("missing item", itemName)
      os.sleep(5)
    end
  until placed
end

local spacing = 34
local spaceCount = incrementStart
local railPlaced = false
local xPos = movement.getX()-1 --minus 1 because this action happens before the move
local function place()

  --place this on the next move (we are moving backwards)
  if railPlaced then
    placeItem(torchName)
    railPlaced = false
  end
  
  if spaceCount >= spacing then
    placeItem(poweredRailName, "down")
    railPlaced = true
    spaceCount = 0
  end

  if xPos < movement.getX() then
    spaceCount = spaceCount + (movement.getX() - xPos)
    xPos = movement.getX()
  end
end

movement.moveXBackward(repeatAmount, {place, fuel.checkAndRefuel})