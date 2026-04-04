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

local function resolveProbeSource(source, args)
    local testSrc = tonumber(args and args[1])

    if testSrc then
        return testSrc
    end

    if source ~= 0 then
        return source
    end

    local players = GetPlayers()
    return players[1] and tonumber(players[1]) or nil
end

RegisterCommand('sp_bank_probe', function(source, args)
    local testSrc = resolveProbeSource(source, args)
    print(('[sp_bridge_test] ==== Bank Probe (src=%s) ===='):format(tostring(testSrc)))

    if not testSrc or testSrc == 0 then
        print('[sp_bridge_test] No player source available for bank probe.')
        return
    end

    local bridgeBank = exports.sp_bridge:GetPlayerBankBalance(testSrc)
    local charId = exports.sp_bridge:GetCharacterId(testSrc)
    local ident = exports.sp_bridge:GetFrameworkIdentifier(testSrc)
    local normalized = exports.sp_bridge:GetNormalizedPlayerData(testSrc)

    local player = nil
    local okPlayer, playerResult = pcall(function()
        return exports.qbx_core:GetPlayer(testSrc)
    end)
    if okPlayer then
        player = playerResult
    end

    local liveDataBank = nil
    local liveFuncBank = nil

    if player then
        local okLiveData, liveDataResult = pcall(function()
            return player.PlayerData and player.PlayerData.money and player.PlayerData.money.bank
        end)
        if okLiveData then
            liveDataBank = liveDataResult
        end

        local okLiveFunc, liveFuncResult = pcall(function()
            return player.Functions and player.Functions.GetMoney and player.Functions.GetMoney('bank')
        end)
        if okLiveFunc then
            liveFuncBank = liveFuncResult
        end
    end

    local dbBank = nil
    if GetResourceState('oxmysql') == 'started' and type(MySQL) == 'table' and MySQL.single and MySQL.single.await then
        local row = MySQL.single.await('SELECT money FROM players WHERE citizenid = ? LIMIT 1', { charId })
        if row and row.money then
            local decoded = type(row.money) == 'string' and json.decode(row.money) or row.money
            if type(decoded) == 'table' then
                dbBank = decoded.bank
            end
        end
    end

    print(('[sp_bridge_test] player src         = %s'):format(tostring(testSrc)))
    print(('[sp_bridge_test] citizenid          = %s'):format(tostring(charId)))
    print(('[sp_bridge_test] framework ident    = %s'):format(tostring(ident)))
    print(('[sp_bridge_test] sp_bridge bank     = %s'):format(tostring(bridgeBank)))
    print(('[sp_bridge_test] live PlayerData    = %s'):format(tostring(liveDataBank)))
    print(('[sp_bridge_test] live GetMoney()    = %s'):format(tostring(liveFuncBank)))
    print(('[sp_bridge_test] normalized.bank    = %s'):format(tostring(normalized and normalized.money and normalized.money.bank)))
    print(('[sp_bridge_test] players.money.bank = %s'):format(tostring(dbBank)))
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
