-- modules/inventory/server/createUsableItem.lua
-- Routes through sp.inventoryProvider.createUsableItem.
-- Always returns boolean.
function sp.createUsableItem(item, cb)
    if type(item) ~= 'string' or item == '' then return false end
    if type(cb) ~= 'function' then return false end

    if sp.inventoryProvider and type(sp.inventoryProvider.createUsableItem) == 'function' then
        local ok, result = pcall(sp.inventoryProvider.createUsableItem, item, cb)
        if not ok then return false end
        return result == true
    end

    return false
end

exports('CreateUsableItem', function(item, cb)
    return sp.createUsableItem(item, cb)
end)
