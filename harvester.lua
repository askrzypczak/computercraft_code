local tArgs = {...}


print "initializing..."
if #tArgs == 0 or tArgs[1] == "help" then
  textutils.pagedPrint(
    [[usage: Provide 4 arguments: x2, y2, x1, y1, z1 

    This tool only works for wheat. it will skip harvesting any other plant

    The input describes a plane from the current bot position from .1 to .2, where bot at 0,0,0
    Forward is positive x, Right is positive y, Up is positive z
    bot will then clear out full plane described by its position and the vector

    there must be a clear path from (0,0,0) to (x1,y1,z1), pathing down x, then y, then z
    
    fuel should be placed in slot 1, it will use the fuel to move.
    If the bot does run out of fuel, you will need to add more fuel to slot 1.

    grass seeds should be placed in slot 2.

    the turtle will need a hoe. if the current turtle does not, use the command line "harvester equip" when a hoe is in slot 1
    ]]
  )

  return
end
if tArgs[1] == "equip" then
  turtle.select(1)
  if turtle.equipRight() then print "equiped!" else print "equip failed" end
  return
end

local startX, startY, startZ, endX, endY = tonumber(tArgs[3]) or 0, tonumber(tArgs[4]) or 0, tonumber(tArgs[5]) or 0, tonumber(tArgs[1]) or 0, tonumber(tArgs[2]) or 0

local movement = dofile("movement.lua").movement
local fuel = dofile("refuel.lua").new({fuelSlot = 1})


local seedSlot = 2
local plantType = "minecraft:wheat"
local readyValue = 7

local function harvest()
  local itemBelow = turtle.inspectDown()
  if not itemBelow or itemBelow.name == plantType and itemBelow.state.age == readyValue then
    turtle.digDown()
    turtle.placeDown()
  end
end

movement.moveTo(startX, startY, startZ, {fuel.checkAndRefuel})


local xTarget, yTarget = endX - startX, endY - startY

movement.coverMove(xTarget, yTarget, 1, {harvest, fuel.checkAndRefuel})

movement.moveTo(startX, startY, startZ, {fuel.checkAndRefuel})
movement.moveTo(0, 0, 0, {fuel.checkAndRefuel})