-- modules/framework/server/getCharacterId.lua
function sp.getCharacterId(source)
    if sp.frameworkProvider and type(sp.frameworkProvider.getCharacterId) == 'function' then
        return sp.frameworkProvider.getCharacterId(source)
    end
    return nil
end

exports('GetCharacterId', function(source)
    return sp.getCharacterId(source)
end)
