-- modules/framework/server/getFrameworkIdentifier.lua
-- Returns the player's stable platform identifier (e.g. "license:xxxx" or "steam:xxxx").
-- This is the hardware/platform ID used as a cross-session DB key.
-- Do NOT confuse with GetCitizenId / GetCharacterId which return the in-game
-- character ID (citizenid for QB/QBOX, which is the same as identifier for ESX).
--
-- ESX:    Player.identifier (license:xxx)
-- QBCore: pd.license (license:xxx)
-- QBOX:   pd.license (license:xxx)
function sp.getFrameworkIdentifier(source)
    if sp.frameworkProvider and type(sp.frameworkProvider.normalizePlayerData) == 'function' then
        local pd = sp.frameworkProvider.normalizePlayerData(source)
        return pd and pd.identifier or nil
    end
    return nil
end

exports('GetFrameworkIdentifier', function(source)
    return sp.getFrameworkIdentifier(source)
end)
