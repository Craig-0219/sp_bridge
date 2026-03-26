-- modules/inventory/providers/qb/server.lua
-- qb-inventory provider. Self-registers when sp.inventory == Inventories.QB.
--
-- Limitations:
--   getItemCount  — metadata not supported (qb-inventory has no metadata-filtered count)
--   hasItem       — same as getItemCount
--   canCarryItem  — metadata not supported (qb-inventory:CanAddItem ignores metadata)
if sp.inventory ~= Inventories.QB then return end

local provider = {}

--- qb-inventory AddItem(source, item, count, slot, metadata)
--- slot defaults to nil when not provided.
function provider.addItem(source, item, count, metadata, slot)
    local ok, result = pcall(function()
        return exports['qb-inventory']:AddItem(source, item, count, slot, metadata)
    end)
    if not ok then return false end
    return result ~= false
end

--- qb-inventory RemoveItem(source, item, count, metadata, slot)
--- metadata IS forwarded — not silently dropped (fixed Sprint 2).
function provider.removeItem(source, item, count, metadata, slot)
    local ok, result = pcall(function()
        return exports['qb-inventory']:RemoveItem(source, item, count, metadata, slot)
    end)
    if not ok then return false end
    return result ~= false
end

--- @limitation metadata ignored — qb-inventory has no metadata-filtered count API.
--- Returns total count of the item across all slots.
function provider.getItemCount(source, item, metadata)
    local ok, count = pcall(function()
        return exports['qb-inventory']:GetItemCount(source, item)
    end)
    if ok and type(count) == 'number' then return count end
    return 0
end

--- @limitation metadata not considered (see getItemCount limitation).
function provider.hasItem(source, item, count, metadata)
    return provider.getItemCount(source, item, nil) >= (count or 1)
end

--- @limitation metadata not forwarded — qb-inventory:CanAddItem does not support it.
function provider.canCarryItem(source, item, count, metadata)
    local ok, result = pcall(function()
        return exports['qb-inventory']:CanAddItem(source, item, count)
    end)
    if not ok then return false end
    if type(result) == 'boolean' then return result end
    return false
end

--- createUsableItem is framework-scoped, not inventory-scoped.
--- Routes by sp.framework since qb-inventory is used with both QBCore and QBOX.
function provider.createUsableItem(item, cb)
    if sp.framework == Framework.QBOX then
        -- QBOX: CoreObject is string 'qbx_core'; must use exports directly
        local ok = pcall(function() exports.qbx_core:CreateUseableItem(item, cb) end)
        return ok
    end

    if sp.framework == Framework.QBCore
        and type(CoreObject) == 'table'
        and type(CoreObject.Functions) == 'table'
        and type(CoreObject.Functions.CreateUseableItem) == 'function'
    then
        CoreObject.Functions.CreateUseableItem(item, cb)
        return true
    end

    -- ESX + qb-inventory is not a standard combination; not supported
    return false
end

--- QBOX: CoreObject is string; must use exports.qbx_core:GetItems().
--- QBCore: CoreObject.Shared.Items is available directly.
function provider.getItemLabel(item)
    if sp.framework == Framework.QBOX then
        local ok, items = pcall(function() return exports.qbx_core:GetItems() end)
        if ok and type(items) == 'table' then
            local def = items[item]
            if type(def) == 'table' and type(def.label) == 'string' and def.label ~= '' then
                return def.label
            end
        end
        return nil
    end

    if type(CoreObject) == 'table'
        and type(CoreObject.Shared) == 'table'
        and type(CoreObject.Shared.Items) == 'table'
    then
        local def = CoreObject.Shared.Items[item]
        if type(def) == 'table' and type(def.label) == 'string' and def.label ~= '' then
            return def.label
        end
    end

    return nil
end

function provider.getItemDefinitions()
    if sp.framework == Framework.QBOX then
        local ok, items = pcall(function() return exports.qbx_core:GetItems() end)
        if ok and type(items) == 'table' then return items end
        return {}
    end

    if type(CoreObject) == 'table'
        and type(CoreObject.Shared) == 'table'
        and type(CoreObject.Shared.Items) == 'table'
    then
        return CoreObject.Shared.Items
    end

    return {}
end

sp.inventoryProvider = provider
sp.print.info('[provider] qb-inventory server provider registered')
