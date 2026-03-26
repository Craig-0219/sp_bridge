function sp.getPlayerData(source)
    local Player = sp.getPlayer(source)
    if not Player then
        return nil
    end

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
