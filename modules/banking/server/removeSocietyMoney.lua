-- modules/banking/server/removeSocietyMoney.lua
-- Mutation: remove amount from a society / shared account.
-- Returns boolean; false when provider does not support society accounts.
function sp.removeSocietyMoney(accountId, amount, reason)
    if type(accountId) ~= 'string' or accountId == '' then return false end
    if type(amount) ~= 'number' or amount <= 0 then return false end
    local pname = sp.getBankProviderName()

    if not sp.bankProvider then
        sp.print.warn('[banking] RemoveSocietyMoney accountId=' .. accountId .. ' amount=' .. amount .. ' reason=no_provider')
        return false
    end

    if sp.bankProvider.capabilities and sp.bankProvider.capabilities.society == false then
        sp.print.warn('[banking] RemoveSocietyMoney provider=' .. pname .. ' accountId=' .. accountId .. ' amount=' .. amount .. ' reason=society_unsupported')
        return false
    end

    if type(sp.bankProvider.removeSocietyMoney) ~= 'function' then
        sp.print.warn('[banking] RemoveSocietyMoney provider=' .. pname .. ' accountId=' .. accountId .. ' amount=' .. amount .. ' reason=method_missing')
        return false
    end

    local ok, result = pcall(sp.bankProvider.removeSocietyMoney, accountId, amount, reason)
    if not ok then
        sp.print.error('[banking] RemoveSocietyMoney provider=' .. pname .. ' accountId=' .. accountId .. ' amount=' .. amount .. ' reason=pcall_error error=' .. tostring(result))
        return false
    end

    if result ~= true then
        sp.print.warn('[banking] RemoveSocietyMoney provider=' .. pname .. ' accountId=' .. accountId .. ' amount=' .. amount .. ' reason=provider_returned_false')
        return false
    end

    return true
end

exports('RemoveSocietyMoney', function(accountId, amount, reason)
    return sp.removeSocietyMoney(accountId, amount, reason)
end)
