-- modules/banking/shared.lua
-- Bank provider router init.
-- sp.bankProvider is set server-side by the matching provider file.
-- On the client side this file still runs; bankProvider stays nil
-- because all bank mutations are server-only.

sp.bankProvider = nil

---@return table|nil
function sp.getBankProvider()
    return sp.bankProvider
end
