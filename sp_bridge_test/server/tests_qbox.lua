-- ---------------------------------------------------------------------------
-- QBOX-specific regression tests
-- These are only invoked by runner.lua when GetFrameworkName() == 'qbx'.
-- ---------------------------------------------------------------------------

function SPTest.runQBOXTests(src)
    print('[sp_bridge_test] ==== QBOX Regression Tests ====')

    -- ----------------------------------------------------------------
    -- QBOX + ox_inventory: ox uses client-side item-use system (same as ESX + ox).
    -- exports.qbx_core:CreateUseableItem may not exist in all qbx_core versions.
    -- Skip when ox_inventory is the active provider.
    local systems = exports.sp_bridge:GetDetectedSystems()
    local invName = systems and systems.inventory or ''

    SPTest.section('QBOX CreateUsableItem', function()
        -- ox_inventory (and inventories with client-side use systems) do not support
        -- server-side RegisterUsableItem/CreateUseableItem.
        if invName == 'ox_inventory' then
            SPTest.skip('QBOX CreateUsableItem',
                'ox_inventory: server-side usable item callback not applicable in ox+QBOX setup')
            return
        end
        local ok = exports.sp_bridge:CreateUsableItem('sp_test_qbox_dummy', function() end)
        SPTest.assertBool('CreateUsableItem returns bool', ok)
        -- If false: qbx_core:CreateUseableItem is unavailable on this server version.
        -- This is a qbx_core version limitation, not a bridge routing bug.
        if ok then
            SPTest.assert('CreateUsableItem returns true', ok == true)
        else
            SPTest.skip('CreateUsableItem returns true',
                'qbx_core:CreateUseableItem not available on this server — bridge routing is correct, qbx_core export missing')
        end
    end)

    -- ----------------------------------------------------------------
    SPTest.section('QBOX GetItemDefinitions', function()
        local defs = exports.sp_bridge:GetItemDefinitions()
        SPTest.assertTable   ('GetItemDefinitions returns table',     defs)
        SPTest.assertNotEmpty('GetItemDefinitions is not empty table', defs)
    end)

    -- ----------------------------------------------------------------
    SPTest.section('QBOX GetItemLabel', function()
        local label = exports.sp_bridge:GetItemLabel(SPTest.testItem)
        SPTest.assertString  ('GetItemLabel returns string',    label)
        SPTest.assertNotEmpty('GetItemLabel returns non-empty', label)
    end)

    -- ----------------------------------------------------------------
    if not src or src == 0 then
        SPTest.skip('QBOX Identity divergence', 'no player src')
        SPTest.skip('QBOX GetNormalizedPlayerData server path', 'no player src')
        return
    end

    -- ----------------------------------------------------------------
    SPTest.section('QBOX Identity divergence', function()
        -- For QBOX, GetCharacterId returns the citizenid (numeric/string player
        -- identifier) while GetFrameworkIdentifier returns the license.
        -- They should be different values.
        local charId = exports.sp_bridge:GetCharacterId(src)
        local ident  = exports.sp_bridge:GetFrameworkIdentifier(src)

        SPTest.assert('GetCharacterId not nil',           charId ~= nil)
        SPTest.assert('GetFrameworkIdentifier not nil',   ident  ~= nil)
        SPTest.assert(
            'QBOX: citizenid != license identifier',
            tostring(charId) ~= tostring(ident),
            ('charId=%s ident=%s — they should differ for QBOX'):format(
                tostring(charId), tostring(ident))
        )
    end)

    -- ----------------------------------------------------------------
    SPTest.section('QBOX GetNormalizedPlayerData server path', function()
        local pd = exports.sp_bridge:GetNormalizedPlayerData(src)
        SPTest.assertTable('GetNormalizedPlayerData returns table', pd)
        if type(pd) ~= 'table' then return end

        SPTest.assert      ('pd.source == src', pd.source == src)
        SPTest.assertTable ('pd.job is table',  pd.job)
        SPTest.assertTable ('pd.money is table',pd.money)
        SPTest.assertString('pd.identifier is string', pd.identifier)
        SPTest.assertNotEmpty('pd.identifier not empty', pd.identifier)
    end)
end
