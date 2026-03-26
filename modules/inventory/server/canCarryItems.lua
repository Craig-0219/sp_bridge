-- modules/inventory/server/canCarryItems.lua
-- Bulk carry check: returns false as soon as any single item fails canCarryItem.
-- Each entry: { name = string, count = number|nil, metadata = table|nil }
-- count defaults to 1 when omitted; passing 0 is valid (always passes).
-- Routes through sp.canCarryItem which delegates to sp.inventoryProvider.
function sp.canCarryItems(source, items)
    if type(items) ~= 'table' then return false end

    for i = 1, #items do
        local entry = items[i]
        if type(entry) ~= 'table' then return false end

        local name  = entry.name
        local count = entry.count or 1   -- default: check for at least 1
        local meta  = entry.metadata

        if type(name) ~= 'string' or name == '' then return false end
        if not sp.canCarryItem(source, name, count, meta) then return false end
    end

    return true
end

exports('CanCarryItems', function(source, items)
    return sp.canCarryItems(source, items)
end)
