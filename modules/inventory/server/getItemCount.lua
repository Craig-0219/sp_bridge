-- modules/inventory/server/getItemCount.lua
-- Routes through sp.inventoryProvider.getItemCount.
-- Always returns number (never nil, never false).
-- Note: QB and QS providers do not support metadata filtering;
--       metadata is accepted for API consistency but may be ignored.
function sp.getItemCount(source, item, metadata)
    if sp.inventoryProvider and type(sp.inventoryProvider.getItemCount) == 'function' then
        local ok, count = pcall(sp.inventoryProvider.getItemCount, source, item, metadata)
        if ok and type(count) == 'number' then return count end
    end
    return 0
end

exports('GetItemCount', function(source, item, metadata)
    return sp.getItemCount(source, item, metadata)
end)
