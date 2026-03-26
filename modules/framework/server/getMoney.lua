-- modules/framework/server/getMoney.lua
function sp.getMoney(source, moneyType)
    if sp.frameworkProvider and type(sp.frameworkProvider.getMoney) == 'function' then
        return sp.frameworkProvider.getMoney(source, moneyType)
    end
    return 0
end

exports('GetMoney', function(source, moneyType)
    return sp.getMoney(source, moneyType)
end)
