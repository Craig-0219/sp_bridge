-- modules/inventory/server/hasItem.lua
-- Routes through sp.inventoryProvider.hasItem.
-- Always returns boolean (never nil).
--
-- Internal signature: sp.hasItem(source, item, count, metadata)
--   count = nil  → provider defaults to 1 ("has at least one")
--   count = 0    → always true ("has at least zero") — edge case, valid
--   count = n>0  → checks total count >= n
--
-- Export backward-compat (HasItem was originally 3-arg, no count param):
--   Old callers: HasItem(source, item)              → count=1, meta=nil
--   Old callers: HasItem(source, item, metadata)    → count=1, meta=metadata
--   New callers: HasItem(source, item, count)        → count=count, meta=nil
--   New callers: HasItem(source, item, count, meta)  → count=count, meta=meta
-- Detection: if 3rd arg is number → new call; otherwise → treat as legacy metadata.
function sp.hasItem(source, item, count, metadata)
    if sp.inventoryProvider and type(sp.inventoryProvider.hasItem) == 'function' then
        local ok, result = pcall(sp.inventoryProvider.hasItem, source, item, count, metadata)
        if ok then return result == true end
    end
    return false
end

exports('HasItem', function(source, item, countOrMeta, metadata)
    if type(countOrMeta) == 'number' then
        return sp.hasItem(source, item, countOrMeta, metadata)
    else
        -- countOrMeta is nil or a metadata table: legacy 3-arg call
        return sp.hasItem(source, item, 1, countOrMeta)
    end
end)
