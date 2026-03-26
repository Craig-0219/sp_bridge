function sp.hasItem(source, item, metadata)
    return (sp.getItemCount(source, item, metadata) or 0) > 0
end

exports('HasItem', function(source, item, metadata)
    return sp.hasItem(source, item, metadata)
end)
