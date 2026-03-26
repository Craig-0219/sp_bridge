-- modules/inventory/server/createUsableItem.lua
-- Routes through sp.inventoryProvider.createUsableItem.
-- ESX native fallback: CoreObject.RegisterUsableItem / exports path
-- when no third-party inventory provider is registered.
-- Always returns boolean.
function sp.createUsableItem(item, cb)
    if type(item) ~= 'string' or item == '' then return false end
    if type(cb) ~= 'function' then return false end

    if sp.inventoryProvider and type(sp.inventoryProvider.createUsableItem) == 'function' then
        local ok, result = pcall(sp.inventoryProvider.createUsableItem, item, cb)
        if not ok then return false end
        return result == true
    end

    -- ESX native fallback when no third-party inventory (ox/qb/qs) is active.
    -- CoreObject = ESX shared object (has RegisterUsableItem).
    if sp.framework == Framework.ESX then
        if type(CoreObject) == 'table' and type(CoreObject.RegisterUsableItem) == 'function' then
            local ok = pcall(function() CoreObject.RegisterUsableItem(item, cb) end)
            if ok then return true end
        end
        -- Alternative: direct export (ESX Legacy 1.9+)
        local ok = pcall(function() exports.es_extended:RegisterUsableItem(item, cb) end)
        return ok
    end

    return false
end

exports('CreateUsableItem', function(item, cb)
    return sp.createUsableItem(item, cb)
end)
