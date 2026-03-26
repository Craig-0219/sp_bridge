function sp.addBankMoney(source, amount, reason)
    return sp.addMoney(source, 'bank', amount, reason)
end

exports('AddBankMoney', function(source, amount, reason)
    return sp.addBankMoney(source, amount, reason)
end)
