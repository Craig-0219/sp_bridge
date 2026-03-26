-- modules/inventory/server/canCarryItem.lua
-- Routes through sp.inventoryProvider.canCarryItem.
-- Always returns boolean.
-- Fallback when no provider registered: true (permissive, for dev/testing).
-- Note: QB provider does not support metadata in canCarryItem.
function sp.canCarryItem(source, item, count, metadata)
    if sp.inventoryProvider and type(sp.inventoryProvider.canCarryItem) == 'function' then
        local ok, result = pcall(sp.inventoryProvider.canCarryItem, source, item, count, metadata)
        if ok then return result == true end
        return false -- pcall failed = inventory error, conservative response
    end
    return true -- no provider = assume can carry (development fallback)
end

exports('CanCarryItem', function(source, item, count, metadata)
    return sp.canCarryItem(source, item, count, metadata)
end)
