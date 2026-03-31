-- modules/inventory/server/createUsableItem.lua
-- Routes through sp.inventoryProvider.createUsableItem.
-- ESX native fallback (three attempts) when no third-party inventory.
-- Always returns boolean.
function sp.createUsableItem(item, cb)
    if type(item) ~= 'string' or item == '' then return false end
    if type(cb) ~= 'function' then return false end

    if sp.inventoryProvider and type(sp.inventoryProvider.createUsableItem) == 'function' then
        local ok, result = pcall(sp.inventoryProvider.createUsableItem, item, cb)
        if not ok then return false end
        return result == true
    end

    -- QBOX native fallback: used when no third-party inventory provider is detected.
    -- CoreObject for QBOX is the string 'qbx_core', NOT a table — must use exports directly.
    if sp.framework == Framework.QBOX then
        local ok = pcall(function() exports.qbx_core:CreateUseableItem(item, cb) end)
        if ok then return true end
        sp.print.warn('[inventory] createUsableItem QBOX path failed item=' .. item)
        return false
    end

    -- ESX native fallback: used when no third-party inventory is detected.
    -- Three attempts in order of reliability:
    if sp.framework == Framework.ESX then
        -- Attempt 1: CoreObject cached at startup (standard ESX Legacy path)
        if type(CoreObject) == 'table' and type(CoreObject.RegisterUsableItem) == 'function' then
            local ok = pcall(function() CoreObject.RegisterUsableItem(item, cb) end)
            if ok then return true end
            sp.print.warn('[inventory] createUsableItem ESX CoreObject path failed item=' .. item)
        end

        -- Attempt 2: direct export (some ESX forks expose this explicitly)
        do
            local ok = pcall(function() exports.es_extended:RegisterUsableItem(item, cb) end)
            if ok then return true end
        end

        -- Attempt 3: fetch fresh shared object at call-time.
        -- Handles cases where CoreObject was nil/incomplete at resource startup.
        do
            local ok, esx = pcall(function()
                return exports['es_extended']:getSharedObject()
            end)
            if ok and type(esx) == 'table' and type(esx.RegisterUsableItem) == 'function' then
                local ok2 = pcall(function() esx.RegisterUsableItem(item, cb) end)
                if ok2 then return true end
            end
        end

        sp.print.warn('[inventory] createUsableItem ESX all paths failed item=' .. item)
        return false
    end

    return false
end

exports('CreateUsableItem', function(item, cb)
    return sp.createUsableItem(item, cb)
end)
