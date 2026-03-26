function sp.canCarryItem(source, item, count, metadata)
    if sp.inventory == Inventories.OX then
        return exports.ox_inventory:CanCarryItem(source, item, count, metadata)
    end

    if sp.inventory == Inventories.QB then
        return exports['qb-inventory']:CanAddItem(source, item, count)
    end
    
    if sp.inventory == Inventories.QS then
        return exports['qs-inventory']:CanCarryItem(source, item, count, metadata)
    end

    return true
end

exports('CanCarryItem', function(source, item, count, metadata)
    return sp.canCarryItem(source, item, count, metadata)
end)
