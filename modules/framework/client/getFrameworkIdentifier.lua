-- modules/framework/client/getFrameworkIdentifier.lua
-- Returns the local player's stable platform identifier (e.g. "license:xxxx").
-- This is the hardware/platform ID used as a cross-session DB key.
-- Do NOT confuse with GetCitizenId / GetCharacterId which return the in-game
-- character ID (citizenid for QB/QBOX, which is the same as identifier for ESX).
--
-- ESX:    pd.identifier (license:xxx)
-- QBCore: pd.license (license:xxx)
-- QBOX:   pd.license (license:xxx)
function sp.getFrameworkIdentifier()
    if sp.clientProvider and type(sp.clientProvider.normalizePlayerData) == 'function' then
        local pd = sp.clientProvider.normalizePlayerData()
        return pd and pd.identifier or nil
    end
    return nil
end

exports('GetFrameworkIdentifier', function()
    return sp.getFrameworkIdentifier()
end)
