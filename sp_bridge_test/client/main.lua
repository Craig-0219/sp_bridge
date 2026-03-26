-- ---------------------------------------------------------------------------
-- Client entry point for sp_bridge_test
-- Listens for the server-triggered probe event and calls SPTest_clientProbe().
-- ---------------------------------------------------------------------------

RegisterNetEvent('sp_bridge_test:probe', function()
    SPTest_clientProbe()
end)
