function sp.getItemLabelClient(item)
    if type(item) ~= 'string' or item == '' then
        return nil
    end

    if (sp.framework == Framework.QBCore or sp.framework == Framework.QBOX)
        and type(CoreObject) == 'table'
        and type(CoreObject.Shared) == 'table'
        and type(CoreObject.Shared.Items) == 'table'
    then
        local def = CoreObject.Shared.Items[item]
        if type(def) == 'table' then
            local label = def.label
            if type(label) == 'string' and label ~= '' then
                return label
            end
        end
    end

    return item
end

exports('GetItemLabelClient', function(item)
    return sp.getItemLabelClient(item)
end)
