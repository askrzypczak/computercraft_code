local tArgs = {...}

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

    To equip a diamond pick, use the command "equip <slot> right"
    ]]
  )
  return
end


local xTarget, yTarget, zTarget = tonumber(tArgs[1]) or 0, tonumber(tArgs[2]) or 0, tonumber(tArgs[3]) or 0
print("target: ", xTarget, yTarget, zTarget)

local digSlot = 3

local digItem = turtle.getItemDetail(digSlot)
if digItem ~= nil then
  error(string.format("dig slot is not empty! (slot %i)", digSlot))
end

local movement = dofile("API/movement.lua").movement
local inventory = dofile("API/inventory.lua").new({range={startIndex=4, endIndex=16}})
local fuel = dofile("API/refuel.lua").new(inventory, {fuelSlot = 1, bucketSlot = 2})


local blacklistItems = {
  ["minecraft:cobblestone"] = true,
  ["minecraft:dirt"] = true,
  ["minecraft:gravel"] = true,
  ["minecraft:diorite"] = true,
  ["minecraft:andesite"] = true,
  ["minecraft:granite"] = true
}

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
        inventory.onEachInventorySlot(
          function (i)
            if turtle.transferTo(i) then
              handled = true
              return true
            end
          end
        )
      end
      if not handled then turtle.drop() end
    end
  end
  return handled
end

local moveActions = {dig, fuel.checkAndFillLavaBucket, fuel.checkAndRefuel}
movement.observeMove(xTarget, yTarget, zTarget, moveActions)
movement.moveToBackwards(0, 0, 0, moveActions)
movement.faceDir(0)
