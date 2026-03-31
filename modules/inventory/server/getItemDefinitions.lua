-- modules/inventory/server/getItemDefinitions.lua
-- Routes through sp.inventoryProvider.getItemDefinitions.
-- Applies normalizeItems() so callers always receive a consistent schema
-- regardless of the underlying inventory system.
--
-- QBOX fix: QB provider uses exports.qbx_core:GetItems() for QBOX, so the old
-- `type(CoreObject) == 'table'` guard that silently failed for QBOX is gone.
--
-- Returns: table<string, NormalizedItemDef> (never nil)
-- NormalizedItemDef: { name, label, weight, description, image, stack, unique }

local function normalizeName(value)
    if type(value) == 'string' then return value end
    if value == nil then return nil end
    return tostring(value)
end

--- Normalize raw item definitions into a consistent schema keyed by item name.
--- Handles both hash-keyed tables ({ bread = { label='Bread', ... } })
--- and array-style tables ({ { name='bread', label='Bread', ... } }).
local function normalizeItems(raw)
    local out = {}
    if type(raw) ~= 'table' then return out end

    for k, v in pairs(raw) do
        local name, def

        if type(k) == 'string' then
            name = k
            def  = type(v) == 'table' and v or { label = normalizeName(v) }
        elseif type(v) == 'table' then
            name = normalizeName(v.name or v.item or v.id)
            def  = v
        end

        if type(name) == 'string' and name ~= '' then
            local label = (type(def.label) == 'string' and def.label ~= '' and def.label)
                       or (type(def.name)  == 'string' and def.name  ~= '' and def.name)
                       or name
            out[name] = {
                name        = name,
                label       = label,
                weight      = tonumber(def.weight) or 0,
                description = def.description or nil,
                image       = def.image or nil,
                stack       = def.stack or nil,
                unique      = def.unique or nil,
            }
        end
    end

    return out
end

function sp.getItemDefinitions()
    if sp.inventoryProvider and type(sp.inventoryProvider.getItemDefinitions) == 'function' then
        local ok, raw = pcall(sp.inventoryProvider.getItemDefinitions)
        if ok and type(raw) == 'table' and next(raw) ~= nil then
            return normalizeItems(raw)
        end
    end

    -- QBOX native fallback: used when no third-party inventory provider is detected
    -- OR when the provider returns an empty table (e.g. ox_inventory with no items.lua).
    -- qbx_core:GetItems() returns the full item registry registered in qbx_core.
    if sp.framework == Framework.QBOX then
        local ok, items = pcall(function() return exports.qbx_core:GetItems() end)
        if ok and type(items) == 'table' then
            return normalizeItems(items)
        end
    end

    return {}
end

--- Returns a single item definition by name, or the full table when name is omitted.
function sp.items(itemName)
    local defs = sp.getItemDefinitions()
    if type(itemName) == 'string' and itemName ~= '' then
        return defs[itemName]
    end
    return defs
end

exports('GetItemDefinitions', function() return sp.getItemDefinitions() end)
exports('GetItems',           function() return sp.getItemDefinitions() end)
exports('GetAllItems',        function() return sp.getItemDefinitions() end)
exports('GetItemList',        function() return sp.getItemDefinitions() end)
exports('Items', function(itemName) return sp.items(itemName) end)
