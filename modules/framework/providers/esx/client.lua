-- modules/framework/providers/esx/client.lua
if sp.framework ~= Framework.ESX then return end

local provider = {}

function provider.getPlayerData()
    if CoreObject and type(CoreObject.GetPlayerData) == 'function' then
        return CoreObject.GetPlayerData()
    end
    return nil
end

function provider.getMoney(moneyType)
    local pd = provider.getPlayerData()
    if not pd then return 0 end
    local account = (moneyType == 'cash') and 'money' or moneyType
    if type(pd.accounts) == 'table' then
        for _, acc in ipairs(pd.accounts) do
            if acc.name == account then return acc.money or 0 end
        end
    end
    return 0
end

function provider.normalizeMoney()
    local function get(acc) return provider.getMoney(acc) end
    local black = get('black_money')
    return {
        cash  = get('cash'),
        bank  = get('bank'),
        black = black ~= 0 and black or nil,
    }
end

function provider.normalizeJob()
    local pd = provider.getPlayerData()
    if not pd then return sp.defaultNormalizedJob() end
    return sp.normalizeESXJob(pd.job)
end

function provider.getCharacterId()
    local pd = provider.getPlayerData()
    if not pd then return nil end
    return pd.identifier
end

function provider.normalizePlayerData()
    local pd   = provider.getPlayerData()
    local data = sp.defaultNormalizedPlayerData()
    if not pd then return data end
    data.identifier  = pd.identifier
    data.characterId = pd.identifier
    data.name        = pd.name
    data.job         = provider.normalizeJob()
    data.gang        = nil
    data.money       = provider.normalizeMoney()
    return data
end

sp.clientProvider = provider
sp.print.info('[provider] ESX client provider registered')
