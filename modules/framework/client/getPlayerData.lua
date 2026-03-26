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
        -- CoreObject 在 QBOX 是字串 'qbx_core'，無法用 table 方式存取
        -- 需確認版本：exports.qbx_core:GetPlayerData() 在 qbx_core 現代版本（2023+）支援
        local ok, data = pcall(function()
            return exports.qbx_core:GetPlayerData()
        end)
        if ok and type(data) == 'table' then
            return data
        end
        return nil
    end

    return nil
end

exports('GetPlayerData', function()
    return sp.getPlayerData()
end)
