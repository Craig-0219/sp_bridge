function sp.getPlayerData()
    if sp.framework == Framework.ESX and CoreObject and type(CoreObject.GetPlayerData) == 'function' then
        return CoreObject.GetPlayerData()
    end

    if (sp.framework == Framework.QBCore or sp.framework == Framework.QBOX) and CoreObject and CoreObject.Functions and type(CoreObject.Functions.GetPlayerData) == 'function' then
        return CoreObject.Functions.GetPlayerData()
    end

    return nil
end

exports('GetPlayerData', function()
    return sp.getPlayerData()
end)
