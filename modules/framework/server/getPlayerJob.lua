-- modules/framework/server/getPlayerJob.lua
-- Returns NormalizedJob (see modules/core/shared.lua for schema).
-- Fields: name, label, onduty, isBoss, grade.{level,name,label,salary}
function sp.getPlayerJob(source)
    if sp.frameworkProvider and type(sp.frameworkProvider.normalizeJob) == 'function' then
        return sp.frameworkProvider.normalizeJob(source)
    end
    return nil
end

exports('GetPlayerJob', function(source)
    return sp.getPlayerJob(source)
end)
