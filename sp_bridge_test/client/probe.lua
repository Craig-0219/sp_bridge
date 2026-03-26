-- ---------------------------------------------------------------------------
-- SPTest_clientProbe()
-- Called by client/main.lua when the server fires 'sp_bridge_test:probe'.
-- Probes all client-side sp_bridge exports and sends results to the server.
-- ---------------------------------------------------------------------------

function SPTest_clientProbe()
    local results = {}

    local function probe(name, fn)
        local ok, val = pcall(fn)
        if ok then
            results[name] = {
                ok      = true,
                valType = type(val),
                value   = (type(val) == 'table') and '[table]' or tostring(val),
            }
        else
            results[name] = { ok = false, err = tostring(val) }
        end
    end

    probe('GetPlayerData',          function() return exports.sp_bridge:GetPlayerData() end)
    probe('GetNormalizedPlayerData',function() return exports.sp_bridge:GetNormalizedPlayerData() end)
    probe('GetMoney_cash',          function() return exports.sp_bridge:GetMoney('cash') end)
    probe('GetMoney_bank',          function() return exports.sp_bridge:GetMoney('bank') end)
    probe('GetPlayerJob',           function() return exports.sp_bridge:GetPlayerJob() end)
    probe('GetCharacterId',         function() return exports.sp_bridge:GetCharacterId() end)

    TriggerServerEvent('sp_bridge_test:probeResult', results)
end
