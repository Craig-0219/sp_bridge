function sp.getPlayer()
    if sp.framework == Framework.ESX then
        return CoreObject.GetPlayerData()
    end

    if sp.framework == Framework.QBCore then
        return CoreObject.Functions.GetPlayerData()
    end

    if sp.framework == Framework.QBOX then
        return exports.qbx_core:GetPlayerData()
    end
end

exports('GetPlayer', function()
    return sp.getPlayer()
end)
