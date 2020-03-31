local inventory
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

    -- check rest of inventory for fuel
    if turtle.getItemDetail() == nil then
      inventory.onEachInventory(
        function(i, item)
          if item.name == fuelType then
            turtle.select(i)
            turtle.transferTo(fuelSlot)
            turtle.select(fuelSlot)
            return true
          end
        end
      )
    end

    turtle.refuel(1)
    while turtle.getFuelLevel() < 1 do
      print("need fuel")
      os.sleep(5)
      local fuelDetail = turtle.getItemDetail(fuelSlot)
      if fuelDetail ~= nil then
        fuelType = fuelDetail.name
        print(string.format("using %s as fuel", fuelDetail.name))
      end

      turtle.refuel()
    end

    turtle.select(oldSlot)
  end
end

local function new(ops, _inventory)
  fuelSlot = ops and ops[fuelSlot] or 1

  if _inventory == nil then error "fuel needs inventory dependency" end
  inventory = _inventory

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