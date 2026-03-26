function sp.getPlayerJob(source)
    local Player = sp.getPlayer(source)
    if not Player then
        return nil
    end

    if sp.framework == Framework.ESX then
        local job = Player.job
        if type(job) == 'table' then
            return job
        end
        return nil
    end

    if sp.framework == Framework.QBCore or sp.framework == Framework.QBOX then
        local job = Player.PlayerData and Player.PlayerData.job
        if type(job) == 'table' then
            return job
        end
        return nil
    end

    return nil
end

exports('GetPlayerJob', function(source)
    return sp.getPlayerJob(source)
end)
