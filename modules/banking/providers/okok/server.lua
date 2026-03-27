-- modules/banking/providers/okok/server.lua
-- okokBanking provider.
-- Player bank  : delegates to sp.getMoney / sp.addMoney / sp.removeMoney
--                (ESX/QB framework bank money; okokBanking manages society
--                 accounts, not individual player bank balances).
-- Society      : okokBanking exports.
--
-- Assumed exports:
--   GetAccount(accountName)                              -> table{money}
--   AddMoney(accountName, amount, reason, source)        -> nil|boolean
--   RemoveMoney(accountName, amount, reason, source)     -> nil|boolean
--   source param = 0 for server-side calls.
if sp.banking ~= Bankings.OKOK then return end

local provider = {}
provider.name         = 'okokBanking'
provider.capabilities = { playerBank = true, society = true }

-- ---------------------------------------------------------------------------
-- Player bank
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
        return exports['okokBanking']:GetAccount(accountId)
    end)
    if not ok or type(account) ~= 'table' then return 0 end
    if type(account.money) == 'number' then return account.money end
    return 0
end

function provider.addSocietyMoney(accountId, amount, reason)
    local ok, result = pcall(function()
        return exports['okokBanking']:AddMoney(accountId, amount, reason or '', 0)
    end)
    if not ok then return false end
    return result ~= false
end

function provider.removeSocietyMoney(accountId, amount, reason)
    local ok, result = pcall(function()
        return exports['okokBanking']:RemoveMoney(accountId, amount, reason or '', 0)
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
