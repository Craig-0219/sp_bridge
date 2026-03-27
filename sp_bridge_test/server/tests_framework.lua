-- ---------------------------------------------------------------------------
-- Framework detection + player data tests
-- ---------------------------------------------------------------------------

function SPTest.runFrameworkTests(src)
    print('[sp_bridge_test] ==== Framework Tests ====')

    -- ----------------------------------------------------------------
    SPTest.section('Framework Detection', function()
        local fw = exports.sp_bridge:GetFrameworkName()
        SPTest.assertString('GetFrameworkName returns string', fw)
        SPTest.assert(
            'GetFrameworkName is esx/qbcore/qbx',
            fw == 'esx' or fw == 'qbcore' or fw == 'qbx',
            ('unexpected value: %s'):format(tostring(fw))
        )

        local systems = exports.sp_bridge:GetDetectedSystems()
        SPTest.assertTable('GetDetectedSystems returns table', systems)
    end)

    -- ----------------------------------------------------------------
    if not src or src == 0 then
        SPTest.skip('Player Job - NormalizedJob',     'no player src')
        SPTest.skip('Player Job - GetRawPlayerJob',   'no player src')
        SPTest.skip('Player Identity',                'no player src')
        SPTest.skip('Player Money',                   'no player src')
        SPTest.skip('NormalizedPlayerData',           'no player src')
        return
    end

    -- ----------------------------------------------------------------
    SPTest.section('Player Job - NormalizedJob', function()
        local job = exports.sp_bridge:GetPlayerJob(src)
        SPTest.assertTable('GetPlayerJob returns table', job)
        if type(job) ~= 'table' then return end

        -- Top-level scalar fields
        SPTest.assertString('job.name exists',  job.name)
        SPTest.assertString('job.label exists', job.label)
        SPTest.assertBool  ('job.isBoss exists', job.isBoss)

        -- job.grade must be a table (not a raw number)
        SPTest.assertTable('job.grade is table', job.grade)
        if type(job.grade) == 'table' then
            SPTest.assertNumber('job.grade.level is number', job.grade.level)
            SPTest.assertString('job.grade.label is string', job.grade.label)
        end

        -- Regression: old flat fields must NOT leak into the normalized schema.
        SPTest.assert('job.isboss is nil (stale field absent)',
            job.isboss == nil,
            'stale lowercase job.isboss leaked into normalized job')
        SPTest.assert('job.grade_label is nil (stale field absent)',
            job.grade_label == nil,
            'stale job.grade_label leaked into normalized job')
        SPTest.assert('job.grade_name is nil (stale field absent)',
            job.grade_name == nil,
            'stale job.grade_name leaked into normalized job')
    end)

    -- ----------------------------------------------------------------
    SPTest.section('Player Job - GetRawPlayerJob', function()
        local raw = exports.sp_bridge:GetRawPlayerJob(src)
        SPTest.assertTable('GetRawPlayerJob returns table', raw)
        if type(raw) ~= 'table' then return end
        SPTest.assertString('raw job has name', raw.name)
    end)

    -- ----------------------------------------------------------------
    SPTest.section('Player Identity', function()
        local charId = exports.sp_bridge:GetCharacterId(src)
        SPTest.assert('GetCharacterId not nil', charId ~= nil)

        local citizenId = exports.sp_bridge:GetCitizenId(src)
        SPTest.assert('GetCitizenId not nil', citizenId ~= nil)

        -- For most frameworks these are the same value.
        SPTest.assert(
            'GetCharacterId == GetCitizenId',
            tostring(charId) == tostring(citizenId),
            ('charId=%s citizenId=%s'):format(tostring(charId), tostring(citizenId))
        )

        local ident = exports.sp_bridge:GetFrameworkIdentifier(src)
        SPTest.assertString  ('GetFrameworkIdentifier returns string', ident)
        SPTest.assertNotEmpty('GetFrameworkIdentifier not empty', ident)
    end)

    -- ----------------------------------------------------------------
    SPTest.section('Player Money', function()
        local cash = exports.sp_bridge:GetMoney(src, 'cash')
        SPTest.assertNumber('GetMoney(cash) returns number', cash)
        SPTest.assert('GetMoney(cash) >= 0', cash >= 0, ('got %s'):format(tostring(cash)))

        local nm = exports.sp_bridge:GetNormalizedMoney(src)
        SPTest.assertTable('GetNormalizedMoney returns table', nm)
        if type(nm) == 'table' then
            SPTest.assertNumber('nm.cash is number', nm.cash)
            SPTest.assertNumber('nm.bank is number', nm.bank)
        end
    end)

    -- ----------------------------------------------------------------
    SPTest.section('NormalizedPlayerData', function()
        local pd = exports.sp_bridge:GetNormalizedPlayerData(src)
        SPTest.assertTable('GetNormalizedPlayerData returns table', pd)
        if type(pd) ~= 'table' then return end

        SPTest.assert      ('pd.source == src', pd.source == src,
            ('expected %s got %s'):format(src, tostring(pd.source)))
        SPTest.assertTable ('pd.job is table',   pd.job)
        SPTest.assertTable ('pd.money is table', pd.money)
        SPTest.assert      ('pd.identifier not nil', pd.identifier ~= nil)
    end)
end
