-- modules/inventory/server/removeItem.lua
-- Routes through sp.inventoryProvider.removeItem.
-- Always returns boolean.
-- metadata is NOT silently dropped (bug fixed Sprint 2, enforced here).
-- slot param added (optional).
function sp.removeItem(source, item, count, metadata, slot)
    if sp.inventoryProvider and type(sp.inventoryProvider.removeItem) == 'function' then
        local ok, result = pcall(sp.inventoryProvider.removeItem, source, item, count, metadata, slot)
        if not ok then return false end
        return result == true
    end
    return false
end

exports('RemoveItem', function(source, item, count, metadata, slot)
    return sp.removeItem(source, item, count, metadata, slot)
end)
