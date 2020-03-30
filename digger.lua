local movement = dofile("movement.lua").movement

local tArgs = {...}

local blacklistItems = {
  ["minecraft:cobblestone"] = true,
  ["minecraft:dirt"] = true,
  ["minecraft:gravel"] = true
}

local xTarget, yTarget, zTarget = 0, 1, 1


local storageSlots = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
local digSlot = 2
local fuelSlot = 1

local fuelType

local function checkAndRefuel()
  local level = turtle.getFuelLevel()
  if level == "unlimited" then return end

  if level < 1 then
    local oldSlot = turtle.getSelectedSlot()
    turtle.select(fuelSlot)

    local success = turtle.refuel()
    if not success then print("need fuel") end
    while turtle.getFuelLevel() < 1 do

      local fuelDetail = turtle.getItemDetail(fuelSlot)
      if fuelDetail ~= nil then
        fuelType = fuelDetail.name
        print(string.format("using %s as fuel", fuelDetail.name))
      end

      turtle.refuel()
      os.sleep(5)
    end

    turtle.select(oldSlot)
  end
end

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
      if digDetail == fuelType and turtle.getItemSpace(fuelSlot) > 0 then
        turtle.transferTo(fuelSlot)
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

      movement.moveX(xSign * xMagnitude, {dig, checkAndRefuel})

      if yCount < yMagnitude then
        xSign = xSign * -1
        movement.moveY(ySign, {dig, checkAndRefuel})
      end
    end

    if zCount < zMagnitude then
      ySign = ySign * -1
      xSign = xSign * -1
      movement.moveZ(zSign, dig, {checkAndRefuel})
    end
  end

  movement.moveX(xTarget * -1)
  movement.moveY(yTarget * -1)
  movement.moveZ(zTarget * -1)
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

xTarget, yTarget, zTarget = tonumber(tArgs[1]), tonumber(tArgs[2]), tonumber(tArgs[3])
print("target: ", xTarget, yTarget, zTarget)


turtle.select(fuelSlot)
local fuelItem = turtle.getItemDetail(fuelSlot)
if fuelItem == nil then
  error(string.format("no fuel item provided in slot %i", fuelSlot))
end
print(string.format("using %s as fuel", fuelItem.name))
fuelType = fuelItem.name


local digItem = turtle.getItemDetail(digSlot)
if digItem ~= nil then
  error(string.format("dig slot is not empty! (slot %i)", digSlot))
end

fullDig()