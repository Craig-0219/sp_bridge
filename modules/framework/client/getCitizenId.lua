-- modules/framework/client/getCitizenId.lua
-- Delegates to sp.getCharacterId which routes through sp.clientProvider.
-- Kept as a separate export for backward compatibility.
function sp.getCitizenId()
    return sp.getCharacterId()
end

exports('GetCitizenId', function()
    return sp.getCitizenId()
end)
