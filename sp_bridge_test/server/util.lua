-- ---------------------------------------------------------------------------
-- SPTest utility layer
-- All assert helpers record results without throwing; use section() to
-- isolate failures so one broken test block can't abort the whole run.
-- ---------------------------------------------------------------------------

local _results

function SPTest.reset()
    _results = { passed = 0, failed = 0, skipped = 0, errors = {} }
end

-- Call reset immediately so the table exists even before SPTest.run().
SPTest.reset()

-- Internal: record one result line.
local function _pass(name)
    _results.passed = _results.passed + 1
    if SPTest.verbose then
        print(('[sp_bridge_test] PASS  %s'):format(name))
    end
end

local function _fail(name, reason)
    _results.failed = _results.failed + 1
    local msg = ('[sp_bridge_test] FAIL  %s — %s'):format(name, tostring(reason))
    print(msg)
    table.insert(_results.errors, msg)
end

-- ---------------------------------------------------------------------------
-- Public assert helpers
-- ---------------------------------------------------------------------------

function SPTest.assert(name, condition, failReason)
    if condition then
        _pass(name)
    else
        _fail(name, failReason or 'assertion failed')
    end
end

function SPTest.assertType(name, value, expected)
    if type(value) == expected then
        _pass(name)
    else
        _fail(name, ('expected type %s, got %s (%s)'):format(expected, type(value), tostring(value)))
    end
end

function SPTest.assertNumber(name, value)
    SPTest.assertType(name, value, 'number')
end

function SPTest.assertBool(name, value)
    SPTest.assertType(name, value, 'boolean')
end

function SPTest.assertTable(name, value)
    SPTest.assertType(name, value, 'table')
end

function SPTest.assertString(name, value)
    SPTest.assertType(name, value, 'string')
end

function SPTest.assertNotEmpty(name, value)
    if type(value) == 'string' and value ~= '' then
        _pass(name)
    elseif type(value) == 'table' and next(value) ~= nil then
        _pass(name)
    else
        _fail(name, ('expected non-empty string/table, got %s (%s)'):format(type(value), tostring(value)))
    end
end

function SPTest.skip(name, reason)
    _results.skipped = _results.skipped + 1
    print(('[sp_bridge_test] SKIP  %s — %s'):format(name, tostring(reason or 'skipped')))
end

-- Wrap a test block in pcall so an unexpected Lua error is caught and
-- recorded as a failure rather than aborting the whole test run.
function SPTest.section(name, fn)
    print(('[sp_bridge_test] ---- %s'):format(name))
    local ok, err = pcall(fn)
    if not ok then
        _fail(name .. ' [section error]', err)
    end
end

-- Print final totals and list every failure.
function SPTest.summary()
    print(('[sp_bridge_test] ============================================'))
    print(('[sp_bridge_test] Results: %d passed, %d failed, %d skipped'):format(
        _results.passed, _results.failed, _results.skipped))
    if #_results.errors > 0 then
        print('[sp_bridge_test] Failures:')
        for _, msg in ipairs(_results.errors) do
            print('  ' .. msg)
        end
    end
    print(('[sp_bridge_test] ============================================'))
end
