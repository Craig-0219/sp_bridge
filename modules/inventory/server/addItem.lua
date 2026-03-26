function sp.addItem(source, item, count, metadata)
    if sp.inventory == Inventories.OX then
        return exports.ox_inventory:AddItem(source, item, count, metadata)
    end

    if sp.inventory == Inventories.QB then
        return exports['qb-inventory']:AddItem(source, item, count, nil, metadata)
    end

    if sp.inventory == Inventories.QS then
        return exports['qs-inventory']:AddItem(source, item, count, nil, metadata)
    end

    return false
end

exports('AddItem', function(source, item, count, metadata)
    return sp.addItem(source, item, count, metadata)
end)
