local tArgs = {...}

local blacklistItems = {
  ["minecraft:cobblestone"] = true,
  ["minecraft:dirt"] = true,
  ["minecraft:gravel"] = true
}

local xTarget = tonumber(tArgs[1]) or 0
local yTarget = tonumber(tArgs[2]) or 1
local zTarget = tonumber(tArgs[3]) or 1

print("target: ", xTarget, yTarget, zTarget)


local storageSlots = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
local digSlot = 2
local fuelSlot = 1

local x, y, z = 0, 0, 0

local face = 0

local function turnRight()
  turtle.turnRight()
  if face >= 3 then face = 0
  else face = face + 1
  end
end

local function turnLeft()
  turtle.turnLeft()
  if face == 0 then face = 3
  else face = face - 1
  end
end

local function faceDir(dir)
  if dir == 3 and face == 0 then turnLeft()
  elseif dir - face == -1 then turnLeft()
  else while face ~= dir do turnRight() end
  end
end

local function forward()
  if turtle.forward() then 
    if face == 0 then x = x + 1
    elseif face == 1 then y = y + 1
    elseif face == 2 then x = x - 1
    elseif face == 3 then y = y - 1
    end
  else print "error moving forward!"
  end
end

local function up()
  if turtle.up() then z = z + 1
  else print "error moving up!"
  end
end

local function down()
  if turtle.down() then z = z - 1
  else print "error moving down!"
  end
end

local function checkAndRefuel()
  local level = turtle.getFuelLevel()
  if level == "unlimited" then return end

  if level < 1 then
    local oldSlot = turtle.getSelectedSlot()
    turtle.select(fuelSlot)

    local success = turtle.refuel()
    if not success then print("need fuel") end
    while turtle.getFuelLevel() < 1 do
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
      if turtle.compareTo(fuelSlot) and turtle.getItemSpace(fuelSlot) > 0 then
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

local function moveX(dist, doDig)
  local goal = x + dist

  if dist > 0 then 
    faceDir(0)
  elseif dist < 0 then
    faceDir(2)
  end
  if dist ~= 0 then
    while x ~= goal do
      checkAndRefuel()
      if doDig then dig() end
      forward()
    end
  end
end

local function moveY(dist, doDig)
  local goal = y + dist

  if dist > 0 then 
    faceDir(1)
  elseif dist < 0 then
    faceDir(3)
  end
  if dist ~= 0 then 
    while y ~= goal do 
      checkAndRefuel()
      if doDig then dig() end
      forward()
    end
  end
end

local function moveZ(dist, doDig)
  local goal = z + dist

  if dist > 0 then 
    for i = 1, dist do 
      if doDig then dig("up") end
      up()
    end
  elseif dist < 0 then
    while z ~= goal do
      checkAndRefuel()
      if doDig then dig("down") end
      down()
    end
  end
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

      moveX(xSign * xMagnitude, true)

      if yCount < yMagnitude then
        xSign = xSign * -1
        moveY(ySign, true)
      end
    end

    if zCount < zMagnitude then 
      ySign = ySign * -1
      xSign = xSign * -1
      moveZ(zSign, true)
    end
  end
end




print "initializing..."

turtle.select(fuelSlot)
local fuelItem = turtle.getItemDetail(fuelSlot)
if fuelItem == nil then
  error(string.format("no fuel item provided in slot %i", fuelSlot))
end
print(string.format("using %s as fuel", fuelItem.name))

local digItem = turtle.getItemDetail(digSlot)
if digItem ~= nil then 
  error(string.format("dig slot is not empty! (slot %i)", digSlot))
end

fullDig()