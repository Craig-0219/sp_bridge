-- ---------------------------------------------------------------------------
-- Banking API tests
-- Covers: GetPlayerBankBalance, AddPlayerBankMoney, RemovePlayerBankMoney,
--         GetSocietyBalance, AddSocietyMoney, RemoveSocietyMoney
--
-- Designed to work regardless of which bank provider is active:
--   - framework : society calls expected to log society_unsupported and return 0/false
--   - renewed   : full player + society coverage
--   - qb / okok : player via framework layer, society via external resource
-- ---------------------------------------------------------------------------

function SPTest.runBankingTests(src)
    print('[sp_bridge_test] ==== Banking Tests ====')

    -- ----------------------------------------------------------------
    -- 1. Provider introspection
    -- ----------------------------------------------------------------
    SPTest.section('Bank provider registered', function()
        local pname = exports.sp_bridge:GetBankProviderName()
        SPTest.assertString('GetBankProviderName returns string', pname)
        SPTest.assertNotEmpty('GetBankProviderName not empty', pname)
        print(('[sp_bridge_test]   active bank provider = %s'):format(tostring(pname)))
    end)

    -- ----------------------------------------------------------------
    -- 2. Player bank — no src needed (balance query is player-independent)
    -- ----------------------------------------------------------------
    if not src or src == 0 then
        SPTest.skip('Player bank balance',          'no player src')
        SPTest.skip('AddPlayerBankMoney',           'no player src')
        SPTest.skip('RemovePlayerBankMoney',        'no player src')
        SPTest.skip('Player bank round-trip',       'no player src')
    else
        SPTest.section('GetPlayerBankBalance', function()
            local bal = exports.sp_bridge:GetPlayerBankBalance(src)
            SPTest.assertNumber('GetPlayerBankBalance returns number', bal)
            SPTest.assert('GetPlayerBankBalance >= 0', bal >= 0,
                ('got %s'):format(tostring(bal)))
        end)

        SPTest.section('AddPlayerBankMoney / RemovePlayerBankMoney round-trip', function()
            local testAmount = 1  -- smallest meaningful unit

            local added = exports.sp_bridge:AddPlayerBankMoney(src, testAmount, 'sp_bridge_test')
            SPTest.assertBool('AddPlayerBankMoney returns bool', added)

            if added then
                local removed = exports.sp_bridge:RemovePlayerBankMoney(src, testAmount, 'sp_bridge_test')
                SPTest.assertBool('RemovePlayerBankMoney returns bool', removed)
                SPTest.assert('RemovePlayerBankMoney returned true', removed == true,
                    'may indicate insufficient bank balance or provider error')
            else
                SPTest.skip('RemovePlayerBankMoney', 'AddPlayerBankMoney failed')
            end
        end)

        -- Edge: amount validation (0 and negative must return false without crashing)
        SPTest.section('AddPlayerBankMoney invalid amount guard', function()
            local r0 = exports.sp_bridge:AddPlayerBankMoney(src, 0)
            SPTest.assertBool('AddPlayerBankMoney(0) returns bool', r0)
            SPTest.assert('AddPlayerBankMoney(0) == false (guard)', r0 == false)

            local rn = exports.sp_bridge:AddPlayerBankMoney(src, -100)
            SPTest.assertBool('AddPlayerBankMoney(-100) returns bool', rn)
            SPTest.assert('AddPlayerBankMoney(-100) == false (guard)', rn == false)
        end)
    end

    -- ----------------------------------------------------------------
    -- 3. Society balance — no src required
    -- ----------------------------------------------------------------
    SPTest.section('GetSocietyBalance return type', function()
        -- Use a plausible society id; actual value depends on server config.
        -- We only validate the return CONTRACT (number), not the value.
        local bal = exports.sp_bridge:GetSocietyBalance(SPTest.testSocietyAccount)
        SPTest.assertNumber('GetSocietyBalance returns number', bal)
        SPTest.assert('GetSocietyBalance >= 0', bal >= 0,
            ('got %s'):format(tostring(bal)))
        print(('[sp_bridge_test]   society balance (%s) = %s'):format(
            SPTest.testSocietyAccount, tostring(bal)))
    end)

    -- ----------------------------------------------------------------
    -- 4. framework provider: society calls MUST return 0/false (unsupported)
    -- The capability log will show society=false at startup; here we verify
    -- the runtime contract holds.
    -- ----------------------------------------------------------------
    SPTest.section('Framework provider society_unsupported contract', function()
        local pname = exports.sp_bridge:GetBankProviderName()
        if pname ~= 'framework' then
            SPTest.skip('society_unsupported contract',
                ('provider=%s; only checked for framework'):format(pname))
            return
        end

        local bal = exports.sp_bridge:GetSocietyBalance('sp_test_nonexistent_society')
        SPTest.assertNumber('GetSocietyBalance returns number (framework)', bal)
        SPTest.assert('GetSocietyBalance == 0 when unsupported', bal == 0,
            ('framework society should be 0, got %s'):format(tostring(bal)))

        local added = exports.sp_bridge:AddSocietyMoney('sp_test_nonexistent_society', 1)
        SPTest.assertBool('AddSocietyMoney returns bool (framework)', added)
        SPTest.assert('AddSocietyMoney == false when unsupported', added == false,
            'framework society should always return false')

        local removed = exports.sp_bridge:RemoveSocietyMoney('sp_test_nonexistent_society', 1)
        SPTest.assertBool('RemoveSocietyMoney returns bool (framework)', removed)
        SPTest.assert('RemoveSocietyMoney == false when unsupported', removed == false,
            'framework society should always return false')
    end)

    -- ----------------------------------------------------------------
    -- 5. Society mutations — only when provider supports society
    -- ----------------------------------------------------------------
    SPTest.section('Society mutation contract (non-framework providers)', function()
        local pname = exports.sp_bridge:GetBankProviderName()
        if pname == 'framework' then
            SPTest.skip('AddSocietyMoney / RemoveSocietyMoney',
                'framework provider does not support society accounts')
            return
        end

        -- Contract only: verify return type. We do NOT do a real round-trip
        -- here because we cannot guarantee the test society account exists.
        local added = exports.sp_bridge:AddSocietyMoney(SPTest.testSocietyAccount, 1, 'sp_bridge_test')
        SPTest.assertBool('AddSocietyMoney returns bool', added)

        local removed = exports.sp_bridge:RemoveSocietyMoney(SPTest.testSocietyAccount, 1, 'sp_bridge_test')
        SPTest.assertBool('RemoveSocietyMoney returns bool', removed)
    end)

    -- ----------------------------------------------------------------
    -- 6. Edge: empty / nil accountId guard
    -- ----------------------------------------------------------------
    SPTest.section('GetSocietyBalance empty accountId guard', function()
        local bal = exports.sp_bridge:GetSocietyBalance('')
        SPTest.assertNumber('GetSocietyBalance(\'\') returns number', bal)
        SPTest.assert('GetSocietyBalance(\'\') == 0 (guard)', bal == 0)
    end)
end
