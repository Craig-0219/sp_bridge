-- modules/banking/server/removePlayerBankMoney.lua
-- Mutation: remove amount from player's bank balance.
-- Returns boolean; false on any error or missing provider.
function sp.removePlayerBankMoney(source, amount, reason)
    if type(amount) ~= 'number' or amount <= 0 then return false end
    if sp.bankProvider and type(sp.bankProvider.removePlayerBankMoney) == 'function' then
        local ok, result = pcall(sp.bankProvider.removePlayerBankMoney, source, amount, reason)
        if not ok then return false end
        return result == true
    end
    return false
end

exports('RemovePlayerBankMoney', function(source, amount, reason)
    return sp.removePlayerBankMoney(source, amount, reason)
end)
