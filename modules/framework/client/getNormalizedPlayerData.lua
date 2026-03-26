-- modules/framework/client/getNormalizedPlayerData.lua
function sp.getNormalizedPlayerData()
    if sp.clientProvider and type(sp.clientProvider.normalizePlayerData) == 'function' then
        return sp.clientProvider.normalizePlayerData()
    end
    return sp.defaultNormalizedPlayerData()
end

exports('GetNormalizedPlayerData', function()
    return sp.getNormalizedPlayerData()
end)
