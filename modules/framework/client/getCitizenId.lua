function sp.getCitizenId()
    local data = sp.getPlayerData()
    if type(data) ~= 'table' then
        return nil
    end

    if sp.framework == Framework.ESX then
        local identifier = data.identifier
        if type(identifier) == 'string' and identifier ~= '' then
            return identifier
        end
        return nil
    end

    if sp.framework == Framework.QBCore or sp.framework == Framework.QBOX then
        local cid = data.citizenid or (data.PlayerData and data.PlayerData.citizenid) or (data.charinfo and data.charinfo.citizenid)
        if type(cid) == 'string' and cid ~= '' then
            return cid
        end
        return nil
    end

    return nil
end

exports('GetCitizenId', function()
    return sp.getCitizenId()
end)
