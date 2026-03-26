-- modules/framework/client/getPlayerJob.lua
-- Returns NormalizedJob (see modules/core/shared.lua for schema).
-- Fields: name, label, onduty, isBoss, grade.{level,name,label,salary}
function sp.getPlayerJob()
    if sp.clientProvider and type(sp.clientProvider.normalizeJob) == 'function' then
        return sp.clientProvider.normalizeJob()
    end
    return nil
end

exports('GetPlayerJob', function()
    return sp.getPlayerJob()
end)
