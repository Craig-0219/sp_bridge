local entityTargets = {}
local pendingAttach = {}

local function toString(value)
    if value == nil then
        return ''
    end
    if type(value) == 'string' then
        return value
    end
    return tostring(value)
end

local function toNumber(value, fallback)
    local n = tonumber(value)
    if n then
        return n
    end
    return fallback
end

local function ensureArray(value)
    if type(value) == 'table' then
        return value
    end
    return {}
end

local function getCaller()
    local r = GetInvokingResource()
    if type(r) == 'string' and r ~= '' then
        return r
    end
    return cache and cache.resource or sp.name
end

local function resolveActiveTarget()
    if sp.target == Targets.QB and GetResourceState('qb-target') == 'started' then
        return Targets.QB
    end

    if sp.target == Targets.OX and GetResourceState('ox_target') == 'started' then
        return Targets.OX
    end

    if GetResourceState('qb-target') == 'started' then
        sp.target = Targets.QB
        return Targets.QB
    end

    if GetResourceState('ox_target') == 'started' then
        sp.target = Targets.OX
        return Targets.OX
    end

    sp.target = nil
    return nil
end

local function extractOptionNames(options, targetType)
    local names = {}
    if targetType == Targets.OX then
        for i = 1, #options do
            local opt = options[i]
            local name = type(opt) == 'table' and toString(opt.name) or ''
            if name ~= '' then
                names[#names + 1] = name
            end
        end
        return names
    end

    if targetType == Targets.QB then
        for i = 1, #options do
            local opt = options[i]
            local label = type(opt) == 'table' and toString(opt.label) or ''
            if label ~= '' then
                names[#names + 1] = label
            end
        end
        return names
    end

    return names
end

local function splitOxEntities(entities)
    local netIds = {}
    local localEntityIds = {}

    for i = 1, #entities do
        local entity = tonumber(entities[i])
        if entity then
            if DoesEntityExist(entity) then
                if NetworkGetEntityIsNetworked(entity) then
                    local netId = NetworkGetNetworkIdFromEntity(entity)
                    if type(netId) == 'number' and netId > 0 then
                        netIds[#netIds + 1] = netId
                    else
                        localEntityIds[#localEntityIds + 1] = entity
                    end
                else
                    localEntityIds[#localEntityIds + 1] = entity
                end
            elseif NetworkDoesNetworkIdExist(entity) then
                netIds[#netIds + 1] = entity
            end
        end
    end

    return netIds, localEntityIds
end

local function isTrackedEntityValid(entityRef)
    local entity = tonumber(entityRef)
    if not entity or entity <= 0 then
        return false
    end

    if DoesEntityExist(entity) then
        return true
    end

    if NetworkDoesNetworkIdExist(entity) then
        return true
    end

    return false
end

local function pruneCallerTargets(caller)
    local callerTargets = entityTargets[caller]
    if type(callerTargets) ~= 'table' then
        return
    end

    for ent, names in pairs(callerTargets) do
        if not isTrackedEntityValid(ent) then
            callerTargets[ent] = nil
        elseif type(names) ~= 'table' then
            callerTargets[ent] = nil
        elseif next(names) == nil then
            callerTargets[ent] = nil
        end
    end

    if next(callerTargets) == nil then
        entityTargets[caller] = nil
    end
end

local function clearPendingAttach(caller, entity)
    local callerPending = pendingAttach[caller]
    if type(callerPending) ~= 'table' then
        return
    end

    callerPending[entity] = nil
    if next(callerPending) == nil then
        pendingAttach[caller] = nil
    end
end

function sp.addTargetEntity(entities, options)
    if type(entities) == 'number' then
        entities = { entities }
    end
    entities = ensureArray(entities)
    if #entities == 0 then
        return nil
    end

    local opts = ensureArray(options)
    if #opts == 0 then
        return nil
    end

    local baseDistance = toNumber(options and options.distance, nil)
    if not baseDistance then
        for i = 1, #opts do
            local d = tonumber(opts[i] and opts[i].distance)
            if d then
                baseDistance = d
                break
            end
        end
    end
    baseDistance = baseDistance or 2.0

    local targetType = resolveActiveTarget()
    if targetType == Targets.OX then
        if GetResourceState('ox_target') ~= 'started' then
            return nil
        end

        local oxOptions = {}
        local optionNames = {}

        for i = 1, #opts do
            local opt = opts[i]
            if type(opt) == 'table' then
                local name = toString(opt.name)
                if name == '' then
                    name = ('sp_bridge_entity_%s'):format(tostring(i))
                end

                local label = toString(opt.label)
                if label == '' then
                    label = name
                end

                local distance = toNumber(opt.distance, baseDistance)
                local canInteract
                if type(opt.canInteract) == 'function' then
                    canInteract = function(ent, dist, _, _, _)
                        return opt.canInteract(ent, dist)
                    end
                end

                local clientEvent = toString(opt.event)
                local serverEvent = toString(opt.serverEvent)
                local command = toString(opt.command)
                local args = opt.args

                oxOptions[#oxOptions + 1] = {
                    name = name,
                    label = label,
                    icon = toString(opt.icon) ~= '' and toString(opt.icon) or nil,
                    items = opt.items,
                    groups = opt.groups or opt.job,
                    distance = distance,
                    canInteract = canInteract,
                    onSelect = function(data)
                        if type(opt.onSelect) == 'function' then
                            pcall(opt.onSelect, data and data.entity or nil)
                            return
                        end

                        if clientEvent ~= '' then
                            TriggerEvent(clientEvent, args)
                            return
                        end

                        if serverEvent ~= '' then
                            TriggerServerEvent(serverEvent, args)
                            return
                        end

                        if command ~= '' then
                            ExecuteCommand(command)
                        end
                    end,
                }
                optionNames[#optionNames + 1] = name
            end
        end

        local netIds, localEntityIds = splitOxEntities(entities)
        local anyAdded = false

        if #netIds > 0 then
            local ok = pcall(function()
                exports.ox_target:addEntity(netIds, oxOptions)
            end)
            if not ok then
                return nil
            end
            anyAdded = true
        end

        if #localEntityIds > 0 then
            local ok = pcall(function()
                exports.ox_target:addLocalEntity(localEntityIds, oxOptions)
            end)
            if not ok then
                return nil
            end
            anyAdded = true
        end

        if not anyAdded then
            return nil
        end

        return optionNames
    end

    if targetType == Targets.QB then
        if GetResourceState('qb-target') ~= 'started' then
            return nil
        end

        local qbOptions = {}
        local optionLabels = {}

        for i = 1, #opts do
            local opt = opts[i]
            if type(opt) == 'table' then
                local label = toString(opt.label)
                if label == '' then
                    label = ('Entity %s'):format(tostring(i))
                end

                local canInteract
                if type(opt.canInteract) == 'function' then
                    canInteract = function(ent, dist, _)
                        return opt.canInteract(ent, dist)
                    end
                end

                local clientEvent = toString(opt.event)
                local serverEvent = toString(opt.serverEvent)
                local command = toString(opt.command)
                local args = opt.args

                qbOptions[#qbOptions + 1] = {
                    label = label,
                    icon = toString(opt.icon) ~= '' and toString(opt.icon) or nil,
                    item = type(opt.items) == 'table' and opt.items[1] or nil,
                    job = opt.job or opt.groups,
                    action = function(ent)
                        if type(opt.onSelect) == 'function' then
                            pcall(opt.onSelect, ent)
                            return
                        end

                        if clientEvent ~= '' then
                            TriggerEvent(clientEvent, args)
                            return
                        end

                        if serverEvent ~= '' then
                            TriggerServerEvent(serverEvent, args)
                            return
                        end

                        if command ~= '' then
                            ExecuteCommand(command)
                        end
                    end,
                    canInteract = canInteract,
                }
                optionLabels[#optionLabels + 1] = label
            end
        end

        local ok = pcall(function()
            exports['qb-target']:AddTargetEntity(entities, {
                options = qbOptions,
                distance = baseDistance,
            })
        end)
        if not ok then
            return nil
        end

        return optionLabels
    end

    return nil
end

function sp.removeTargetEntity(entities, options)
    if type(entities) == 'number' then
        entities = { entities }
    end
    entities = ensureArray(entities)
    if #entities == 0 then
        return false
    end

    local targetType = resolveActiveTarget()
    if targetType == Targets.OX then
        if GetResourceState('ox_target') ~= 'started' then
            return false
        end

        local names = options
        if type(names) == 'string' then
            names = { names }
        end
        names = ensureArray(names)
        if #names == 0 then
            return false
        end

        local netIds, localEntityIds = splitOxEntities(entities)
        local removedAny = false
        local ok = true

        if #netIds > 0 then
            ok = ok and pcall(function()
                exports.ox_target:removeEntity(netIds, names)
            end)
            removedAny = true
        end

        if #localEntityIds > 0 then
            ok = ok and pcall(function()
                exports.ox_target:removeLocalEntity(localEntityIds, names)
            end)
            removedAny = true
        end

        if not removedAny then
            return false
        end

        return ok
    end

    if targetType == Targets.QB then
        if GetResourceState('qb-target') ~= 'started' then
            return false
        end

        local ok = true
        for i = 1, #entities do
            local ent = entities[i]
            if type(ent) == 'number' then
                ok = ok and pcall(function()
                    exports['qb-target']:RemoveTargetEntity(ent)
                end)
            end
        end
        return ok
    end

    return false
end

local function addTargetEntityForCaller(caller, entities, options)
    local targetType = resolveActiveTarget()
    local optionNames = extractOptionNames(ensureArray(options), targetType)
    if #optionNames == 0 then
        return nil
    end

    if type(entities) == 'number' then
        entities = { entities }
    end
    entities = ensureArray(entities)
    if #entities == 0 then
        return nil
    end

    pruneCallerTargets(caller)
    entityTargets[caller] = entityTargets[caller] or {}
    for i = 1, #entities do
        local ent = entities[i]
        if type(ent) == 'number' then
            entityTargets[caller][ent] = entityTargets[caller][ent] or {}
            local hasExistingNames = false
            for j = 1, #optionNames do
                local name = optionNames[j]
                if entityTargets[caller][ent][name] then
                    hasExistingNames = true
                    break
                end
            end

            if hasExistingNames then
                pcall(function()
                    sp.removeTargetEntity(ent, optionNames)
                end)

                for j = 1, #optionNames do
                    entityTargets[caller][ent][optionNames[j]] = nil
                end

                if next(entityTargets[caller][ent]) == nil then
                    entityTargets[caller][ent] = nil
                end
            end
        end
    end

    local added = sp.addTargetEntity(entities, options)
    if type(added) ~= 'table' or #added == 0 then
        return nil
    end

    for i = 1, #entities do
        local ent = entities[i]
        if type(ent) == 'number' then
            entityTargets[caller][ent] = entityTargets[caller][ent] or {}
            for j = 1, #added do
                entityTargets[caller][ent][added[j]] = true
            end
        end
    end

    return added
end

local function removeTargetEntityForCaller(caller, entities, options)

    if type(entities) == 'number' then
        entities = { entities }
    end
    entities = ensureArray(entities)
    if #entities == 0 then
        return false
    end

    local opts = options
    if type(opts) == 'string' then
        opts = { opts }
    end
    opts = ensureArray(opts)
    if #opts == 0 then
        return false
    end

    for i = 1, #entities do
        local ent = entities[i]
        if type(ent) == 'number' then
            for j = 1, #opts do
                local name = opts[j]
                if not (entityTargets[caller] and entityTargets[caller][ent] and entityTargets[caller][ent][name]) then
                    return false
                end
            end
        end
    end

    for i = 1, #entities do
        local ent = entities[i]
        if type(ent) == 'number' then
            local ok = sp.removeTargetEntity(ent, opts)
            if not ok then
                return false
            end
            if entityTargets[caller] and entityTargets[caller][ent] then
                for j = 1, #opts do
                    entityTargets[caller][ent][opts[j]] = nil
                end
                if next(entityTargets[caller][ent]) == nil then
                    entityTargets[caller][ent] = nil
                end
            end
        end
    end

    if entityTargets[caller] and next(entityTargets[caller]) == nil then
        entityTargets[caller] = nil
    end

    return true
end

exports('AddTargetEntity', function(entities, options, ownerResource)
    local caller = type(ownerResource) == 'string' and ownerResource ~= '' and ownerResource or getCaller()
    return addTargetEntityForCaller(caller, entities, options)
end)

exports('RemoveTargetEntity', function(entities, options, ownerResource)
    local caller = type(ownerResource) == 'string' and ownerResource ~= '' and ownerResource or getCaller()
    return removeTargetEntityForCaller(caller, entities, options)
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if type(resourceName) ~= 'string' or resourceName == '' then
        return
    end

    entityTargets[resourceName] = nil
    pendingAttach[resourceName] = nil
end)

exports('AttachEntityTarget', function(entity, options)
    if type(entity) ~= 'number' then
        return false
    end
    local ownerResource = getCaller()

    local function tryAttach()
        local added = addTargetEntityForCaller(ownerResource, entity, options)
        return type(added) == 'table' and #added > 0
    end

    if tryAttach() then
        clearPendingAttach(ownerResource, entity)
        return true
    end

    pendingAttach[ownerResource] = pendingAttach[ownerResource] or {}
    if pendingAttach[ownerResource][entity] then
        return true
    end
    pendingAttach[ownerResource][entity] = true

    CreateThread(function()
        for _ = 1, 160 do
            if not isTrackedEntityValid(entity) then
                break
            end

            if resolveActiveTarget() and tryAttach() then
                break
            end

            Wait(125)
        end

        clearPendingAttach(ownerResource, entity)
    end)

    return true
end)

exports('RemoveEntityTarget', function(entity, options)
    if type(entity) ~= 'number' then
        return false
    end
    local ownerResource = getCaller()
    clearPendingAttach(ownerResource, entity)
    return removeTargetEntityForCaller(ownerResource, entity, options)
end)
