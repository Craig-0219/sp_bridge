local function toNumber(v)
    local n = tonumber(v)
    if n then
        return n
    end
    return 0
end

local function awaitAddonAccount(accountName)
    local p = promise.new()
    local done = false

    SetTimeout(1000, function()
        if done then
            return
        end
        done = true
        p:resolve(nil)
    end)

    TriggerEvent('esx_addonaccount:getSharedAccount', accountName, function(account)
        if done then
            return
        end
        done = true
        p:resolve(account)
    end)
    return Citizen.Await(p)
end

local function renewedGet(account)
    local ok, result = pcall(function()
        return exports['Renewed-Banking']:getAccountMoney(account)
    end)
    if ok then
        return toNumber(result)
    end
    return nil
end

local function renewedAdd(account, amount)
    local ok, result = pcall(function()
        return exports['Renewed-Banking']:addAccountMoney(account, amount)
    end)
    return ok and result == true
end

local function renewedRemove(account, amount)
    local ok, result = pcall(function()
        return exports['Renewed-Banking']:removeAccountMoney(account, amount)
    end)
    return ok and result == true
end

local function qbBankingGet(account)
    local ok, result = pcall(function()
        return exports['qb-banking']:GetAccountBalance(account)
    end)
    if ok then
        return toNumber(result)
    end
    return nil
end

local function qbBankingAdd(account, amount, reason)
    local ok, result = pcall(function()
        return exports['qb-banking']:AddMoney(account, amount, reason or 'sp_bridge')
    end)
    return ok and result == true
end

local function qbBankingRemove(account, amount, reason)
    local ok, result = pcall(function()
        return exports['qb-banking']:RemoveMoney(account, amount, reason or 'sp_bridge')
    end)
    return ok and result == true
end

local function qbManagementGet(account)
    local ok, result = pcall(function()
        return exports['qb-management']:GetAccount(account)
    end)
    if ok then
        return toNumber(result)
    end
    return nil
end

local function qbManagementAdd(account, amount)
    local ok, result = pcall(function()
        return exports['qb-management']:AddMoney(account, amount)
    end)
    return ok and (result == nil or result == true)
end

local function qbManagementRemove(account, amount)
    local ok, result = pcall(function()
        return exports['qb-management']:RemoveMoney(account, amount)
    end)
    return ok and (result == nil or result == true)
end

local function okokGet(account)
    local ok, result = pcall(function()
        return exports['okokBanking']:GetAccount(account)
    end)
    if not ok then
        return nil
    end
    if type(result) == 'table' then
        return toNumber(result.money or result.balance or result.account_balance)
    end
    return toNumber(result)
end

local function okokAdd(account, amount)
    local ok, result = pcall(function()
        return exports['okokBanking']:AddMoney(account, amount)
    end)
    return ok and (result == nil or result == true)
end

local function okokRemove(account, amount)
    local ok, result = pcall(function()
        return exports['okokBanking']:RemoveMoney(account, amount)
    end)
    return ok and (result == nil or result == true)
end

function sp.getAccountBalance(account)
    if type(account) ~= 'string' or account == '' then
        return 0
    end

    if sp.banking == Bankings.RENEWED and GetResourceState('Renewed-Banking') == 'started' then
        return renewedGet(account) or 0
    end

    if sp.banking == Bankings.QB_BANKING and GetResourceState('qb-banking') == 'started' then
        return qbBankingGet(account) or 0
    end

    if sp.banking == Bankings.QB_MANAGEMENT and GetResourceState('qb-management') == 'started' then
        return qbManagementGet(account) or 0
    end

    if sp.banking == Bankings.OKOK and GetResourceState('okokBanking') == 'started' then
        return okokGet(account) or 0
    end

    if (sp.banking == Bankings.ESX_BANKING or sp.banking == Bankings.ESX_ADDON_ACCOUNT) and GetResourceState('esx_addonaccount') == 'started' then
        local acc = awaitAddonAccount(account)
        return toNumber(acc and acc.money or 0)
    end

    return 0
end

function sp.addAccountMoney(account, amount, reason)
    if type(account) ~= 'string' or account == '' then
        return false
    end

    amount = toNumber(amount)
    if amount <= 0 then
        return true
    end

    if sp.banking == Bankings.RENEWED and GetResourceState('Renewed-Banking') == 'started' then
        return renewedAdd(account, amount)
    end

    if sp.banking == Bankings.QB_BANKING and GetResourceState('qb-banking') == 'started' then
        return qbBankingAdd(account, amount, reason)
    end

    if sp.banking == Bankings.QB_MANAGEMENT and GetResourceState('qb-management') == 'started' then
        return qbManagementAdd(account, amount)
    end

    if sp.banking == Bankings.OKOK and GetResourceState('okokBanking') == 'started' then
        return okokAdd(account, amount)
    end

    if (sp.banking == Bankings.ESX_BANKING or sp.banking == Bankings.ESX_ADDON_ACCOUNT) and GetResourceState('esx_addonaccount') == 'started' then
        local acc = awaitAddonAccount(account)
        if not acc then
            return false
        end
        if type(acc.addMoney) ~= 'function' then
            return false
        end
        acc.addMoney(amount)
        return true
    end

    return false
end

function sp.removeAccountMoney(account, amount, reason)
    if type(account) ~= 'string' or account == '' then
        return false
    end

    amount = toNumber(amount)
    if amount <= 0 then
        return true
    end

    if sp.banking == Bankings.RENEWED and GetResourceState('Renewed-Banking') == 'started' then
        return renewedRemove(account, amount)
    end

    if sp.banking == Bankings.QB_BANKING and GetResourceState('qb-banking') == 'started' then
        return qbBankingRemove(account, amount, reason)
    end

    if sp.banking == Bankings.QB_MANAGEMENT and GetResourceState('qb-management') == 'started' then
        return qbManagementRemove(account, amount)
    end

    if sp.banking == Bankings.OKOK and GetResourceState('okokBanking') == 'started' then
        return okokRemove(account, amount)
    end

    if (sp.banking == Bankings.ESX_BANKING or sp.banking == Bankings.ESX_ADDON_ACCOUNT) and GetResourceState('esx_addonaccount') == 'started' then
        local acc = awaitAddonAccount(account)
        if not acc then
            return false
        end
        if type(acc.removeMoney) ~= 'function' then
            return false
        end
        acc.removeMoney(amount)
        return true
    end

    return false
end

function sp.getJobAccountBalance(job)
    return sp.getAccountBalance(job)
end

function sp.addJobAccountMoney(job, amount, reason)
    return sp.addAccountMoney(job, amount, reason)
end

function sp.removeJobAccountMoney(job, amount, reason)
    return sp.removeAccountMoney(job, amount, reason)
end

function sp.getGangAccountBalance(gang)
    if sp.banking == Bankings.QB_MANAGEMENT and GetResourceState('qb-management') == 'started' then
        local ok, result = pcall(function()
            return exports['qb-management']:GetGangAccount(gang)
        end)
        return ok and toNumber(result) or 0
    end

    return sp.getAccountBalance(gang)
end

function sp.addGangAccountMoney(gang, amount, reason)
    amount = toNumber(amount)
    if amount <= 0 then
        return true
    end

    if sp.banking == Bankings.QB_MANAGEMENT and GetResourceState('qb-management') == 'started' then
        local ok, result = pcall(function()
            return exports['qb-management']:AddGangMoney(gang, amount)
        end)
        return ok and (result == nil or result == true)
    end

    return sp.addAccountMoney(gang, amount, reason)
end

function sp.removeGangAccountMoney(gang, amount, reason)
    amount = toNumber(amount)
    if amount <= 0 then
        return true
    end

    if sp.banking == Bankings.QB_MANAGEMENT and GetResourceState('qb-management') == 'started' then
        local ok, result = pcall(function()
            return exports['qb-management']:RemoveGangMoney(gang, amount)
        end)
        return ok and (result == nil or result == true)
    end

    return sp.removeAccountMoney(gang, amount, reason)
end

exports('GetAccountBalance', function(account)
    return sp.getAccountBalance(account)
end)

exports('AddAccountMoney', function(account, amount, reason)
    return sp.addAccountMoney(account, amount, reason)
end)

exports('RemoveAccountMoney', function(account, amount, reason)
    return sp.removeAccountMoney(account, amount, reason)
end)

exports('GetJobAccountBalance', function(job)
    return sp.getJobAccountBalance(job)
end)

exports('AddJobAccountMoney', function(job, amount, reason)
    return sp.addJobAccountMoney(job, amount, reason)
end)

exports('RemoveJobAccountMoney', function(job, amount, reason)
    return sp.removeJobAccountMoney(job, amount, reason)
end)

exports('GetGangAccountBalance', function(gang)
    return sp.getGangAccountBalance(gang)
end)

exports('AddGangAccountMoney', function(gang, amount, reason)
    return sp.addGangAccountMoney(gang, amount, reason)
end)

exports('RemoveGangAccountMoney', function(gang, amount, reason)
    return sp.removeGangAccountMoney(gang, amount, reason)
end)
