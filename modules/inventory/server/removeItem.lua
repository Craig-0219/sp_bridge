function sp.removeItem(source, item, count, metadata)
    if sp.inventory == Inventories.OX then
        return exports.ox_inventory:RemoveItem(source, item, count, metadata)
    end

    if sp.inventory == Inventories.QB then
        return exports['qb-inventory']:RemoveItem(source, item, count, nil)
    end
    
    if sp.inventory == Inventories.QS then
        return exports['qs-inventory']:RemoveItem(source, item, count, nil, metadata)
    end

    return false
end

exports('RemoveItem', function(source, item, count, metadata)
    return sp.removeItem(source, item, count, metadata)
end)
