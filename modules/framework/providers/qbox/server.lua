-- modules/framework/providers/qbox/server.lua
-- NOTE: CoreObject == 'qbx_core' (string) for QBOX. Never use it as a table.
-- All player operations must go through exports.qbx_core:* directly.
if sp.framework ~= Framework.QBOX then return end

local provider = {}

function provider.getPlayer(source)
    local ok, Player = pcall(function()
        return exports.qbx_core:GetPlayer(source)
    end)
    if ok and Player then return Player end
    return nil
end

function provider.getMoney(source, moneyType)
    local Player = provider.getPlayer(source)
    if not Player then return 0 end
    local account = (moneyType == 'money') and 'cash' or moneyType
    local okData, dataValue = pcall(function()
        return Player.PlayerData and Player.PlayerData.money and Player.PlayerData.money[account]
    end)
    if okData and type(dataValue) == 'number' then
        return dataValue
    end
    local ok, val = pcall(function()
        return Player.Functions.GetMoney(account)
    end)
    if ok and type(val) == 'number' then return val end
    return 0
end

function provider.normalizeMoney(source)
    local function get(acc) return provider.getMoney(source, acc) end
    local black = get('black_money')
    return {
        cash  = get('money'),
        bank  = get('bank'),
        black = black ~= 0 and black or nil,
    }
end

function provider.normalizeJob(source)
    local Player = provider.getPlayer(source)
    if not Player then return sp.defaultNormalizedJob() end
    local ok, job = pcall(function()
        return Player.PlayerData and Player.PlayerData.job
    end)
    if not ok or not job then return sp.defaultNormalizedJob() end
    return sp.normalizeQBOXJob(job)
end

function provider.normalizeGang(source)
    local Player = provider.getPlayer(source)
    if not Player then return nil end
    local ok, gang = pcall(function()
        return Player.PlayerData and Player.PlayerData.gang
    end)
    if not ok or not gang then return nil end
    return sp.normalizeQBOXGang(gang)
end

function provider.getCharacterId(source)
    local Player = provider.getPlayer(source)
    if not Player then return nil end
    local ok, cid = pcall(function()
        return Player.PlayerData and Player.PlayerData.citizenid
    end)
    return ok and cid or nil
end

function provider.normalizePlayerData(source)
    local Player = provider.getPlayer(source)
    local data   = sp.defaultNormalizedPlayerData()
    data.source  = source
    if not Player then return data end

    local pd     = Player.PlayerData or {}
    data.identifier  = pd.license or pd.steamid
    data.characterId = pd.citizenid
    data.name = (pd.charinfo and (pd.charinfo.firstname .. ' ' .. pd.charinfo.lastname)) or nil
    data.job      = provider.normalizeJob(source)
    data.gang     = provider.normalizeGang(source)
    data.money    = provider.normalizeMoney(source)
    data.metadata = pd.metadata
    return data
end

sp.frameworkProvider = provider
sp.print.info('[provider] QBOX server provider registered')
