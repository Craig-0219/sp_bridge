function sp.itemDeployer(items, cb)
    if type(items) ~= 'table' then
        return 0
    end

    local count = 0
    for i = 1, #items do
        local name = items[i]
        if type(name) == 'string' and name ~= '' then
            if sp.createUsableItem(name, cb) then
                count = count + 1
            end
        end
    end

    return count
end

exports('ItemDeployer', function(items, cb)
    return sp.itemDeployer(items, cb)
end)
