-- modules/inventory/server/canCarryItem.lua
-- Routes through sp.inventoryProvider.canCarryItem.
-- Always returns boolean.
--
-- No-provider fallback policy: returns TRUE (permissive).
-- Rationale: during resource startup the inventory provider may not yet be
-- registered, or a custom setup may not use any recognised inventory.
-- Returning false would silently block all AddItem calls in those scenarios,
-- causing hard-to-diagnose item loss. Returning true is a safe development
-- default; production servers always have an inventory running.
--
-- Provider pcall failure policy: returns FALSE (conservative).
-- Rationale: if the provider IS registered but the underlying export errors
-- (e.g. inventory resource crashed), blocking the carry is safer than allowing
-- potential item duplication.
--
-- Note: QB and QS providers do not support metadata in canCarryItem;
--       metadata is accepted by this function for API symmetry but may be
--       ignored internally — see provider files for per-provider limitations.
function sp.canCarryItem(source, item, count, metadata)
    if sp.inventoryProvider and type(sp.inventoryProvider.canCarryItem) == 'function' then
        local ok, result = pcall(sp.inventoryProvider.canCarryItem, source, item, count, metadata)
        if ok then return result == true end
        return false -- provider errored: conservative block
    end
    return true -- no provider registered: permissive development fallback
end

exports('CanCarryItem', function(source, item, count, metadata)
    return sp.canCarryItem(source, item, count, metadata)
end)
