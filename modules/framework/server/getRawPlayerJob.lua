-- modules/framework/server/getRawPlayerJob.lua
-- Returns the raw, framework-specific job table directly from the player object.
-- Schema differs per framework:
--   ESX:    { name, label, grade, grade_name, grade_label, grade_salary, ... }
--   QBCore: { name, label, onduty, isboss, grade={level,name,label,payment} }
--   QBOX:   same shape as QBCore
-- For a consistent cross-framework schema use GetNormalizedJob / GetPlayerJob.
function sp.getRawPlayerJob(source)
    -- ESX: use sp.frameworkProvider.getPlayer which uses the exports-backed
    -- path (more reliable than the CoreObject-only sp.getPlayer path).
    if sp.framework == Framework.ESX then
        local getP = sp.frameworkProvider and sp.frameworkProvider.getPlayer
        local Player = type(getP) == 'function' and getP(source) or sp.getPlayer(source)
        if not Player then return nil end
        local ok, job = pcall(function() return Player.job end)
        return (ok and type(job) == 'table') and job or nil
    end

    local Player = sp.getPlayer(source)
    if not Player then return nil end

    if sp.framework == Framework.QBCore or sp.framework == Framework.QBOX then
        local ok, job = pcall(function()
            return Player.PlayerData and Player.PlayerData.job
        end)
        return (ok and type(job) == 'table') and job or nil
    end

    return nil
end

exports('GetRawPlayerJob', function(source)
    return sp.getRawPlayerJob(source)
end)
