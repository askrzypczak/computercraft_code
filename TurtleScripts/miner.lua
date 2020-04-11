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


local blacklistItems = {
  ["minecraft:cobblestone"] = true,
  ["minecraft:dirt"] = true,
  ["minecraft:gravel"] = true,
  ["minecraft:diorite"] = true,
  ["minecraft:andesite"] = true,
  ["minecraft:granite"] = true,
  ["embellishcraft:slate_cobblestone"] = true,
  ["embellishcraft:marble_cobblestone"] = true,
  ["embellishcraft:larvikite_cobblestone"] = true,
  ["embellishcraft:gneiss_cobblestone"] = true,
  ["mapperbase:raw_bitumen"] = true
}

local movement = dofile("API/movement.lua").movement
local inventory = dofile("API/inventory.lua").new({range={startIndex=4, endIndex=16}})
local fuel = dofile("API/refuel.lua").new(inventory, {fuelSlot = 1, bucketSlot = 2})
local digger = dofile("API/digger.lua").new(inventory, fuel, {blacklistItems = blacklistItems, digSlot = 3})


local moveActions = {digger.dig, fuel.checkAndFillLavaBucket, fuel.checkAndRefuel}
movement.observeMove(xTarget, yTarget, zTarget, moveActions)
movement.moveToBackwards(0, 0, 0, moveActions)
movement.faceDir(movement.front)
