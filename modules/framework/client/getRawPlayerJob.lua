-- modules/framework/client/getRawPlayerJob.lua
-- Returns the raw, framework-specific job table from local player data.
-- Schema differs per framework:
--   ESX:    { name, label, grade, grade_name, grade_label, grade_salary, ... }
--   QBCore: { name, label, onduty, isboss, grade={level,name,label,payment} }
--   QBOX:   same shape as QBCore
-- For a consistent cross-framework schema use GetNormalizedJob / GetPlayerJob.
function sp.getRawPlayerJob()
    local data = sp.getPlayerData()
    if type(data) ~= 'table' then return nil end

    if sp.framework == Framework.ESX then
        return type(data.job) == 'table' and data.job or nil
    end

    if sp.framework == Framework.QBCore or sp.framework == Framework.QBOX then
        local job = data.job or (data.PlayerData and data.PlayerData.job)
        return type(job) == 'table' and job or nil
    end

    return nil
end

exports('GetRawPlayerJob', function()
    return sp.getRawPlayerJob()
end)
