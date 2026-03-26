-- modules/framework/server/getNormalizedJob.lua
function sp.getNormalizedJob(source)
    if sp.frameworkProvider and type(sp.frameworkProvider.normalizeJob) == 'function' then
        return sp.frameworkProvider.normalizeJob(source)
    end
    return sp.defaultNormalizedJob()
end

exports('GetNormalizedJob', function(source)
    return sp.getNormalizedJob(source)
end)
