

local function new(ops)
  local invRange = ops.range

  local function onEachInventory(action, startIndex, endIndex)
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