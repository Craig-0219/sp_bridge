function sp.getCitizenId(source)
    local Player = sp.getPlayer(source)
    if not Player then
        return nil
    end

    if sp.framework == Framework.ESX then
        local identifier = Player.identifier
        if type(identifier) == 'string' and identifier ~= '' then
            return identifier
        end
        if type(Player.getIdentifier) == 'function' then
            local id = Player.getIdentifier()
            if type(id) == 'string' and id ~= '' then
                return id
            end
        end
    end

    if sp.framework == Framework.QBCore or sp.framework == Framework.QBOX then
        local cid = Player.PlayerData and Player.PlayerData.citizenid
        if type(cid) == 'string' and cid ~= '' then
            return cid
        end
    end

    return nil
end

exports('GetCitizenId', function(source)
    return sp.getCitizenId(source)
end)
