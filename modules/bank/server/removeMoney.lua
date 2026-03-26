function sp.removeBankMoney(source, amount, reason)
    return sp.removeMoney(source, 'bank', amount, reason)
end

exports('RemoveBankMoney', function(source, amount, reason)
    return sp.removeBankMoney(source, amount, reason)
end)
