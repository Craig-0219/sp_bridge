-- modules/framework/providers/esx/server.lua
if sp.framework ~= Framework.ESX then return end

local provider = {}

function provider.getPlayer(source)
    local ok, Player = pcall(function()
        return CoreObject.GetPlayerFromId(source)
    end)
    if ok and Player then return Player end
    return nil
end

function provider.getMoney(source, moneyType)
    local Player = provider.getPlayer(source)
    if not Player then return 0 end
    local account = (moneyType == 'cash') and 'money' or moneyType
    local ok, val = pcall(function()
        return Player.getAccount(account).money
    end)
    if ok and type(val) == 'number' then return val end
    return 0
end

function provider.normalizeMoney(source)
    local Player = provider.getPlayer(source)
    if not Player then return sp.defaultNormalizedMoney() end
    local function getAmt(name)
        local ok, val = pcall(function() return Player.getAccount(name).money end)
        return (ok and type(val) == 'number') and val or 0
    end
    local black = getAmt('black_money')
    return {
        cash  = getAmt('money'),
        bank  = getAmt('bank'),
        black = black ~= 0 and black or nil,
    }
end

function provider.normalizeJob(source)
    local Player = provider.getPlayer(source)
    if not Player then return sp.defaultNormalizedJob() end
    local ok, job = pcall(function() return Player.job end)
    if not ok then return sp.defaultNormalizedJob() end
    return sp.normalizeESXJob(job)
end

function provider.getCharacterId(source)
    -- ESX uses identifier as primary ID; no separate characterId
    local Player = provider.getPlayer(source)
    if not Player then return nil end
    local ok, id = pcall(function() return Player.identifier end)
    return ok and id or nil
end

function provider.normalizePlayerData(source)
    local Player = provider.getPlayer(source)
    local data   = sp.defaultNormalizedPlayerData()
    data.source  = source
    if not Player then return data end

    local ok
    ok, data.identifier = pcall(function() return Player.identifier end)
    if not ok then data.identifier = nil end
    data.characterId = data.identifier

    ok, data.name = pcall(function() return Player.getName() end)
    if not ok then data.name = nil end

    data.job   = provider.normalizeJob(source)
    data.gang  = nil -- ESX has no native gang concept
    data.money = provider.normalizeMoney(source)
    return data
end

sp.frameworkProvider = provider
sp.print.info('[provider] ESX server provider registered')
