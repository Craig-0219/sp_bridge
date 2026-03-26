-- modules/inventory/server/hasItem.lua
-- Routes through sp.inventoryProvider.hasItem.
-- Always returns boolean.
--
-- Backward-compat note:
--   Old signature: HasItem(source, item, metadata)       -- 3 args, no count
--   New signature: HasItem(source, item, count, metadata) -- 4 args
--   Detection: if 3rd arg is a number -> new call; else -> old call (count=1)
function sp.hasItem(source, item, count, metadata)
    if sp.inventoryProvider and type(sp.inventoryProvider.hasItem) == 'function' then
        local ok, result = pcall(sp.inventoryProvider.hasItem, source, item, count, metadata)
        if ok then return result == true end
    end
    return false
end

exports('HasItem', function(source, item, countOrMeta, metadata)
    -- backward-compat: detect if 3rd arg is count (number) or legacy metadata
    if type(countOrMeta) == 'number' then
        return sp.hasItem(source, item, countOrMeta, metadata)
    else
        return sp.hasItem(source, item, 1, countOrMeta)
    end
end)
