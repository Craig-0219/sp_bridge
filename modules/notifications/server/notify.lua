function sp.notify(source, message, notifyType, data)
    if type(source) ~= 'number' then
        return false
    end

    TriggerClientEvent('sp_bridge:notify', source, message, notifyType, data)
    return true
end

exports('Notify', function(source, message, notifyType, data)
    return sp.notify(source, message, notifyType, data)
end)
