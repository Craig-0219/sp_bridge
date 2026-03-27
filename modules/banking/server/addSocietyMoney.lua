-- modules/banking/server/addSocietyMoney.lua
-- Mutation: add amount to a society / shared account.
-- Returns boolean; false when provider does not support society accounts.
function sp.addSocietyMoney(accountId, amount, reason)
    if type(accountId) ~= 'string' or accountId == '' then return false end
    if type(amount) ~= 'number' or amount <= 0 then return false end
    if sp.bankProvider and type(sp.bankProvider.addSocietyMoney) == 'function' then
        local ok, result = pcall(sp.bankProvider.addSocietyMoney, accountId, amount, reason)
        if not ok then return false end
        return result == true
    end
    return false
end

exports('AddSocietyMoney', function(accountId, amount, reason)
    return sp.addSocietyMoney(accountId, amount, reason)
end)
