local tArgs = {...}

print "initializing..."
if #tArgs == 0 or tArgs[1] == "help" then
  textutils.pagedPrint(
    [[usage: Provide 2 arguments: repeatAmount, placeDirection

    repeatAmount: int
      the turtle will move forward <repeatAmount> times, 
       each time digging in front and placing a block in the chosen direction

    placeDirection: [up|down|left|right]
      the turtle will place a block in the chosen direction
    ]]
  )
  return
end


local repeatAmount, placeDirection = tonumber(tArgs[0]), tArgs[1]


local movement = dofile("API/movement.lua").movement
local inventory = dofile("API/inventory.lua").new({range={startIndex=3, endIndex=16}})
local fuel = dofile("API/refuel.lua").new(inventory, {fuelSlot = 1})
local digger = dofile("API/digger.lua").new(inventory, fuel, {dropAll = true, digSlot = 2})

local function place()

  local placeSlot

  repeat
  inventory.onEachInventory(function(slot)
    placeSlot = slot
    return true
  end)
  if placeSlot == nil then
    print "no items to place"
    os.sleep(5)
  end
  until placeSlot ~= nil

  turtle.select(placeSlot)

  if placeDirection == "up" then 
    turtle.placeUp()
  elseif placeDirection == "down" then 
    turtle.placeDown()
  elseif placeDirection == "left" then 
    movement.faceDir(movement.left)
    turtle.place()
  elseif placeDirection == "right" then
    movement.faceDir(movement.right)
    turtle.place()
  end
  movement.faceDir(movement.front)
end

movement.moveX(repeatAmount, {digger.dig, place, fuel.checkAndRefuel})
place()