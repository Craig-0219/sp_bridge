function sp.getItemCount(source, item, metadata)
    if sp.inventory == Inventories.OX then
        return exports.ox_inventory:Search(source, 'count', item, metadata)
    end

    if sp.inventory == Inventories.QB then
        local count = exports['qb-inventory']:GetItemCount(source, item)
        return count or 0
    end
    
    if sp.inventory == Inventories.QS then
         local count = exports['qs-inventory']:GetItemTotalAmount(source, item)
         return count or 0
    end

    return 0
end

exports('GetItemCount', function(source, item, metadata)
    return sp.getItemCount(source, item, metadata)
end)
