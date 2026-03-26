function sp.getInventoryImage(item)
    if type(item) ~= 'string' or item == '' then
        return nil
    end

    if sp.inventory == Inventories.OX then
        return ('nui://ox_inventory/web/images/%s.png'):format(item)
    end

    if sp.inventory == Inventories.QB then
        return ('nui://qb-inventory/html/images/%s.png'):format(item)
    end

    if sp.inventory == Inventories.QS then
        return ('nui://qs-inventory/html/images/%s.png'):format(item)
    end

    return nil
end

exports('GetInventoryImage', function(item)
    return sp.getInventoryImage(item)
end)
