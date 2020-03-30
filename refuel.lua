

local fuelType, fuelSlot

local function getFuelType()
  return fuelType
end
local function getFuelSlot()
  return fuelSlot
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

local function new(ops)
  fuelSlot = ops and ops[fuelSlot] or 1

  turtle.select(fuelSlot)
  local fuelItem = turtle.getItemDetail(fuelSlot)
  if fuelItem == nil then
    error(string.format("no fuel item provided in slot %i", fuelSlot))
  end
  print(string.format("using %s as fuel", fuelItem.name))
  fuelType = fuelItem.name

  return {
    checkAndRefuel = checkAndRefuel,
    getFuelType = getFuelType,
    getFuelSlot = getFuelSlot
  }
end

return {
  new = new
}