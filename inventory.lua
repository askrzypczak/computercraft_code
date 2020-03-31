

local function new(ops)
  local invRange = ops.range

  local function onEachInventory(action, startIndex, endIndex)

    if not startIndex and not invRange then error("start index missing") end
    if not endIndex and not invRange then error("end index missing") end

    for i = startIndex or invRange.startIndex, endIndex or invRange.endIndex do
      local item = turtle.getItemDetail(i)
      if item and action(i, item) then break end
    end
  end

  return {
    onEachInventory = onEachInventory
  }
end

return {
  new = new
}