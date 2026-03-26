function sp.canCarryItemsClient(items)
    if type(items) ~= 'table' then
        return false
    end

    for i = 1, #items do
        local entry = items[i]
        local name = type(entry) == 'table' and entry.name or nil
        local count = type(entry) == 'table' and entry.count or nil
        local metadata = type(entry) == 'table' and entry.metadata or nil
        if type(name) ~= 'string' or name == '' then
            return false
        end
        if sp.canCarryItemClient(name, count, metadata) ~= true then
            return false
        end
    end

    return true
end

exports('CanCarryItemsClient', function(items)
    return sp.canCarryItemsClient(items)
end)
