-- Legacy compatibility export for resources that expect an ESX-style
-- shared object from sp_bridge.
local function buildSharedObject()
    return {
        Framework = {
            getFrameworkIdentifier = function(source)
                return sp.getFrameworkIdentifier(source)
            end,
            getPlayerName = function(source)
                return sp.getPlayerName(source)
            end,
        },
        Banking = {
            getBankProviderName = function()
                return sp.getBankProviderName()
            end,
            getPlayerBankBalance = function(source)
                return sp.getPlayerBankBalance(source)
            end,
            addPlayerBankMoney = function(source, amount, reason)
                return sp.addPlayerBankMoney(source, amount, reason)
            end,
            removePlayerBankMoney = function(source, amount, reason)
                return sp.removePlayerBankMoney(source, amount, reason)
            end,
        },
        Notifications = {
            notify = function(source, payload)
                if type(payload) == 'table' then
                    return sp.notify(source, payload.message, payload.type, payload.data)
                end

                return sp.notify(source, payload, nil, nil)
            end,
        },
    }
end

exports('getSharedObject', function()
    return buildSharedObject()
end)
