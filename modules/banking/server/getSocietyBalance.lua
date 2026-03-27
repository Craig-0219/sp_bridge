-- modules/banking/server/getSocietyBalance.lua
-- Query: society / shared account balance by accountId string.
-- Returns number (>= 0); 0 on any error, missing provider, or unsupported provider.
function sp.getSocietyBalance(accountId)
    if type(accountId) ~= 'string' or accountId == '' then return 0 end
    local pname = sp.getBankProviderName()

    if not sp.bankProvider then
        sp.print.warn('[banking] GetSocietyBalance accountId=' .. accountId .. ' reason=no_provider')
        return 0
    end

    -- Capability check: log explicitly when provider does not support society.
    if sp.bankProvider.capabilities and sp.bankProvider.capabilities.society == false then
        sp.print.warn('[banking] GetSocietyBalance provider=' .. pname .. ' accountId=' .. accountId .. ' reason=society_unsupported')
        return 0
    end

    if type(sp.bankProvider.getSocietyBalance) ~= 'function' then
        sp.print.warn('[banking] GetSocietyBalance provider=' .. pname .. ' accountId=' .. accountId .. ' reason=method_missing')
        return 0
    end

    local ok, val = pcall(sp.bankProvider.getSocietyBalance, accountId)
    if not ok then
        sp.print.error('[banking] GetSocietyBalance provider=' .. pname .. ' accountId=' .. accountId .. ' reason=pcall_error error=' .. tostring(val))
        return 0
    end

    if type(val) ~= 'number' then
        sp.print.warn('[banking] GetSocietyBalance provider=' .. pname .. ' accountId=' .. accountId .. ' reason=unexpected_return got=' .. type(val))
        return 0
    end

    return val
end

exports('GetSocietyBalance', function(accountId)
    return sp.getSocietyBalance(accountId)
end)
