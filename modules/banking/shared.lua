-- modules/banking/shared.lua
-- Bank provider router init.
-- sp.bankProvider is set server-side by the matching provider file.
-- On the client side this file still runs; bankProvider stays nil
-- because all bank mutations are server-only.

if type(sp) ~= 'table' then
    sp = {}
end

sp.bankProvider = nil

---@return table|nil
function sp.getBankProvider()
    return sp.bankProvider
end

--- Returns the display name of the active bank provider, or 'none'.
function sp.getBankProviderName()
    if sp.bankProvider and type(sp.bankProvider.name) == 'string' then
        return sp.bankProvider.name
    end
    return 'none'
end
