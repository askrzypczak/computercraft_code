local tArgs = {...}

print "initializing..."
if tArgs[1] == "help" then
  textutils.pagedPrint(
    [[usage: Provide 2 arguments: farm x and farm y.
    farm pattern will be repeated x by y times.

    This tool only works for wood and related blocks. It requires a cleared space
    
    fuel should be placed in slot 1, it will use the fuel to move.
    If the bot does run out of fuel, you will need to add more fuel to slot 1.

    saplings should be added to slot 2

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

local function isSapling(item)
  if item then
    return string.find(item.name, "sapling") ~= nil
  else return false end
end

local saplingItem = turtle.getItemDetail(saplingSlot)
if not isSapling(saplingItem) then
  error(string.format("sapling slot is not a sapling! (slot %i)", saplingSlot))
end


local digSlot = 3

local digItem = turtle.getItemDetail(digSlot)
if digItem ~= nil then
  error(string.format("cutting slot is not empty! (slot %i)", digSlot))
end



local movement = dofile("API/movement.lua").movement
local inventory = dofile("API/inventory.lua").new({range={startIndex=4, endIndex=16}})
local fuel = dofile("API/refuel.lua").new({fuelSlot = 1}, inventory)


local function woodcut(direction)
  turtle.select(digSlot)

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
      inventory.onEachInventorySlot(
        function(i)
          return turtle.transferTo(i)
        end
      )
    end
  end
end

local function plant()
  local xIndex = math.abs(movement.getX()) % (#farmPattern + 1)
  if xIndex ~= 0 then
    local yIndex = math.abs(movement.getY()) % (#farmPattern[xIndex] + 1)
    if farmPattern[xIndex][yIndex] == 1 then
      turtle.select(saplingSlot)
      turtle.placeDown()
    end
  end
end



movement.moveTo(1, 0, 0, {fuel.checkAndRefuel})

local xTarget, yTarget = xRepeat * patternX, yRepeat * patternY
print(string.format("cutting (%i, %i, %i) to (%i, %i, %i)", movement.getX(), movement.getY(), movement.getZ(), xTarget, yTarget, farmHeight))
movement.observeMove(xTarget, yTarget, farmHeight, {woodcut, fuel.checkAndRefuel})


print "done"
movement.moveToBackwards(1, 0, 1, {fuel.checkAndRefuel})

print(string.format("planting (%i, %i, %i) to (%i, %i, %i)", movement.getX(), movement.getY(), movement.getZ(), xTarget, yTarget, 0))
movement.coverMove(xTarget, yTarget, 0, {plant, fuel.checkAndRefuel})


movement.moveToBackwards(0, 0, 1, {woodcut, fuel.checkAndRefuel})
movement.moveToBackwards(0, 0, 0, {woodcut, fuel.checkAndRefuel})
movement.faceDir(0)
