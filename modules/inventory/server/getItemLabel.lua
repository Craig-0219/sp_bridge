-- modules/inventory/server/getItemLabel.lua
-- Routes through sp.inventoryProvider.getItemLabel.
-- Returns string|nil.
-- Fallback: if provider returns nil, returns item name itself (not nil)
-- so callers always get a usable display string.
-- Fixed: QBOX previously broken due to type(CoreObject)=='table' guard in old code.
function sp.getItemLabel(item)
    if type(item) ~= 'string' or item == '' then return nil end

    if sp.inventoryProvider and type(sp.inventoryProvider.getItemLabel) == 'function' then
        local ok, label = pcall(sp.inventoryProvider.getItemLabel, item)
        if ok and type(label) == 'string' and label ~= '' then return label end
    end

    return item -- fallback: item name is better than nil for display purposes
end

exports('GetItemLabel', function(item)
    return sp.getItemLabel(item)
end)
