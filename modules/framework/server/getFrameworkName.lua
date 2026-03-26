local function normalizeFrameworkName(rawName)
    if type(rawName) ~= 'string' or rawName == '' then
        return nil
    end

    local lowered = rawName:lower()

    if lowered == 'es_extended' or lowered == 'esx' then
        return 'esx'
    end

    if lowered == 'qbx_core' or lowered == 'qbox' or lowered == 'qbx' then
        return 'qbx'
    end

    if lowered == 'qb-core' or lowered == 'qbcore' then
        return 'qbcore'
    end

    return nil
end

exports('GetFrameworkName', function(mode)
    local rawName = sp and sp.framework or nil

    if mode == 'resource' then
        return rawName
    end

    return normalizeFrameworkName(rawName)
end)

exports('GetDetectedSystems', function()
    local rawName = sp and sp.framework or nil

    return {
        framework = rawName,
        frameworkName = normalizeFrameworkName(rawName),
        inventory = sp and sp.inventory or nil,
        notification = sp and sp.notification or nil,
        target = sp and sp.target or nil,
        banking = sp and sp.banking or nil,
        context = sp and sp.context or nil,
        loaded = sp and sp.loaded == true or false
    }
end)
