-- modules/inventory/server/addItem.lua
-- Routes through sp.inventoryProvider.addItem.
-- Always returns boolean.
-- slot param added (optional); nil = provider default slot assignment.
function sp.addItem(source, item, count, metadata, slot)
    if sp.inventoryProvider and type(sp.inventoryProvider.addItem) == 'function' then
        local ok, result = pcall(sp.inventoryProvider.addItem, source, item, count, metadata, slot)
        if not ok then return false end
        return result == true
    end
    return false
end

exports('AddItem', function(source, item, count, metadata, slot)
    return sp.addItem(source, item, count, metadata, slot)
end)
