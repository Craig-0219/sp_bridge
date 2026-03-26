-- modules/framework/client/getNormalizedJob.lua
function sp.getNormalizedJob()
    if sp.clientProvider and type(sp.clientProvider.normalizeJob) == 'function' then
        return sp.clientProvider.normalizeJob()
    end
    return sp.defaultNormalizedJob()
end

exports('GetNormalizedJob', function()
    return sp.getNormalizedJob()
end)
