-- ---------------------------------------------------------------------------
-- /sp_test [playerServerId]
--
-- Run from the server console:
--   sp_test          — uses first connected player if any, else src-less mode
--   sp_test 3        — run against player with server id 3
--
-- Run in-game (requires ace permission `command.sp_test` when restricted=true):
--   /sp_test         — uses the calling player as test subject
--   /sp_test 3       — uses player 3 as test subject
-- ---------------------------------------------------------------------------

RegisterCommand('sp_test', function(source, args)
    local testSrc = tonumber(args[1])

    if not testSrc then
        if source ~= 0 then
            -- Called by a player in-game; use themselves.
            testSrc = source
        else
            -- Called from server console; pick first connected player.
            local players = GetPlayers()
            testSrc = players[1] and tonumber(players[1]) or nil
        end
    end

    print(('[sp_bridge_test] Starting test run (src=%s)'):format(tostring(testSrc)))
    SPTest.run(testSrc)

    -- Also trigger the lightweight client-side probe on the test player.
    if testSrc and testSrc ~= 0 then
        TriggerClientEvent('sp_bridge_test:probe', testSrc)
    end
end, SPTest.restricted)

-- Receive and print client probe results.
RegisterNetEvent('sp_bridge_test:probeResult', function(data)
    local src = source
    print(('[sp_bridge_test] Client probe results from player %d:'):format(src))
    if type(data) ~= 'table' then
        print('[sp_bridge_test]   (no data received)')
        return
    end
    for name, info in pairs(data) do
        local line
        if info.ok then
            line = ('  PASS  %s  [%s]  =  %s'):format(
                name, tostring(info.valType), tostring(info.value))
        else
            line = ('  FAIL  %s  error: %s'):format(name, tostring(info.err))
        end
        print('[sp_bridge_test] ' .. line)
    end
end)

-- Export for external callers (e.g. another resource running headless tests).
exports('RunTests', function(src)
    SPTest.run(src)
end)
