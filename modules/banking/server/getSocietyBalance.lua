-- modules/banking/server/getSocietyBalance.lua
-- Query: society / shared account balance by accountId string.
-- Returns number (>= 0); 0 on any error, missing provider, or unsupported provider.
function sp.getSocietyBalance(accountId)
    if type(accountId) ~= 'string' or accountId == '' then return 0 end
    if sp.bankProvider and type(sp.bankProvider.getSocietyBalance) == 'function' then
        local ok, val = pcall(sp.bankProvider.getSocietyBalance, accountId)
        if ok and type(val) == 'number' then return val end
    end
    return 0
end

exports('GetSocietyBalance', function(accountId)
    return sp.getSocietyBalance(accountId)
end)
