-- modules/inventory/providers/qs/server.lua
-- qs-inventory provider. Self-registers when sp.inventory == Inventories.QS.
--
-- Limitations:
--   getItemCount  — no metadata filtering (GetItemTotalAmount is total count only)
--   hasItem       — same as getItemCount
--   getItemLabel  — qs-inventory has no own item label API;
--                   delegates to framework layer (QB Shared.Items or qbx_core:GetItems)
--   getItemDefinitions — uses qs-inventory:GetItemList() if available
if sp.inventory ~= Inventories.QS then return end

local provider = {}

--- qs-inventory AddItem(source, item, count, slot, metadata)
function provider.addItem(source, item, count, metadata, slot)
    local ok, result = pcall(function()
        return exports['qs-inventory']:AddItem(source, item, count, slot, metadata)
    end)
    if not ok then return false end
    return result ~= false
end

--- qs-inventory RemoveItem(source, item, count, slot, metadata)
--- metadata IS forwarded.
function provider.removeItem(source, item, count, metadata, slot)
    local ok, result = pcall(function()
        return exports['qs-inventory']:RemoveItem(source, item, count, slot, metadata)
    end)
    if not ok then return false end
    return result ~= false
end

--- @limitation metadata not supported; returns total count across all slots.
function provider.getItemCount(source, item, metadata)
    local ok, count = pcall(function()
        return exports['qs-inventory']:GetItemTotalAmount(source, item)
    end)
    if ok and type(count) == 'number' then return count end
    return 0
end

--- @limitation metadata not considered (see getItemCount limitation).
function provider.hasItem(source, item, count, metadata)
    return provider.getItemCount(source, item, nil) >= (count or 1)
end

function provider.canCarryItem(source, item, count, metadata)
    local ok, result = pcall(function()
        return exports['qs-inventory']:CanCarryItem(source, item, count, metadata)
    end)
    if not ok then return false end
    if type(result) == 'boolean' then return result end
    return false
end

--- createUsableItem: QS inventory is used with QBCore or QBOX.
--- Routes by sp.framework.
function provider.createUsableItem(item, cb)
    if sp.framework == Framework.QBOX then
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

    return false
end

--- QS has no own item label registry; delegates to framework layer.
--- QBOX: exports.qbx_core:GetItems(); QBCore: CoreObject.Shared.Items.
--- TODO: check if qs-inventory exposes a GetItemList with labels in newer versions.
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

    if (sp.framework == Framework.QBCore)
        and type(CoreObject) == 'table'
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

--- TODO: verify qs-inventory:GetItemList() stability across QS versions.
function provider.getItemDefinitions()
    local ok, items = pcall(function()
        return exports['qs-inventory']:GetItemList()
    end)
    if ok and type(items) == 'table' then return items end
    return {}
end

sp.inventoryProvider = provider
sp.print.info('[provider] qs-inventory server provider registered')
