local function normalizeName(value)
    if type(value) == 'string' then
        return value
    end
    if value == nil then
        return nil
    end
    return tostring(value)
end

local function normalizeItems(raw)
    local out = {}
    if type(raw) ~= 'table' then
        return out
    end

    for k, v in pairs(raw) do
        local name = nil
        local def = nil

        if type(k) == 'string' then
            name = k
            if type(v) == 'table' then
                def = v
            else
                def = { label = normalizeName(v) }
            end
        elseif type(v) == 'table' then
            name = normalizeName(v.name or v.item or v.id)
            def = v
        end

        if type(name) == 'string' and name ~= '' then
            local label = def and def.label or nil
            if type(label) ~= 'string' or label == '' then
                label = def and def.name or nil
            end
            if type(label) ~= 'string' or label == '' then
                label = name
            end

            local weight = 0
            if def and def.weight ~= nil then
                weight = tonumber(def.weight) or 0
            end

            out[name] = {
                name = name,
                label = label,
                weight = weight,
                description = def and def.description or nil,
                image = def and def.image or nil,
                stack = def and def.stack or nil,
                unique = def and def.unique or nil,
            }
        end
    end

    return out
end

local function tryGetOxInventoryDefinitions()
    if GetResourceState('ox_inventory') ~= 'started' then
        return nil
    end

    local ok, items = pcall(function()
        return exports.ox_inventory:Items()
    end)
    if ok and type(items) == 'table' then
        return items
    end

    return nil
end

local function tryGetQsInventoryDefinitions()
    if GetResourceState('qs-inventory') ~= 'started' then
        return nil
    end

    local ok, items = pcall(function()
        return exports['qs-inventory']:GetItemList()
    end)
    if ok and type(items) == 'table' then
        return items
    end

    return nil
end

function sp.getItemDefinitions()
    if (sp.framework == Framework.QBCore or sp.framework == Framework.QBOX)
        and type(CoreObject) == 'table'
        and type(CoreObject.Shared) == 'table'
        and type(CoreObject.Shared.Items) == 'table'
    then
        return normalizeItems(CoreObject.Shared.Items)
    end

    local raw = nil

    if sp.inventory == Inventories.OX then
        raw = tryGetOxInventoryDefinitions()
    elseif sp.inventory == Inventories.QS then
        raw = tryGetQsInventoryDefinitions()
    end

    raw = raw or tryGetOxInventoryDefinitions() or tryGetQsInventoryDefinitions()

    return normalizeItems(raw)
end

function sp.items(itemName)
    local defs = sp.getItemDefinitions()
    if type(itemName) == 'string' and itemName ~= '' then
        return defs[itemName]
    end
    return defs
end

exports('GetItemDefinitions', function()
    return sp.getItemDefinitions()
end)

exports('GetItems', function()
    return sp.getItemDefinitions()
end)

exports('GetAllItems', function()
    return sp.getItemDefinitions()
end)

exports('GetItemList', function()
    return sp.getItemDefinitions()
end)

exports('Items', function(itemName)
    return sp.items(itemName)
end)
