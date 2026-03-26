function sp.getItemCountClient(item, metadata)
    if type(item) ~= 'string' or item == '' then
        return 0
    end

    if sp.inventory == Inventories.OX and GetResourceState('ox_inventory') == 'started' then
        local ok, result = pcall(function()
            return exports.ox_inventory:Search('count', item, metadata)
        end)
        return ok and (tonumber(result) or 0) or 0
    end

    local data = sp.getPlayerData()
    if type(data) ~= 'table' then
        return 0
    end

    local items = data.items or (data.PlayerData and data.PlayerData.items) or data.inventory
    if type(items) ~= 'table' then
        return 0
    end

    local total = 0
    for i = 1, #items do
        local entry = items[i]
        local name = entry and (entry.name or entry.item)
        if name == item then
            total = total + (tonumber(entry.amount or entry.count) or 1)
        end
    end

    return total
end

exports('GetItemCountClient', function(item, metadata)
    return sp.getItemCountClient(item, metadata)
end)
