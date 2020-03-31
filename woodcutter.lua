local tArgs = {...}

print "initializing..."
if tArgs[1] == "help" then
  textutils.pagedPrint(
    [[usage: Provide 2 arguments: farm x and farm y.
    farm pattern will be repeated x by y times.

    This tool only works for wood and related blocks. It requires a cleared space
    there must be a clear path from (0,0,0) to (x1,y1,z1), pathing down Z, then y, then x
    
    fuel should be placed in slot 1, it will use the fuel to move.
    If the bot does run out of fuel, you will need to add more fuel to slot 1.

    the turtle will need an axe. if the current turtle does not, use the command line "woodcutter equip" when an axe is in slot 1]]
  )

  return
end
if tArgs[1] == "equip" then
  turtle.select(1)
  if turtle.equipRight() then print "equiped!" else print "equip failed" end
  return
end

local xRepeat, yRepeat = tonumber(tArgs[1]) or 1, tonumber(tArgs[2]) or 1

--configuring for birch
local farmHeight = 10
local farmPattern = {
  {0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 1, 0, 0, 1, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 1, 0, 0, 1, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0}
}
local patternX, patternY = #farmPattern, #farmPattern[1]

local saplingSlot = 2

local saplingItem = turtle.getItemDetail(saplingSlot)
if saplingItem ~= nil then
  error(string.format("sapling slot is not empty! (slot %i)", saplingSlot))
end

local function isSapling(item)
  if item then
    return string.find(item.name, "sapling") ~= nil
  else return false end
end

local digSlot = 3

local digItem = turtle.getItemDetail(digSlot)
if digItem ~= nil then
  error(string.format("cutting slot is not empty! (slot %i)", digSlot))
end



local movement = dofile("movement.lua").movement
local inventory = dofile("inventory.lua").new({range={startIndex=4, endIndex=16}})
local fuel = dofile("refuel.lua").new({fuelSlot = 1}, inventory)


local function woodcut(direction)
  local digSuccess
  if not direction or direction == "forward" then
    digSuccess = turtle.dig()
  elseif direction == "up" then
    digSuccess = turtle.digUp()
  elseif direction == "down" then
    digSuccess = turtle.digDown()
  end

  if digSuccess then
    local digDetail = turtle.getItemDetail()
    if isSapling(digDetail) then
      turtle.transferTo(saplingSlot)
    else
      inventory.onEachInventorySlot(turtle.transferTo)
    end
  end
end

local function plant()
  if farmPattern[movement.getX()][movement.getY()] == 1 then
    turtle.select(saplingSlot)
    turtle.plceDown()
  end
end



movement.moveTo(1, 0, 0, {fuel.checkAndRefuel})

print "cutting"
local xTarget, yTarget = xRepeat * patternX, yRepeat * patternY
movement.coverMove(xTarget, yTarget, farmHeight, {woodcut, fuel.checkAndRefuel})


print "done"
movement.moveToBackwards(1, 0, 1, {fuel.checkAndRefuel})

print "planting"
movement.coverMove(xTarget, yTarget, 0, {plant, fuel.checkAndRefuel})


movement.moveToBackwards(0, 0, 0, {fuel.checkAndRefuel})
movement.faceDir(0)
