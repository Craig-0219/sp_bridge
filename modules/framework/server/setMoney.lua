function sp.setMoney(source, moneyType, amount, reason)
    local Player = sp.getPlayer(source)
    if not Player then
        return false
    end

    amount = tonumber(amount) or 0
    if amount < 0 then
        amount = 0
    end

    if sp.framework == Framework.ESX then
        local account = (moneyType == 'cash') and 'money' or moneyType
        if account == 'money' and type(Player.setMoney) == 'function' then
            Player.setMoney(amount)
            return true
        end
        if type(Player.setAccountMoney) == 'function' then
            Player.setAccountMoney(account, amount, reason)
            return true
        end
        return false
    end

    if sp.framework == Framework.QBCore or sp.framework == Framework.QBOX then
        local account = (moneyType == 'money') and 'cash' or moneyType
        if Player.Functions and type(Player.Functions.SetMoney) == 'function' then
            return Player.Functions.SetMoney(account, amount, reason) == true
        end
        return false
    end

    return false
end

exports('SetMoney', function(source, moneyType, amount, reason)
    return sp.setMoney(source, moneyType, amount, reason)
end)
