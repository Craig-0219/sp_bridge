-- modules/banking/server/addPlayerBankMoney.lua
-- Mutation: add amount to player's bank balance.
-- Returns boolean; false on any error or missing provider.
function sp.addPlayerBankMoney(source, amount, reason)
    if type(amount) ~= 'number' or amount <= 0 then return false end
    if sp.bankProvider and type(sp.bankProvider.addPlayerBankMoney) == 'function' then
        local ok, result = pcall(sp.bankProvider.addPlayerBankMoney, source, amount, reason)
        if not ok then return false end
        return result == true
    end
    return false
end

exports('AddPlayerBankMoney', function(source, amount, reason)
    return sp.addPlayerBankMoney(source, amount, reason)
end)
