function sp.giveItem(source, item, count, metadata)
    return sp.addItem(source, item, count, metadata)
end

exports('GiveItem', function(source, item, count, metadata)
    return sp.giveItem(source, item, count, metadata)
end)
