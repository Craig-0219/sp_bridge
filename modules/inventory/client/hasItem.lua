function sp.hasItemClient(item, metadata)
    return (sp.getItemCountClient(item, metadata) or 0) > 0
end

exports('HasItemClient', function(item, metadata)
    return sp.hasItemClient(item, metadata)
end)
