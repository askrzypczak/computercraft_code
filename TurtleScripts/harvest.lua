local tArgs = {...}


print "initializing..."
if #tArgs == 0 or tArgs[1] == "help" then
  textutils.pagedPrint(
    [[usage: Provide 5 arguments: x2, y2, x1, y1, z1 

    This tool only works for wheat. it will skip harvesting any other plant

    The input describes a plane from the current bot position from .1 to .2, where bot at 0,0,0
    Forward is positive x, Right is positive y, Up is positive z
    bot will then clear out full plane described by its position and the vector

    there must be a clear path from (0,0,0) to (x1,y1,z1), pathing down Z, then y, then x
    
    fuel should be placed in slot 1, it will use the fuel to move.
    If the bot does run out of fuel, you will need to add more fuel to slot 1.

    grass seeds should be placed in slot 2.

    the turtle will need a hoe. if the current turtle does not, use the command "equip <slot> right"

    maintenance: you will need to periodically remove seeds from the inventory, as it will never drop them
    ]]
  )

  return
end

local startX, startY, startZ, endX, endY = tonumber(tArgs[3]) or 0, tonumber(tArgs[4]) or 0, tonumber(tArgs[5]) or 0, tonumber(tArgs[1]) or 0, tonumber(tArgs[2]) or 0

local movement = dofile("API/movement.lua").movement
local inventory = dofile("API/inventory.lua").new({range={startIndex=2, endIndex=16}}) --seeds count as inventory
local fuel = dofile("API/refuel.lua").new(inventory, {fuelSlot = 1})


local seedSlot = 2
local plantType = "minecraft:wheat"
local seedType = "minecraft:wheat_seeds"
local readyValue = 7


local function selectSeeds()
  turtle.select(seedSlot)
  local item = turtle.getItemDetail()

  if item and item.name ~= seedType then
    turtle.drop()
    item = nil
  end

  if item == nil then
    inventory.onEachInventory(
      function(i, inventoryItem)
        if inventoryItem.name == seedType then
          turtle.select(i)
          turtle.transferTo(seedSlot)
          turtle.select(seedSlot)
          return true
        end
      end
    )
  end
end

local function harvest()
  local isItem, itemBelow = turtle.inspectDown()
  if not isItem or itemBelow.name == plantType and itemBelow.state.age == readyValue then
    turtle.digDown()
    selectSeeds()
    turtle.placeDown()
  end
end


print "harvesting..."
movement.moveTo(startX, startY, startZ, {fuel.checkAndRefuel})


local xTarget, yTarget = endX - startX, endY - startY

movement.coverMove(xTarget, yTarget, 0, {harvest, fuel.checkAndRefuel})
harvest() --last block will be the endpoint, callbacks wont be called after move, only before.

print "done!"
movement.moveTo(startX, startY, startZ, {fuel.checkAndRefuel})
movement.moveToBackwards(0, 0, 0, {fuel.checkAndRefuel})
movement.faceDir(movement.front)

print "dumping items"
inventory.onEachInventory(
  function(i, inventoryItem)
    if i ~= seedSlot then
      turtle.select(i)
      turtle.dropDown()
    end
  end
)