-- modules/inventory/providers/ox/server.lua
-- OX inventory provider. Self-registers when sp.inventory == Inventories.OX.
if sp.inventory ~= Inventories.OX then return end

local provider = {}

--- @limitation slot: ox_inventory AddItem does not use a slot param in most versions.
--- metadata IS forwarded natively.
function provider.addItem(source, item, count, metadata, slot)
    local ok, result = pcall(function()
        return exports.ox_inventory:AddItem(source, item, count, metadata)
    end)
    if not ok then return false end
    -- ox returns true on success; nil in some older versions also means success
    return result ~= false
end

--- metadata and slot are both forwarded; ox supports both natively.
function provider.removeItem(source, item, count, metadata, slot)
    local ok, result = pcall(function()
        return exports.ox_inventory:RemoveItem(source, item, count, metadata, slot)
    end)
    if not ok then return false end
    return result == true
end

--- metadata filter is supported by ox_inventory:Search natively.
function provider.getItemCount(source, item, metadata)
    local ok, count = pcall(function()
        return exports.ox_inventory:Search(source, 'count', item, metadata)
    end)
    if ok and type(count) == 'number' then return count end
    return 0
end

function provider.hasItem(source, item, count, metadata)
    return provider.getItemCount(source, item, metadata) >= (count or 1)
end

--- @limitation metadata support in CanCarryItem varies by ox_inventory version.
function provider.canCarryItem(source, item, count, metadata)
    local ok, result = pcall(function()
        return exports.ox_inventory:CanCarryItem(source, item, count, metadata)
    end)
    if not ok then return false end
    if type(result) == 'boolean' then return result end
    return false
end

function provider.getItemLabel(item)
    local ok, items = pcall(function()
        return exports.ox_inventory:Items()
    end)
    if not ok or type(items) ~= 'table' then return nil end
    local def = items[item]
    if type(def) == 'table' and type(def.label) == 'string' and def.label ~= '' then
        return def.label
    end
    return nil
end

function provider.getItemDefinitions()
    local ok, items = pcall(function()
        return exports.ox_inventory:Items()
    end)
    if ok and type(items) == 'table' then return items end
    return {}
end

--- OX inventory: try ox_inventory:RegisterUsableItem first.
--- Falls back to framework-level registration for ESX / QBCore / QBOX.
function provider.createUsableItem(item, cb)
    local ok = pcall(function()
        exports.ox_inventory:RegisterUsableItem(item, cb)
    end)
    if ok then return true end

    -- Fallback: framework-level registration when ox export is unavailable.
    if sp.framework == Framework.QBOX then
        local ok2 = pcall(function() exports.qbx_core:CreateUseableItem(item, cb) end)
        return ok2
    end

    if sp.framework == Framework.QBCore
        and type(CoreObject) == 'table'
        and type(CoreObject.Functions) == 'table'
        and type(CoreObject.Functions.CreateUseableItem) == 'function'
    then
        local ok2 = pcall(function() CoreObject.Functions.CreateUseableItem(item, cb) end)
        return ok2
    end

    if sp.framework == Framework.ESX then
        -- Attempt 1: CoreObject cached at startup
        if type(CoreObject) == 'table' and type(CoreObject.RegisterUsableItem) == 'function' then
            local ok2 = pcall(function() CoreObject.RegisterUsableItem(item, cb) end)
            if ok2 then return true end
        end
        -- Attempt 2: fetch fresh shared object (handles stale CoreObject at startup)
        local ok2, esx = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok2 and type(esx) == 'table' and type(esx.RegisterUsableItem) == 'function' then
            local ok3 = pcall(function() esx.RegisterUsableItem(item, cb) end)
            return ok3
        end
        return false
    end

    return false
end

sp.inventoryProvider = provider
sp.print.info('[provider] ox_inventory server provider registered')
