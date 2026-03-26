-- modules/framework/client/getCharacterId.lua
function sp.getCharacterId()
    if sp.clientProvider and type(sp.clientProvider.getCharacterId) == 'function' then
        return sp.clientProvider.getCharacterId()
    end
    return nil
end

exports('GetCharacterId', function()
    return sp.getCharacterId()
end)
