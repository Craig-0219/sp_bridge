-- modules/inventory/shared.lua
-- Inventory provider router init.
-- sp.inventoryProvider is set server-side by the matching provider file.
-- On client side this file still runs but inventoryProvider stays nil;
-- inventory mutations are server-only.

sp.inventoryProvider = nil

--- Returns the active inventory provider, or nil if not registered.
---@return table|nil
function sp.getInventoryProvider()
    return sp.inventoryProvider
end

--- Resolve item definitions for QBOX stacks.
--- Newer qbx_core versions no longer export GetItems(); their qb-core
--- compatibility bridge exposes the normalized registry on Shared.Items.
---@return table
function sp.getQboxItemDefinitions()
    if sp.framework ~= Framework.QBOX then
        return {}
    end

    local ok, items = pcall(function()
        return exports.qbx_core:GetItems()
    end)
    if ok and type(items) == 'table' and next(items) ~= nil then
        return items
    end

    local okCompat, qb = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    if okCompat
        and type(qb) == 'table'
        and type(qb.Shared) == 'table'
        and type(qb.Shared.Items) == 'table'
    then
        return qb.Shared.Items
    end

    return {}
end

--- Register a usable item on QBOX, trying both the native export and the
--- qb-core compatibility object exposed by qbx_core.
---@param item string
---@param cb function
---@return boolean
function sp.createQboxUsableItem(item, cb)
    if sp.framework ~= Framework.QBOX then
        return false
    end

    local ok = pcall(function()
        exports.qbx_core:CreateUseableItem(item, cb)
    end)
    if ok then
        return true
    end

    local okCompat, qb = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    if okCompat
        and type(qb) == 'table'
        and type(qb.Functions) == 'table'
        and type(qb.Functions.CreateUseableItem) == 'function'
    then
        local okCreate = pcall(function()
            qb.Functions.CreateUseableItem(item, cb)
        end)
        if okCreate then
            return true
        end
    end

    return false
end
