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

    To equip a diamond pick, use the command "digger equip"
    ]]
  )
  return
end

if tArgs[1] == "equip" then
  turtle.select(1)
  if turtle.equipRight() then print "equiped!" else print "equip failed" end
  return
end

local xTarget, yTarget, zTarget = tonumber(tArgs[1]) or 0, tonumber(tArgs[2]) or 1, tonumber(tArgs[3]) or 1
print("target: ", xTarget, yTarget, zTarget)

local digSlot = 2

local digItem = turtle.getItemDetail(digSlot)
if digItem ~= nil then
  error(string.format("dig slot is not empty! (slot %i)", digSlot))
end

local movement = dofile("movement.lua").movement
local inventory = dofile("inventory.lua").new({range={startIndex=3, endIndex=16}})
local fuel = dofile("refuel.lua").new({fuelSlot = 1}, inventory)


local blacklistItems = {
  ["minecraft:cobblestone"] = true,
  ["minecraft:dirt"] = true,
  ["minecraft:gravel"] = true,
  ["minecraft:diorite"] = true,
  ["minecraft:andesite"] = true,
  ["minecraft:granite"] = true
}

local storageSlots = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}


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

movement.coverMove(xTarget, yTarget, zTarget, {dig, fuel.checkAndRefuel})
movement.moveTo(0, 0, 0)
movement.faceDir(0)
