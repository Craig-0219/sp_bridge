-- modules/framework/client/getPlayerData.lua
-- Returns the raw framework player data table.
-- Schema is INCONSISTENT across frameworks:
--   ESX:    GetPlayerData() result ({ accounts, job, identifier, ... })
--   QBCore: GetPlayerData() result ({ citizenid, job, money, ... })
--   QBOX:   GetPlayerData() via exports.qbx_core (same shape as QBCore)
--
-- DEPRECATED: use GetNormalizedPlayerData for a stable cross-framework schema.
-- GetRawPlayerData is an explicit alias for this function (same behavior).
function sp.getPlayerData()
    if sp.framework == Framework.ESX then
        if CoreObject and type(CoreObject.GetPlayerData) == 'function' then
            return CoreObject.GetPlayerData()
        end
        return nil
    end

    if sp.framework == Framework.QBCore then
        if CoreObject
            and type(CoreObject.Functions) == 'table'
            and type(CoreObject.Functions.GetPlayerData) == 'function'
        then
            return CoreObject.Functions.GetPlayerData()
        end
        return nil
    end

    if sp.framework == Framework.QBOX then
        -- CoreObject == 'qbx_core' (string); cannot use table access
        local ok, data = pcall(function()
            return exports.qbx_core:GetPlayerData()
        end)
        if ok and type(data) == 'table' then return data end
        return nil
    end

    return nil
end

exports('GetPlayerData', function()
    return sp.getPlayerData()
end)

exports('GetRawPlayerData', function()
    return sp.getPlayerData()
end)
