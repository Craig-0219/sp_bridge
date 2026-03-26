-- modules/framework/client/getPlayerJob.lua
-- Returns NormalizedJob. This is an explicit alias for GetNormalizedJob.
-- Schema: { name, label, onduty, isBoss, grade={level,name,label,salary} }
--
-- BREAKING CHANGE (Sprint 2): previously returned the raw, framework-specific
-- job table. Use GetRawPlayerJob to recover that behavior.
function sp.getPlayerJob()
    return sp.getNormalizedJob()
end

exports('GetPlayerJob', function()
    return sp.getPlayerJob()
end)
