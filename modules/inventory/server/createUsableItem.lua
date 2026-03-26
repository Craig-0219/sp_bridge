-- modules/inventory/server/createUsableItem.lua
function sp.createUsableItem(item, cb)
    if type(item) ~= 'string' or item == '' then return false end
    if type(cb) ~= 'function' then return false end

    if sp.framework == Framework.ESX then
        if type(CoreObject) == 'table' and type(CoreObject.RegisterUsableItem) == 'function' then
            CoreObject.RegisterUsableItem(item, cb)
            return true
        end
        return false
    end

    if sp.framework == Framework.QBCore then
        if type(CoreObject) == 'table'
            and type(CoreObject.Functions) == 'table'
            and type(CoreObject.Functions.CreateUseableItem) == 'function'
        then
            CoreObject.Functions.CreateUseableItem(item, cb)
            return true
        end
        return false
    end

    if sp.framework == Framework.QBOX then
        -- CoreObject == 'qbx_core' (string); type check would always fail here
        local ok = pcall(function()
            exports.qbx_core:CreateUseableItem(item, cb)
        end)
        return ok
    end

    return false
end

exports('CreateUsableItem', function(item, cb)
    return sp.createUsableItem(item, cb)
end)
