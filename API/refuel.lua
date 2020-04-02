local inventory
local fuelType
local fuelSlot
local fuelBucketSlot

local lavaName = "minecraft:lava"
local lavaBucketName = "minecraft:lava_bucket"
local emptyBucketName = "minecraft:bucket"

local function getFuelType()
  return fuelType
end
local function getFuelSlot()
  return fuelSlot
end

local function checkAndFillLavaBucket(dirName)
  if fuelBucketSlot then

    local itemThere, item
    if not dirName or dirName == "forward" then
      itemThere, item = turtle.inspect()
    elseif dirName == "up" then
      itemThere, item = turtle.inspectUp()
    elseif dirName == "down" then
      itemThere, item = turtle.inspectDown()
    end

    if itemThere and item.name == lavaName and item.state.level == 0 then
      inventory.actOnSlot(fuelBucketSlot, function()

        local bucketItem = turtle.getItemDetail(fuelBucketSlot)

        if bucketItem and bucketItem.name == lavaBucketName then
          turtle.refuel()
        end

        if bucketItem and bucketItem.name == emptyBucketName then

          --if bucket is selected in inventory, then 'place' will consume and collect the lava
          if not dirName or dirName == "forward" then
            turtle.place()
          elseif dirName == "up" then
            turtle.placeUp()
          elseif dirName == "down" then
            turtle.placeDown()
          end

        end
      end)
    end
  else
    error("checkAndFillLavaBucket: no fuel bucket slot")
  end
end

local function checkAndRefuel()
  local level = turtle.getFuelLevel()
  if level == "unlimited" then return end

  if level < 1 then
    inventory.actOnSlot(fuelSlot, function()

      if fuelBucketSlot then
        local bucketItem = turtle.getItemDetail(fuelBucketSlot)
        if bucketItem and bucketItem.name == lavaBucketName then
          turtle.select(fuelBucketSlot)
          turtle.refuel()
          return
        end
      end
      -- check rest of inventory for fuel
      if turtle.getItemDetail() == nil then
        inventory.onEachInventory(function(i, item)
          if item.name == fuelType then
            turtle.select(i)
            turtle.transferTo(fuelSlot)
            turtle.select(fuelSlot)
            return true
          end
        end)
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
    end)
  end
end

local function new(ops, _inventory)
  fuelSlot = ops and ops.fuelSlot or 1
  fuelBucketSlot = ops and ops.bucketSlot

  if _inventory == nil then error "fuel needs inventory dependency" end
  inventory = _inventory

  turtle.select(fuelSlot)
  local fuelItem = turtle.getItemDetail(fuelSlot)
  if fuelItem == nil or not turtle.refuel(0) then
    error(string.format("no fuel item provided in slot %i", fuelSlot))
  end
  print(string.format("using %s as fuel", fuelItem.name))
  fuelType = fuelItem.name

  if fuelBucketSlot then
    turtle.select(fuelBucketSlot)
    local bucketItem = turtle.getItemDetail(fuelBucketSlot)
    if bucketItem == nil or (bucketItem.name ~= emptyBucketName and bucketItem.name ~= lavaBucketName) then
      error(string.format("no empty bucket item provided in slot %i", fuelBucketSlot))
    elseif bucketItem and bucketItem.count > 1 then
      error(string.format("can only carry one bucket in slot %i", fuelBucketSlot))
    end
    
    print("bucket detected, will use lava to refuel")
  end

  return {
    checkAndRefuel = checkAndRefuel,
    checkAndFillLavaBucket = checkAndFillLavaBucket,
    getFuelType = getFuelType,
    getFuelSlot = getFuelSlot
  }
end

return {
  new = new
}