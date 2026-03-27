-- modules/banking/server/getPlayerBankBalance.lua
-- Query: player's bank balance.
-- Returns number (>= 0); 0 on any error or missing provider.
function sp.getPlayerBankBalance(source)
    if sp.bankProvider and type(sp.bankProvider.getPlayerBankBalance) == 'function' then
        local ok, val = pcall(sp.bankProvider.getPlayerBankBalance, source)
        if ok and type(val) == 'number' then return val end
    end
    return 0
end

exports('GetPlayerBankBalance', function(source)
    return sp.getPlayerBankBalance(source)
end)
