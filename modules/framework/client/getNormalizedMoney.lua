-- modules/framework/client/getNormalizedMoney.lua
function sp.getNormalizedMoney()
    if sp.clientProvider and type(sp.clientProvider.normalizeMoney) == 'function' then
        return sp.clientProvider.normalizeMoney()
    end
    return sp.defaultNormalizedMoney()
end

exports('GetNormalizedMoney', function()
    return sp.getNormalizedMoney()
end)
