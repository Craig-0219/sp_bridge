-- modules/inventory/server/addItem.lua
-- Routes through sp.inventoryProvider.addItem.
-- ESX native fallback: Player.addInventoryItem when no third-party inventory.
-- Always returns boolean.
-- slot param added (optional); nil = provider default slot assignment.
function sp.addItem(source, item, count, metadata, slot)
    if sp.inventoryProvider and type(sp.inventoryProvider.addItem) == 'function' then
        local ok, result = pcall(sp.inventoryProvider.addItem, source, item, count, metadata, slot)
        if not ok then return false end
        return result == true
    end

    -- ESX native inventory: Player.addInventoryItem(item, count)
    -- Used when no third-party inventory (ox/qb/qs) is detected.
    if sp.framework == Framework.ESX then
        local getP = sp.frameworkProvider and sp.frameworkProvider.getPlayer
        local Player = type(getP) == 'function' and getP(source) or nil
        if not Player then return false end
        local ok = pcall(function() Player.addInventoryItem(item, count) end)
        return ok
    end

    return false
end

exports('AddItem', function(source, item, count, metadata, slot)
    return sp.addItem(source, item, count, metadata, slot)
end)
