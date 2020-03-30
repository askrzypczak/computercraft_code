local x, y, z = 0, 0, 0
local face = 0

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
    if face == 0 then x = x + 1
    elseif face == 1 then y = y + 1
    elseif face == 2 then x = x - 1
    elseif face == 3 then y = y - 1
    end
  else print "error moving forward!"
  end
end


local function createMovementFunction(faceIfGreater, faceIfLesser)
  local function movementFunction(dist, callbacks)
    local goal = x + dist

    if dist > 0 then
      faceDir(faceIfGreater)
    elseif dist < 0 then
      faceDir(faceIfLesser)
    end
    if dist ~= 0 then
      while x ~= goal do
        for i, callback in pairs(callbacks) do callback() end
        forward()
      end
    end
  end

  return movementFunction
end

local moveX = createMovementFunction(0, 2)
local moveY = createMovementFunction(1, 3)

local function moveZ(dist, dig, callbacks)
  local goal = z + dist

  if dist > 0 then
    for i = 1, dist do
      if dig then dig("up") end
      up()
    end
  elseif dist < 0 then
    while z ~= goal do
      for i, callback in pairs(callbacks) do callback() end
      if dig then dig("down") end
      down()
    end
  end
end

return { movement = { moveX = moveX, moveY = moveY, moveZ = moveZ } }