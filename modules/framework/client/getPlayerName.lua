function sp.getPlayerName()
    local name = GetPlayerName(PlayerId())
    if type(name) == 'string' and name ~= '' then
        return name
    end

    local data = sp.getPlayerData()
    if type(data) ~= 'table' then
        return nil
    end

    if sp.framework == Framework.QBCore or sp.framework == Framework.QBOX then
        local charinfo = data.charinfo or (data.PlayerData and data.PlayerData.charinfo)
        if type(charinfo) == 'table' then
            local first = type(charinfo.firstname) == 'string' and charinfo.firstname or ''
            local last = type(charinfo.lastname) == 'string' and charinfo.lastname or ''
            local full = (first .. ' ' .. last):gsub('^%s*(.-)%s*$', '%1')
            if full ~= '' then
                return full
            end
        end
    end

    return nil
end

exports('GetPlayerName', function()
    return sp.getPlayerName()
end)
