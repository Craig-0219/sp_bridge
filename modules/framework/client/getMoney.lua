-- modules/framework/client/getMoney.lua
function sp.getMoney(moneyType)
    if sp.clientProvider and type(sp.clientProvider.getMoney) == 'function' then
        return sp.clientProvider.getMoney(moneyType)
    end
    return 0
end

exports('GetMoney', function(moneyType)
    return sp.getMoney(moneyType)
end)
