function sp.getPlayerName(source)
    local Player = sp.getPlayer(source)

    if sp.framework == Framework.ESX and Player and type(Player.getName) == 'function' then
        return Player.getName()
    end

    if (sp.framework == Framework.QBCore or sp.framework == Framework.QBOX) and Player and Player.PlayerData then
        local charinfo = Player.PlayerData.charinfo
        if type(charinfo) == 'table' then
            local first = type(charinfo.firstname) == 'string' and charinfo.firstname or ''
            local last = type(charinfo.lastname) == 'string' and charinfo.lastname or ''
            local full = (first .. ' ' .. last):gsub('^%s*(.-)%s*$', '%1')
            if full ~= '' then
                return full
            end
        end
    end

    local name = GetPlayerName(source)
    if type(name) == 'string' and name ~= '' then
        return name
    end

    return nil
end

exports('GetPlayerName', function(source)
    return sp.getPlayerName(source)
end)
