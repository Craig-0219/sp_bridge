function sp.getPlayer(source)
    if not source then return nil end

    if sp.framework == Framework.ESX then
        return CoreObject.GetPlayerFromId(source)
    end

    if sp.framework == Framework.QBCore then
        return CoreObject.Functions.GetPlayer(source)
    end

    if sp.framework == Framework.QBOX then
        return exports.qbx_core:GetPlayer(source)
    end
end

exports('GetPlayer', function(source)
    return sp.getPlayer(source)
end)
