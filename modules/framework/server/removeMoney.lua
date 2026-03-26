function sp.removeMoney(source, moneyType, amount, reason)
    amount = tonumber(amount) or 0
    if amount <= 0 then return true end

    if sp.framework == Framework.ESX then
        local account = (moneyType == 'cash') and 'money' or moneyType
        local Player = sp.getPlayer(source)
        if not Player then return false end
        if account == 'money' then
            Player.removeMoney(amount, reason)
        else
            Player.removeAccountMoney(account, amount, reason)
        end
        return true
    end

    if sp.framework == Framework.QBCore then
        local Player = sp.getPlayer(source)
        if not Player then return false end
        local account = (moneyType == 'money') and 'cash' or moneyType
        local ok = Player.Functions.RemoveMoney(account, amount, reason)
        if ok == nil then return true end
        return ok and true or false
    end

    if sp.framework == Framework.QBOX then
        local Player = sp.getPlayer(source)
        if not Player then return false end
        local account = (moneyType == 'money') and 'cash' or moneyType
        local ok = Player.Functions.RemoveMoney(account, amount, reason)
        if ok == nil then return true end
        return ok and true or false
    end

    return false
end

exports('RemoveMoney', function(source, moneyType, amount, reason)
    return sp.removeMoney(source, moneyType, amount, reason)
end)
