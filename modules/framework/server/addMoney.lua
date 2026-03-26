function sp.addMoney(source, moneyType, amount, reason)
    amount = tonumber(amount) or 0
    if amount <= 0 then return true end

    if sp.framework == Framework.ESX then
        local account = (moneyType == 'cash') and 'money' or moneyType

        -- 當使用 ox_inventory 且帳戶為 money 時，直接呼叫 ox_inventory
        -- 避免 ESX override 雙重路徑（getPlayer + addAccountMoney + Inventory.AddItem）
        -- 改為：直接 DB 寫入 + 手動同步 ESX 記憶體狀態，減少約 1ms/次的 overhead
        if account == 'money' and sp.inventory == Inventories.OX then
            local ok, err = pcall(exports.ox_inventory.AddItem, exports.ox_inventory, source, 'money', amount)
            if not ok then
                -- ox_inventory 失敗時 fallback 到標準 ESX 路徑
                local Player = sp.getPlayer(source)
                if not Player then return false end
                Player.addMoney(amount, reason)
                return true
            end
            -- 同步 ESX 記憶體狀態與 client HUD（不重複寫 DB）
            local Player = sp.getPlayer(source)
            if Player then
                local acc = Player.getAccount('money')
                if acc then
                    acc.money = acc.money + amount
                    Player.triggerEvent('esx:setAccountMoney', acc)
                    TriggerEvent('esx:addAccountMoney', source, 'money', amount, reason or 'sp_bridge')
                end
            end
            return true
        end

        local Player = sp.getPlayer(source)
        if not Player then return false end
        if account == 'money' then
            Player.addMoney(amount, reason)
        else
            Player.addAccountMoney(account, amount, reason)
        end
        return true
    end

    if sp.framework == Framework.QBCore then
        local account = (moneyType == 'money') and 'cash' or moneyType
        local ok = Player.Functions.AddMoney(account, amount, reason)
        if ok == nil then return true end
        return ok and true or false
    end

    if sp.framework == Framework.QBOX then
        local account = (moneyType == 'money') and 'cash' or moneyType
        local ok = Player.Functions.AddMoney(account, amount, reason)
        if ok == nil then return true end
        return ok and true or false
    end

    return false
end

exports('AddMoney', function(source, moneyType, amount, reason)
    return sp.addMoney(source, moneyType, amount, reason)
end)
