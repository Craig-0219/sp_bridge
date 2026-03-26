-- ---------------------------------------------------------------------------
-- Inventory API tests
-- ---------------------------------------------------------------------------

function SPTest.runInventoryTests(src)
    print('[sp_bridge_test] ==== Inventory Tests ====')

    local item = SPTest.testItem

    -- ----------------------------------------------------------------
    SPTest.section('Item Definitions', function()
        local defs = exports.sp_bridge:GetItemDefinitions()
        SPTest.assertTable('GetItemDefinitions returns table', defs)

        local items = exports.sp_bridge:GetItems()
        SPTest.assertTable('GetItems returns table', items)

        local label = exports.sp_bridge:GetItemLabel(item)
        SPTest.assertString  ('GetItemLabel returns string',    label)
        SPTest.assertNotEmpty('GetItemLabel returns non-empty', label)
    end)

    -- ----------------------------------------------------------------
    if not src or src == 0 then
        SPTest.skip('GetItemCount',                   'no player src')
        SPTest.skip('HasItem variants',               'no player src')
        SPTest.skip('CanCarryItem / CanCarryItems',   'no player src')
        SPTest.skip('AddItem / RemoveItem round-trip','no player src')
        SPTest.skip('CreateUsableItem',               'no player src')
        return
    end

    -- ----------------------------------------------------------------
    SPTest.section('GetItemCount', function()
        local count = exports.sp_bridge:GetItemCount(src, item)
        SPTest.assertNumber('GetItemCount returns number', count)
        SPTest.assert('GetItemCount >= 0', count >= 0,
            ('got %s'):format(tostring(count)))
    end)

    -- ----------------------------------------------------------------
    SPTest.section('HasItem variants', function()
        -- 2-arg (source, item) — legacy no-count call
        local r2 = exports.sp_bridge:HasItem(src, item)
        SPTest.assertBool('HasItem(src, item) returns bool', r2)

        -- 3-arg with number as 3rd (new count param)
        local r3n = exports.sp_bridge:HasItem(src, item, 1)
        SPTest.assertBool('HasItem(src, item, 1) returns bool', r3n)

        -- 3-arg with table as 3rd (legacy metadata param)
        local r3t = exports.sp_bridge:HasItem(src, item, {})
        SPTest.assertBool('HasItem(src, item, {}) returns bool', r3t)

        -- 4-arg (source, item, count, metadata)
        local r4 = exports.sp_bridge:HasItem(src, item, 1, {})
        SPTest.assertBool('HasItem(src, item, 1, {}) returns bool', r4)
    end)

    -- ----------------------------------------------------------------
    SPTest.section('CanCarryItem / CanCarryItems', function()
        local canSingle = exports.sp_bridge:CanCarryItem(src, item, 1)
        SPTest.assertBool('CanCarryItem returns bool', canSingle)

        -- CanCarryItems with explicit count
        local canMulti = exports.sp_bridge:CanCarryItems(src, { { item = item, count = 1 } })
        SPTest.assertBool('CanCarryItems returns bool (explicit count)', canMulti)

        -- CanCarryItems with no count field — must default to 1, not error
        local canNoCount = exports.sp_bridge:CanCarryItems(src, { { item = item } })
        SPTest.assertBool('CanCarryItems returns bool (no count field)', canNoCount)
    end)

    -- ----------------------------------------------------------------
    SPTest.section('AddItem / RemoveItem round-trip', function()
        local canCarry = exports.sp_bridge:CanCarryItem(src, item, 1)
        if not canCarry then
            SPTest.skip('AddItem',    'CanCarryItem returned false — inventory likely full')
            SPTest.skip('RemoveItem', 'AddItem skipped')
            return
        end

        local added = exports.sp_bridge:AddItem(src, item, 1)
        SPTest.assertBool('AddItem returns bool', added)
        SPTest.assert('AddItem returned true', added == true,
            'AddItem returned false — check server console for errors')

        if added then
            local removed = exports.sp_bridge:RemoveItem(src, item, 1)
            SPTest.assertBool('RemoveItem returns bool', removed)
            SPTest.assert('RemoveItem returned true', removed == true,
                'RemoveItem returned false — item may not have been added correctly')
        else
            SPTest.skip('RemoveItem', 'AddItem failed')
        end
    end)

    -- ----------------------------------------------------------------
    SPTest.section('CreateUsableItem', function()
        -- Register a no-op usable; verifies routing works and returns true.
        local ok = exports.sp_bridge:CreateUsableItem('sp_test_dummy_item', function() end)
        SPTest.assertBool('CreateUsableItem returns bool', ok)
        SPTest.assert('CreateUsableItem returned true', ok == true)
    end)
end
