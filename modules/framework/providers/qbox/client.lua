-- modules/framework/providers/qbox/client.lua
-- NOTE: CoreObject == 'qbx_core' (string). Use exports.qbx_core:* only.
if sp.framework ~= Framework.QBOX then return end

local provider = {}

function provider.getPlayerData()
    local ok, data = pcall(function()
        return exports.qbx_core:GetPlayerData()
    end)
    if ok and type(data) == 'table' then return data end
    return nil
end

function provider.getMoney(moneyType)
    local pd = provider.getPlayerData()
    if not pd or type(pd.money) ~= 'table' then return 0 end
    local account = (moneyType == 'money') and 'cash' or moneyType
    return pd.money[account] or 0
end

function provider.normalizeMoney()
    local pd = provider.getPlayerData()
    if not pd or type(pd.money) ~= 'table' then return sp.defaultNormalizedMoney() end
    local m = pd.money
    return {
        cash  = m.cash  or 0,
        bank  = m.bank  or 0,
        black = (m.black_money ~= nil and m.black_money ~= 0) and m.black_money or nil,
    }
end

function provider.normalizeJob()
    local pd = provider.getPlayerData()
    if not pd then return sp.defaultNormalizedJob() end
    return sp.normalizeQBOXJob(pd.job)
end

function provider.normalizeGang()
    local pd = provider.getPlayerData()
    if not pd then return nil end
    return sp.normalizeQBOXGang(pd.gang)
end

function provider.getCharacterId()
    local pd = provider.getPlayerData()
    if not pd then return nil end
    return pd.citizenid
end

function provider.normalizePlayerData()
    local pd   = provider.getPlayerData()
    local data = sp.defaultNormalizedPlayerData()
    if not pd then return data end
    data.identifier  = pd.license or pd.steamid
    data.characterId = pd.citizenid
    data.name = (pd.charinfo and (pd.charinfo.firstname .. ' ' .. pd.charinfo.lastname)) or nil
    data.job      = provider.normalizeJob()
    data.gang     = provider.normalizeGang()
    data.money    = provider.normalizeMoney()
    data.metadata = pd.metadata
    return data
end

sp.clientProvider = provider
sp.print.info('[provider] QBOX client provider registered')
