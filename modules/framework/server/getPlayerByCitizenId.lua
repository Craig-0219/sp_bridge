function sp.getPlayerByCitizenId(citizenId)
    if type(citizenId) ~= 'string' or citizenId == '' then
        return nil
    end

    local players = GetPlayers()
    for i = 1, #players do
        local source = tonumber(players[i])
        if source then
            local cid = sp.getCitizenId(source)
            if cid == citizenId then
                return sp.getPlayer(source)
            end
        end
    end

    return nil
end

exports('GetPlayerByCitizenId', function(citizenId)
    return sp.getPlayerByCitizenId(citizenId)
end)
