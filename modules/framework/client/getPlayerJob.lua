function sp.getPlayerJob()
    local data = sp.getPlayerData()
    if type(data) ~= 'table' then
        return nil
    end

    if sp.framework == Framework.ESX then
        return data.job
    end

    if sp.framework == Framework.QBCore or sp.framework == Framework.QBOX then
        return data.job or (data.PlayerData and data.PlayerData.job)
    end

    return nil
end

exports('GetPlayerJob', function()
    return sp.getPlayerJob()
end)
