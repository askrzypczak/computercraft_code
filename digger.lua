local movement = dofile("movement.lua").movement
local fuel = dofile("refuel.lua").new({fuelSlot = 1})

local tArgs = {...}

local blacklistItems = {
  ["minecraft:cobblestone"] = true,
  ["minecraft:dirt"] = true,
  ["minecraft:gravel"] = true,
  ["minecraft:diorite"] = true,
  ["minecraft:andesite"] = true,
  ["minecraft:granite"] = true
}

local xTarget, yTarget, zTarget

local storageSlots = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
local digSlot = 2


local function dig(direction)
  local handled = false

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
    if digDetail and blacklistItems[digDetail.name] then
      turtle.drop()
      handled = true
    end
    if not handled then
      if digDetail == fuel.getFuelType() and turtle.getItemSpace(fuel.getFuelSlot()) > 0 then
        turtle.transferTo(fuel.getFuelSlot())
        handled = true
      else
        for key, storage in pairs(storageSlots) do
          if turtle.transferTo(storage) then
            handled = true
            break
          end
        end
      end
      if not handled then turtle.drop() end
    end
  end
  return handled
end

local function fullDig()
  local xSign, ySign ,zSign
  if xTarget > 0 then xSign = 1 else xSign = -1 end
  if yTarget > 0 then ySign = 1 else ySign = -1 end
  if zTarget > 0 then zSign = 1 else zSign = -1 end

  local xMagnitude = math.abs(xTarget)
  local yMagnitude = math.abs(yTarget)
  local zMagnitude = math.abs(zTarget)

  for zCount = 1, zMagnitude do
    for yCount = 1, yMagnitude do

      movement.moveX(xSign * xMagnitude, {dig, fuel.checkAndRefuel})

      if yCount < yMagnitude then
        xSign = xSign * -1
        movement.moveY(ySign, {dig, fuel.checkAndRefuel})
      end
    end

    if zCount < zMagnitude then
      ySign = ySign * -1
      xSign = xSign * -1
      movement.moveZ(zSign, {dig, fuel.checkAndRefuel})
    end
  end

  movement.moveTo(0, 0, 0)
  movement.faceDir(0)
end


print "initializing..."
if #tArgs == 0 or tArgs[1] == "help" then
  textutils.pagedPrint(
    [[usage: Provide 3 arguments: x, y, z. 

    This describes a vector from the current bot position.
    Forward is positive x, Right is positive y, and Up is positive Z
    bot will then clear out full cube described by its position and the vector
    
    fuel should be placed in slot 1, it will use the fuel to move.
    when the same fuel type is dug, it will add the dug item to the fuel stack, and use it as fuel in the future.

    If the bot does run out of fuel, you will need to add more fuel to slot 1.
    ]]
  )

  return
end

xTarget, yTarget, zTarget = tonumber(tArgs[1]) or 0, tonumber(tArgs[2]) or 1, tonumber(tArgs[3]) or 1
print("target: ", xTarget, yTarget, zTarget)


local digItem = turtle.getItemDetail(digSlot)
if digItem ~= nil then
  error(string.format("dig slot is not empty! (slot %i)", digSlot))
end

fullDig()