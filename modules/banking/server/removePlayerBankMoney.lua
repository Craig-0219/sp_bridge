-- modules/banking/server/removePlayerBankMoney.lua
-- Mutation: remove amount from player's bank balance.
-- Returns boolean; false on any error or missing provider.
function sp.removePlayerBankMoney(source, amount, reason)
    if type(amount) ~= 'number' or amount <= 0 then return false end
    local pname = sp.getBankProviderName()

    if not sp.bankProvider then
        sp.print.warn('[banking] RemovePlayerBankMoney source=' .. tostring(source) .. ' amount=' .. amount .. ' reason=no_provider')
        return false
    end

    if type(sp.bankProvider.removePlayerBankMoney) ~= 'function' then
        sp.print.warn('[banking] RemovePlayerBankMoney provider=' .. pname .. ' source=' .. tostring(source) .. ' amount=' .. amount .. ' reason=method_missing')
        return false
    end

    local ok, result = pcall(sp.bankProvider.removePlayerBankMoney, source, amount, reason)
    if not ok then
        sp.print.error('[banking] RemovePlayerBankMoney provider=' .. pname .. ' source=' .. tostring(source) .. ' amount=' .. amount .. ' reason=pcall_error error=' .. tostring(result))
        return false
    end

    if result ~= true then
        sp.print.warn('[banking] RemovePlayerBankMoney provider=' .. pname .. ' source=' .. tostring(source) .. ' amount=' .. amount .. ' reason=provider_returned_false')
        return false
    end

    return true
end

exports('RemovePlayerBankMoney', function(source, amount, reason)
    return sp.removePlayerBankMoney(source, amount, reason)
end)
