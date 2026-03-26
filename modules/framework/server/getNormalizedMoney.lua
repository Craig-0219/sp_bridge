-- modules/framework/server/getNormalizedMoney.lua
function sp.getNormalizedMoney(source)
    if sp.frameworkProvider and type(sp.frameworkProvider.normalizeMoney) == 'function' then
        return sp.frameworkProvider.normalizeMoney(source)
    end
    return sp.defaultNormalizedMoney()
end

exports('GetNormalizedMoney', function(source)
    return sp.getNormalizedMoney(source)
end)
