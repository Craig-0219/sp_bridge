function sp.getMoney(source, moneyType)
    local Player = sp.getPlayer(source)
    if not Player then return 0 end

    if sp.framework == Framework.ESX then
        local account = (moneyType == 'cash') and 'money' or moneyType
        if account == 'money' then
            return Player.getMoney()
        else
            local acc = Player.getAccount(account)
            return acc and acc.money or 0
        end
    end

    if sp.framework == Framework.QBCore or sp.framework == Framework.QBOX then
        local account = (moneyType == 'money') and 'cash' or moneyType
        return Player.Functions.GetMoney(account) or 0
    end

    return 0
end

exports('GetMoney', function(source, moneyType)
    return sp.getMoney(source, moneyType)
end)
