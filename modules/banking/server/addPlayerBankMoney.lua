-- modules/banking/server/addPlayerBankMoney.lua
-- Mutation: add amount to player's bank balance.
-- Returns boolean; false on any error or missing provider.
function sp.addPlayerBankMoney(source, amount, reason)
    if type(amount) ~= 'number' or amount <= 0 then return false end
    local pname = sp.getBankProviderName()

    if not sp.bankProvider then
        sp.print.warn('[banking] AddPlayerBankMoney source=' .. tostring(source) .. ' amount=' .. amount .. ' reason=no_provider')
        return false
    end

    if type(sp.bankProvider.addPlayerBankMoney) ~= 'function' then
        sp.print.warn('[banking] AddPlayerBankMoney provider=' .. pname .. ' source=' .. tostring(source) .. ' amount=' .. amount .. ' reason=method_missing')
        return false
    end

    local ok, result = pcall(sp.bankProvider.addPlayerBankMoney, source, amount, reason)
    if not ok then
        sp.print.error('[banking] AddPlayerBankMoney provider=' .. pname .. ' source=' .. tostring(source) .. ' amount=' .. amount .. ' reason=pcall_error error=' .. tostring(result))
        return false
    end

    if result ~= true then
        sp.print.warn('[banking] AddPlayerBankMoney provider=' .. pname .. ' source=' .. tostring(source) .. ' amount=' .. amount .. ' reason=provider_returned_false')
        return false
    end

    return true
end

exports('AddPlayerBankMoney', function(source, amount, reason)
    return sp.addPlayerBankMoney(source, amount, reason)
end)
