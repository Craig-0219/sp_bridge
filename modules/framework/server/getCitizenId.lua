-- modules/framework/server/getCitizenId.lua
-- Delegates to sp.getCharacterId which routes through sp.frameworkProvider.
-- Kept as a separate export for backward compatibility.
function sp.getCitizenId(source)
    return sp.getCharacterId(source)
end

exports('GetCitizenId', function(source)
    return sp.getCitizenId(source)
end)
