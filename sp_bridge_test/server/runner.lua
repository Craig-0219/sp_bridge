-- ---------------------------------------------------------------------------
-- SPTest.run(src)
--   src: player server id to use for player-specific tests (may be nil/0
--        when run from the server console with no connected players)
-- ---------------------------------------------------------------------------

function SPTest.run(src)
    SPTest.reset()

    -- Guard: sp_bridge must be started before we can call its exports.
    local ok, ver = pcall(function()
        return exports.sp_bridge:GetBridgeVersion()
    end)
    if not ok then
        print('[sp_bridge_test] ERROR: sp_bridge resource is not running or GetBridgeVersion failed.')
        print('[sp_bridge_test] Start sp_bridge first, then retry /sp_test.')
        return
    end
    print(('[sp_bridge_test] sp_bridge version: %s'):format(tostring(ver)))

    SPTest.runFrameworkTests(src)
    SPTest.runInventoryTests(src)

    -- QBOX-specific tests only when the active framework is qbx.
    local fw = exports.sp_bridge:GetFrameworkName()
    if fw == 'qbx' then
        SPTest.runQBOXTests(src)
    else
        print(('[sp_bridge_test] Skipping QBOX tests (framework = %s)'):format(tostring(fw)))
    end

    SPTest.summary()
end
