-- modules/banking/server/getPlayerBankBalance.lua
-- Query: player's bank balance.
-- Returns number (>= 0); 0 on any error or missing provider.
function sp.getPlayerBankBalance(source)
    local pname = sp.getBankProviderName()

    if not sp.bankProvider then
        sp.print.warn('[banking] GetPlayerBankBalance source=' .. tostring(source) .. ' reason=no_provider')
        return 0
    end

    if type(sp.bankProvider.getPlayerBankBalance) ~= 'function' then
        sp.print.warn('[banking] GetPlayerBankBalance provider=' .. pname .. ' source=' .. tostring(source) .. ' reason=method_missing')
        return 0
    end

    local ok, val = pcall(sp.bankProvider.getPlayerBankBalance, source)
    if not ok then
        sp.print.error('[banking] GetPlayerBankBalance provider=' .. pname .. ' source=' .. tostring(source) .. ' reason=pcall_error error=' .. tostring(val))
        return 0
    end

    if type(val) ~= 'number' then
        sp.print.warn('[banking] GetPlayerBankBalance provider=' .. pname .. ' source=' .. tostring(source) .. ' reason=unexpected_return got=' .. type(val))
        return 0
    end

    return val
end

exports('GetPlayerBankBalance', function(source)
    return sp.getPlayerBankBalance(source)
end)
