-- modules/framework/server/getPlayerData.lua
-- Returns the raw framework player object or PlayerData table.
-- Schema is INCONSISTENT across frameworks:
--   ESX:    Player object  (use :getAccount(), .getName(), .job, ...)
--   QBCore: PlayerData table (pd.citizenid, pd.job, pd.money, ...)
--   QBOX:   PlayerData table (same shape as QBCore)
--
-- DEPRECATED: use GetNormalizedPlayerData for a stable cross-framework schema.
-- GetRawPlayerData is an explicit alias for this function (same behavior).
function sp.getPlayerData(source)
    local Player = sp.getPlayer(source)
    if not Player then return nil end

    if sp.framework == Framework.ESX then
        return Player
    end

    if sp.framework == Framework.QBCore or sp.framework == Framework.QBOX then
        return Player.PlayerData or Player
    end

    return Player
end

exports('GetPlayerData', function(source)
    return sp.getPlayerData(source)
end)

exports('GetRawPlayerData', function(source)
    return sp.getPlayerData(source)
end)
