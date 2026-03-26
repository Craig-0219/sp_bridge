function sp.getBalance(source)
    return sp.getMoney(source, 'bank')
end

exports('GetBankBalance', function(source)
    return sp.getBalance(source)
end)
