-- modules/banking/providers/qb/server.lua
-- qb-banking / qb-management provider.
-- Player bank  : delegates to sp.getMoney / sp.addMoney / sp.removeMoney
--                (QBCore native bank money — same as framework provider).
-- Society      : qb-banking or qb-management exports.
--
-- Assumed exports:
--   GetAccount(accountName)                       -> table{money|balance}
--   AddMoney(accountName, amount, reason)         -> nil|boolean
--   RemoveMoney(accountName, amount, reason)      -> nil|boolean
if sp.banking ~= Bankings.QB_BANKING and sp.banking ~= Bankings.QB_MANAGEMENT then return end

local bankResource = (sp.banking == Bankings.QB_MANAGEMENT) and 'qb-management' or 'qb-banking'

local provider = {}
provider.name         = bankResource
provider.capabilities = { playerBank = true, society = true }

-- ---------------------------------------------------------------------------
-- Player bank  (QB stores player bank in framework money, not the society DB)
-- ---------------------------------------------------------------------------

function provider.getPlayerBankBalance(source)
    if type(sp.getMoney) ~= 'function' then return 0 end
    local ok, val = pcall(sp.getMoney, source, 'bank')
    return (ok and type(val) == 'number') and val or 0
end

function provider.addPlayerBankMoney(source, amount, reason)
    if type(sp.addMoney) ~= 'function' then return false end
    local ok, result = pcall(sp.addMoney, source, 'bank', amount)
    return ok and result == true
end

function provider.removePlayerBankMoney(source, amount, reason)
    if type(sp.removeMoney) ~= 'function' then return false end
    local ok, result = pcall(sp.removeMoney, source, 'bank', amount)
    return ok and result == true
end

-- ---------------------------------------------------------------------------
-- Society
-- ---------------------------------------------------------------------------

function provider.getSocietyBalance(accountId)
    local ok, account = pcall(function()
        return exports[bankResource]:GetAccount(accountId)
    end)
    if not ok or type(account) ~= 'table' then return 0 end
    if type(account.money)   == 'number' then return account.money   end
    if type(account.balance) == 'number' then return account.balance end
    return 0
end

function provider.addSocietyMoney(accountId, amount, reason)
    local ok, result = pcall(function()
        return exports[bankResource]:AddMoney(accountId, amount, reason or '')
    end)
    if not ok then return false end
    return result ~= false
end

function provider.removeSocietyMoney(accountId, amount, reason)
    local ok, result = pcall(function()
        return exports[bankResource]:RemoveMoney(accountId, amount, reason or '')
    end)
    if not ok then return false end
    return result ~= false
end

sp.bankProvider = provider
sp.print.info(('[banking] provider=%s playerBank=%s society=%s'):format(
    provider.name,
    tostring(provider.capabilities.playerBank),
    tostring(provider.capabilities.society)
))
