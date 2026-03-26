exports('AttachNpcTarget', function(entity, options, maybeOptions)
    if type(entity) == 'table' and type(options) == 'number' and type(maybeOptions) == 'table' then
        entity, options = options, maybeOptions
    end

    local ok = exports[cache.resource]:AttachEntityTarget(entity, options)
    if ok ~= true then
        local caller = GetInvokingResource() or 'unknown'
        print(('[sp_bridge] AttachNpcTarget failed | caller=%s | entity=%s | target=%s | ox=%s | qb=%s'):format(
            tostring(caller),
            tostring(entity),
            tostring(sp.target),
            tostring(GetResourceState('ox_target')),
            tostring(GetResourceState('qb-target'))
        ))
    end
    return ok == true
end)

exports('RemoveNpcTarget', function(entity, options, maybeOptions)
    if type(entity) == 'table' and type(options) == 'number' then
        entity, options = options, maybeOptions
    end

    return exports[cache.resource]:RemoveEntityTarget(entity, options)
end)
