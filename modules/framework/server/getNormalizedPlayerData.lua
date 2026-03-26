-- modules/framework/server/getNormalizedPlayerData.lua
function sp.getNormalizedPlayerData(source)
    if sp.frameworkProvider and type(sp.frameworkProvider.normalizePlayerData) == 'function' then
        return sp.frameworkProvider.normalizePlayerData(source)
    end
    return sp.defaultNormalizedPlayerData()
end

exports('GetNormalizedPlayerData', function(source)
    return sp.getNormalizedPlayerData(source)
end)
