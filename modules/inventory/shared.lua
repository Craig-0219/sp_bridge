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
