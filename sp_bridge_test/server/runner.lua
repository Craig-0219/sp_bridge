-- ---------------------------------------------------------------------------
-- SPTest.run(src)
--   src: player server id to use for player-specific tests (may be nil/0
--        when run from the server console with no connected players)
-- ---------------------------------------------------------------------------

function SPTest.run(src)
    SPTest.reset()

    -- Guard: sp_bridge must be started before we can call its exports.
    -- GetFrameworkName is a stable, side-effect-free export available on
    -- all supported versions of sp_bridge.
    local ok, fw = pcall(function()
        return exports.sp_bridge:GetFrameworkName()
    end)
    if not ok or type(fw) ~= 'string' or fw == '' then
        print('[sp_bridge_test] ERROR: sp_bridge resource is not running or GetFrameworkName failed.')
        print('[sp_bridge_test] Start sp_bridge first, then retry /sp_test.')
        if not ok then
            print('[sp_bridge_test] Detail: ' .. tostring(fw))
        end
        return
    end
    print(('[sp_bridge_test] sp_bridge active  framework = %s'):format(fw))

    SPTest.runFrameworkTests(src)
    SPTest.runInventoryTests(src)

    -- QBOX-specific tests only when the active framework is qbx.
    if fw == 'qbx' then
        SPTest.runQBOXTests(src)
    else
        print(('[sp_bridge_test] Skipping QBOX tests (framework = %s)'):format(fw))
    end

    SPTest.summary()
end
