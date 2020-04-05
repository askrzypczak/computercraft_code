
local function new(inventory, fuel, ops)
  if not inventory then error "missing inventory dependency" end
  if not fuel then error "missing fuel dependency" end

  local dropAll = ops and ops.dropAll or false
  local blacklistItems = ops and ops.blacklistItems or {}
  local whitelistItems = ops and ops.whitelistItems or {}
  local digSlot = ops and ops.digSlot or error("dig slot not provided")

  local digItem = turtle.getItemDetail(digSlot)
  if digItem ~= nil then
    print(string.format("dig slot is not empty! (slot %i) - droping item", digSlot))
    inventory.actOnSlot(digSlot, function() turtle.drop() end)
  end

  local function getDigSlot() return digSlot end

  local function dig(direction)
    local handled = false

    local blockDetect
    if not direction or direction == "forward" then
      blockDetect = turtle.detect()
    elseif direction == "up" then
      blockDetect = turtle.detectUp()
    elseif direction == "down" then
      blockDetect = turtle.detectDown()
    end
    if blockDetect then
      inventory.actOnSlot(digSlot, function()

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
          if digDetail and not whitelistItems[digDetail.name] and (blacklistItems[digDetail.name] or dropAll) then
            turtle.drop()
            handled = true
          end
          if not handled then
            if digDetail == fuel.getFuelType() and turtle.getItemSpace(fuel.getFuelSlot()) > 0 then
              turtle.transferTo(fuel.getFuelSlot())
              handled = true
            else
              inventory.onEachInventorySlot(
                function (i)
                  if turtle.transferTo(i) then
                    handled = true
                    return true
                  end
                end
              )
            end
            if not handled then turtle.drop() end
          end
        end
      end)
    end
    return handled
  end

  return {
    dig = dig,
    getDigSlot = getDigSlot
  }

end

return {
  new = new
}