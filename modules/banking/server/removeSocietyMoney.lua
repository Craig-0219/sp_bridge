-- modules/banking/server/removeSocietyMoney.lua
-- Mutation: remove amount from a society / shared account.
-- Returns boolean; false when provider does not support society accounts.
function sp.removeSocietyMoney(accountId, amount, reason)
    if type(accountId) ~= 'string' or accountId == '' then return false end
    if type(amount) ~= 'number' or amount <= 0 then return false end
    if sp.bankProvider and type(sp.bankProvider.removeSocietyMoney) == 'function' then
        local ok, result = pcall(sp.bankProvider.removeSocietyMoney, accountId, amount, reason)
        if not ok then return false end
        return result == true
    end
    return false
end

exports('RemoveSocietyMoney', function(accountId, amount, reason)
    return sp.removeSocietyMoney(accountId, amount, reason)
end)
