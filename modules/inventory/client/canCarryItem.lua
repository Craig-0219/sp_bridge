function sp.canCarryItemClient(item, count, metadata)
    if type(item) ~= 'string' or item == '' then
        return false
    end

    count = tonumber(count) or 1
    if count <= 0 then
        return true
    end

    if sp.inventory == Inventories.OX and GetResourceState('ox_inventory') == 'started' then
        local ok, result = pcall(function()
            return exports.ox_inventory:CanCarryItem(item, count, metadata)
        end)
        return ok and result == true
    end

    return true
end

exports('CanCarryItemClient', function(item, count, metadata)
    return sp.canCarryItemClient(item, count, metadata)
end)
