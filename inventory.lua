

local function new(ops)
  local invRange = ops.range

  local function _eachInv(action, startIndex, endIndex, allSlots)

    if not startIndex and not invRange and not invRange.startIndex then error("start index missing") end
    if not endIndex and not invRange and not invRange.endIndex then error("end index missing") end

    for i = startIndex or invRange.startIndex, endIndex or invRange.endIndex do
      local item = turtle.getItemDetail(i)
      if (allSlots or item) and action(i, item) then break end
    end
  end

  local function onEachInventory(action, startIndex, endIndex)
    _eachInv(action, startIndex, endIndex, false)
  end

  local function onEachInventorySlot(action, startIndex, endIndex)
    _eachInv(action, startIndex, endIndex, true)
  end

  return {
    onEachInventory = onEachInventory,
    onEachInventorySlot = onEachInventorySlot
  }
end

return {
  new = new
}