local x, y, z = 0, 0, 0
local face = 0

local function getX() return x end
local function getY() return y end
local function getZ() return z end

local front, right, back, left = 0, 1, 2, 3

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
    if face == front then x = x + 1
    elseif face == right then y = y + 1
    elseif face == back then x = x - 1
    elseif face == left then y = y - 1
    end
  else print "error moving forward!"
  end
end

local function invokeCallbacks(callbacks, face)
  if callbacks then
    for i, callback in pairs(callbacks) do callback(face) end
  end
end

local function createMovementFunction(faceIfGreater, faceIfLesser, getCoord)
  local function movementFunction(dist, callbacks)
    local goal = getCoord() + dist

    if dist > 0 then
      faceDir(faceIfGreater)
    elseif dist < 0 then
      faceDir(faceIfLesser)
    end
    if dist ~= 0 then
      while getCoord() ~= goal do
        invokeCallbacks(callbacks)
        forward()
      end
    end
  end

  return movementFunction
end

local moveX = createMovementFunction(0, 2, function() return x end)
local moveY = createMovementFunction(1, 3, function() return y end)

local function moveZ(dist, callbacks)
  local goal = z + dist

  if dist > 0 then
    while z ~= goal do
      invokeCallbacks(callbacks, "up")
      up()
    end
  elseif dist < 0 then
    while z ~= goal do
      invokeCallbacks(callbacks, "down")
      down()
    end
  end
end

local function moveTo(targetX, targetY, targetZ, callbacks)
  moveX(targetX - x, callbacks)
  moveY(targetY - y, callbacks)
  moveZ(targetZ - z, callbacks)
end
local function moveToBackwards(targetX, targetY, targetZ, callbacks)  
  moveZ(targetZ - z, callbacks)
  moveY(targetY - y, callbacks)
  moveX(targetX - x, callbacks)
end


local function getSigns(...)
  local args = {...}
  for i, val in pairs(args) do
    if val > 0 then args[i] = 1 else args[i] = -1 end
  end
  return table.unpack(args)
end
local function getMagnitude(...)
  local args = {...}
  for i, val in pairs(args) do
    args[i] = math.abs(val)
  end
  return table.unpack(args)
end

--the bot will occupy every space in the cube decribed by the bots current position and the end of the vector.
local function coverMove(xVector, yVector, zVector, callbacks)

  local xSign, ySign, zSign = getSigns(xVector, yVector, zVector)
  local xMagnitude, yMagnitude, zMagnitude = getMagnitude(xVector, yVector, zVector)

  for zCount = 0, zMagnitude do
    for yCount = 0, yMagnitude do

      moveX(xSign * xMagnitude, callbacks)

      if yCount < yMagnitude then
        xSign = xSign * -1
        moveY(ySign, callbacks)
      end
    end

    if zCount < zMagnitude then
      ySign = ySign * -1
      xSign = xSign * -1
      moveZ(zSign, callbacks)
    end
  end
end

--the bot will 'observe' every space (by having callbacks be invoked in the direction of each block at least once) in the cube decribed by the bots current position and the end of the vector.
--this is more fuel efficient.
--once this function is properly tested, will need to generalize it and use it to replace coverMove
local function observeMove(xVector, yVector, zVector, callbacks)

  local xSign, ySign, zSign = getSigns(xVector, yVector, zVector)
  local xMagnitude, yMagnitude, zMagnitude = getMagnitude(xVector, yVector, zVector)

  local zMax = math.max(z, z + zVector)
  local zMin = math.min(z, z + zVector)

  local function xLoop()
    for xCount = 0, xMagnitude do
      if z ~= zMax then
        invokeCallbacks(callbacks, "up")
      end
      if z ~= zMin then
        invokeCallbacks(callbacks, "down")
      end
      if xCount < xMagnitude then
        moveX(xSign, callbacks)
      end
    end
  end

  local function planeLoop()
    for yCount = 0, yMagnitude do
      xLoop()
      if yCount < yMagnitude then
        xSign = xSign * -1
        moveY(ySign, callbacks)
      end
    end
  end
  
  for zCount = 0, zMagnitude, 3 do
    planeLoop()
    if zCount < zMagnitude then
      ySign = ySign * -1
      xSign = xSign * -1

      local zTarget
      if zSign == 1 then
        zTarget = math.min(zMax - z, zSign * 3)
      else
        zTarget = math.max(zMin + z, zSign * 3)
      end
      moveZ(zTarget, callbacks)
    end
  end

  local lastPass
  if zSign == 1 then
    lastPass = (z+1) < zMax
  else
    lastPass = (z-1) > zMin
  end
  if lastPass then
    planeLoop()
  end
end

return {
  movement = {
    front = front,
    back = back,
    left = left,
    right = right,
    getX = getX,
    getY = getY,
    getZ = getZ,
    moveX = moveX,
    moveY = moveY,
    moveZ = moveZ,
    moveTo = moveTo,
    moveToBackwards = moveToBackwards,
    coverMove = coverMove,
    observeMove = observeMove,
    faceDir = faceDir
  }
}