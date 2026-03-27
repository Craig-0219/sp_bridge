-- modules/banking/providers/renewed/server.lua
-- Renewed-Banking provider.
-- Player bank  : Renewed-Banking player money API.
-- Society      : Renewed-Banking account API.
--
-- Assumed exports (Renewed-Banking v2+):
--   GetBankBalance(source)                        -> number
--   AddMoney(source, amount, reason)              -> nil|boolean
--   RemoveMoney(source, amount, reason)           -> nil|boolean
--   GetAccount(accountName)                       -> number|table{balance}
--   AddAccountMoney(accountName, amount, reason)  -> nil|boolean
--   RemoveAccountMoney(accountName, amount, reason) -> nil|boolean
if sp.banking ~= Bankings.RENEWED then return end

local provider = {}
provider.name         = 'renewed'
provider.capabilities = { playerBank = true, society = true }

-- ---------------------------------------------------------------------------
-- Player bank
-- ---------------------------------------------------------------------------

function provider.getPlayerBankBalance(source)
    local ok, val = pcall(function()
        return exports['Renewed-Banking']:GetBankBalance(source)
    end)
    if ok and type(val) == 'number' then return val end
    return 0
end

function provider.addPlayerBankMoney(source, amount, reason)
    local ok, result = pcall(function()
        return exports['Renewed-Banking']:AddMoney(source, amount, reason or '')
    end)
    if not ok then return false end
    -- Some versions return nil on success; treat nil as true.
    return result ~= false
end

function provider.removePlayerBankMoney(source, amount, reason)
    local ok, result = pcall(function()
        return exports['Renewed-Banking']:RemoveMoney(source, amount, reason or '')
    end)
    if not ok then return false end
    return result ~= false
end

-- ---------------------------------------------------------------------------
-- Society
-- ---------------------------------------------------------------------------

function provider.getSocietyBalance(accountId)
    local ok, val = pcall(function()
        return exports['Renewed-Banking']:GetAccount(accountId)
    end)
    if not ok then return 0 end
    if type(val) == 'number'                                  then return val          end
    if type(val) == 'table' and type(val.balance) == 'number' then return val.balance  end
    return 0
end

function provider.addSocietyMoney(accountId, amount, reason)
    local ok, result = pcall(function()
        return exports['Renewed-Banking']:AddAccountMoney(accountId, amount, reason or '')
    end)
    if not ok then return false end
    return result ~= false
end

function provider.removeSocietyMoney(accountId, amount, reason)
    local ok, result = pcall(function()
        return exports['Renewed-Banking']:RemoveAccountMoney(accountId, amount, reason or '')
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
