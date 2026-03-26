local function getAccountFromESX(accounts, name)
    if type(accounts) ~= 'table' then
        return nil
    end
    for i = 1, #accounts do
        local acc = accounts[i]
        if type(acc) == 'table' and acc.name == name then
            return acc
        end
    end
    return nil
end

function sp.getMoney(moneyType)
    local data = sp.getPlayerData()
    if type(data) ~= 'table' then
        return 0
    end

    if sp.framework == Framework.ESX then
        local account = (moneyType == 'cash') and 'money' or moneyType
        if account == 'money' and type(data.money) == 'number' then
            return data.money
        end
        local acc = getAccountFromESX(data.accounts, account)
        return tonumber(acc and acc.money or 0) or 0
    end

    if sp.framework == Framework.QBCore or sp.framework == Framework.QBOX then
        local account = (moneyType == 'money') and 'cash' or moneyType
        local money = data.money or (data.PlayerData and data.PlayerData.money)
        if type(money) == 'table' then
            return tonumber(money[account] or 0) or 0
        end
        return 0
    end

    return 0
end

exports('GetMoney', function(moneyType)
    return sp.getMoney(moneyType)
end)
