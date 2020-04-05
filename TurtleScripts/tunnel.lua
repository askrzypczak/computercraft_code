local tArgs = {...}

print "initializing..."
if #tArgs == 0 or tArgs[1] == "help" then
  textutils.pagedPrint(
    [[usage: Provide 2 arguments: repeatAmount, human

    repeatAmount: int
      the turtle will move forward <repeatAmount> times, 
       each time digging in front
    
    human: [human]
      if provided, will make the tunnel 2 blocks high

    ]]
    
  )
  return
end


local repeatAmount, human = tonumber(tArgs[1]), tArgs[2] or false


local movement = dofile("/API/movement.lua").movement
local inventory = dofile("/API/inventory.lua").new({range={startIndex=3, endIndex=16}})
local fuel = dofile("/API/refuel.lua").new(inventory, {fuelSlot = 1})
local digger = dofile("/API/digger.lua").new(inventory, fuel, {dropAll = true, digSlot = 2})


local tunnel
if human then 
  tunnel = function(direction)
    digger.dig(direction)
    digger.dig("up")
  end
else
  tunnel = digger.dig
end

movement.moveX(repeatAmount, {tunnel, fuel.checkAndRefuel})
if human then 
  digger.dig("up")
end