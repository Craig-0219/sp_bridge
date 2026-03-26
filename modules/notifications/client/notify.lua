local function toString(value)
    if value == nil then
        return ''
    end
    if type(value) == 'string' then
        return value
    end
    return tostring(value)
end

local function toNumber(value, fallback)
    local n = tonumber(value)
    if n then
        return n
    end
    return fallback
end

local function normalizeType(value, fallback)
    local t = type(value) == 'string' and value:lower() or ''
    if t == '' then
        return fallback
    end
    return t
end

function sp.notifyClient(message, notifyType, data)
    local msg = toString(message)
    if msg == '' then
        return false
    end

    local duration = toNumber(data and data.duration, 3000)
    local title = toString(data and data.title)
    local ntype = normalizeType(notifyType, 'inform')

    if sp.notification == Notifications.OX then
        if GetResourceState('ox_lib') ~= 'started' then
            return false
        end

        local payload = {
            title = title ~= '' and title or nil,
            description = msg,
            type = ntype,
            duration = duration,
            position = toString(data and data.position) ~= '' and toString(data and data.position) or nil
        }

        local ok = pcall(function()
            if type(lib) == 'table' and type(lib.notify) == 'function' then
                lib.notify(payload)
            else
                exports.ox_lib:notify(payload)
            end
        end)
        return ok
    end

    if sp.notification == Notifications.OKOK then
        if GetResourceState('okokNotify') ~= 'started' then
            return false
        end

        local ok = pcall(function()
            exports['okokNotify']:Alert(title ~= '' and title or 'Notification', msg, duration, ntype, false)
        end)
        return ok
    end

    if sp.notification == Notifications.MYTHIC then
        if GetResourceState('mythic_notify') ~= 'started' then
            return false
        end

        local ok = pcall(function()
            exports['mythic_notify']:DoHudText(ntype, msg)
        end)
        return ok
    end

    if sp.notification == Notifications.ESX then
        if GetResourceState('es_extended') ~= 'started' then
            return false
        end

        local ok, esx = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if not ok or not esx or type(esx.ShowNotification) ~= 'function' then
            return false
        end

        return pcall(function()
            esx.ShowNotification(msg)
        end)
    end

    if sp.notification == Notifications.QBCore or sp.notification == Notifications.QBOX then
        return pcall(function()
            TriggerEvent('QBCore:Notify', msg, ntype, duration)
        end)
    end

    return false
end

RegisterNetEvent('sp_bridge:notify', function(message, notifyType, data)
    sp.notifyClient(message, notifyType, data)
end)

exports('Notify', function(message, notifyType, data)
    return sp.notifyClient(message, notifyType, data)
end)
