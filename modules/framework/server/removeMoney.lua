function sp.removeMoney(source, moneyType, amount, reason)
    amount = tonumber(amount) or 0
    if amount <= 0 then return true end

    if sp.framework == Framework.ESX then
        local account = (moneyType == 'cash') and 'money' or moneyType

        -- 與 addMoney 對稱：直接呼叫 ox_inventory 移除 money 物品
        if account == 'money' and sp.inventory == Inventories.OX then
            local ok, result = pcall(exports.ox_inventory.RemoveItem, exports.ox_inventory, source, 'money', amount)
            if not ok or not result then
                -- 失敗（餘額不足或 ox_inventory 錯誤）fallback 到 ESX 路徑
                local Player = sp.getPlayer(source)
                if not Player then return false end
                Player.removeMoney(amount, reason)
                return true
            end
            -- 同步 ESX 記憶體狀態與 client HUD
            local Player = sp.getPlayer(source)
            if Player then
                local acc = Player.getAccount('money')
                if acc then
                    acc.money = math.max(0, acc.money - amount)
                    Player.triggerEvent('esx:setAccountMoney', acc)
                    TriggerEvent('esx:removeAccountMoney', source, 'money', amount, reason or 'sp_bridge')
                end
            end
            return true
        end

        local Player = sp.getPlayer(source)
        if not Player then return false end
        if account == 'money' then
            Player.removeMoney(amount, reason)
        else
            Player.removeAccountMoney(account, amount, reason)
        end
        return true
    end

    if sp.framework == Framework.QBCore then
        local account = (moneyType == 'money') and 'cash' or moneyType
        local ok = Player.Functions.RemoveMoney(account, amount, reason)
        if ok == nil then return true end
        return ok and true or false
    end

    if sp.framework == Framework.QBOX then
        local account = (moneyType == 'money') and 'cash' or moneyType
        local ok = Player.Functions.RemoveMoney(account, amount, reason)
        if ok == nil then return true end
        return ok and true or false
    end

    return false
end

exports('RemoveMoney', function(source, moneyType, amount, reason)
    return sp.removeMoney(source, moneyType, amount, reason)
end)
