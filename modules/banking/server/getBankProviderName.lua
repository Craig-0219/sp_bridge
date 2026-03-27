-- modules/banking/server/getBankProviderName.lua
-- Returns the display name of the active bank provider (e.g. 'framework',
-- 'renewed', 'qb-banking', 'okokBanking'), or 'none' if not registered.
exports('GetBankProviderName', function()
    return sp.getBankProviderName()
end)
