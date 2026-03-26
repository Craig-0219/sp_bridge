# sp_bridge Smoke Tests

Minimal verification checklist after deploying the refactored sp_bridge.
Run these on a server with at least one connected player.

---

## Prerequisites

```
/restart sp_bridge
```

Check server console for:
- `[provider] ESX server provider registered` (or QBCore/QBOX)
- `[provider] ox_inventory server provider registered` (or qb-inventory/qs-inventory)

If neither provider message appears, check `config.lua` and `modules/init.lua` detection.

---

## Framework Smoke Tests (Server Console)

```lua
-- Replace `src` with a valid player source id
local src = 1

-- 1. Framework detection
local fw = exports.sp_bridge:GetFrameworkName()
assert(fw == 'esx' or fw == 'qbcore' or fw == 'qbx', 'Framework not detected')

-- 2. Player job (NormalizedJob)
local job = exports.sp_bridge:GetPlayerJob(src)
assert(type(job) == 'table',               'GetPlayerJob returned non-table')
assert(type(job.name) == 'string',          'job.name missing')
assert(type(job.isBoss) == 'boolean',       'job.isBoss missing or wrong type')
assert(type(job.grade) == 'table',          'job.grade missing')
assert(type(job.grade.level) == 'number',   'job.grade.level missing')

-- 3. Raw player job
local raw = exports.sp_bridge:GetRawPlayerJob(src)
assert(type(raw) == 'table', 'GetRawPlayerJob returned non-table')

-- 4. Character ID
local cid = exports.sp_bridge:GetCharacterId(src)
assert(type(cid) == 'string' and cid ~= '', 'GetCharacterId returned empty')

-- 5. Framework identifier (license)
local lic = exports.sp_bridge:GetFrameworkIdentifier(src)
assert(type(lic) == 'string' and lic ~= '', 'GetFrameworkIdentifier returned empty')

-- 6. Money
local cash = exports.sp_bridge:GetMoney(src, 'cash')
assert(type(cash) == 'number', 'GetMoney did not return number')

local nm = exports.sp_bridge:GetNormalizedMoney(src)
assert(type(nm) == 'table',             'GetNormalizedMoney non-table')
assert(type(nm.cash) == 'number',        'nm.cash not number')
assert(type(nm.bank) == 'number',        'nm.bank not number')

-- 7. Normalized player data
local pd = exports.sp_bridge:GetNormalizedPlayerData(src)
assert(type(pd) == 'table',              'GetNormalizedPlayerData non-table')
assert(pd.source == src,                  'pd.source mismatch')
assert(type(pd.job) == 'table',           'pd.job missing')
assert(type(pd.money) == 'table',         'pd.money missing')

print('[smoke] Framework tests PASSED')
```

---

## Inventory Smoke Tests (Server Console)

```lua
local src = 1
local testItem = 'bread'  -- use any item that exists in your item definitions

-- 1. Item definitions (QBOX critical path)
local defs = exports.sp_bridge:GetItemDefinitions()
assert(type(defs) == 'table', 'GetItemDefinitions non-table')
-- Optional: check a known item exists
-- assert(defs[testItem] ~= nil, testItem .. ' not in definitions')

-- 2. Item label
local label = exports.sp_bridge:GetItemLabel(testItem)
assert(type(label) == 'string' and label ~= '', 'GetItemLabel empty')

-- 3. GetItemCount
local count = exports.sp_bridge:GetItemCount(src, testItem)
assert(type(count) == 'number', 'GetItemCount did not return number')

-- 4. HasItem (2-arg, old style)
local has = exports.sp_bridge:HasItem(src, testItem)
assert(type(has) == 'boolean', 'HasItem 2-arg did not return boolean')

-- 5. HasItem (3-arg new: with count)
local has2 = exports.sp_bridge:HasItem(src, testItem, 999)
assert(type(has2) == 'boolean', 'HasItem 3-arg-count did not return boolean')
assert(has2 == false, 'HasItem 999 should be false for most items')

-- 6. HasItem (3-arg old: with metadata table)
local has3 = exports.sp_bridge:HasItem(src, testItem, { serial = 'test' })
assert(type(has3) == 'boolean', 'HasItem 3-arg-meta did not return boolean')

-- 7. CanCarryItem
local carry = exports.sp_bridge:CanCarryItem(src, testItem, 1)
assert(type(carry) == 'boolean', 'CanCarryItem did not return boolean')

-- 8. CanCarryItems (bulk, count defaults to 1)
local carryBulk = exports.sp_bridge:CanCarryItems(src, {
    { name = testItem },
    { name = testItem, count = 2 },
})
assert(type(carryBulk) == 'boolean', 'CanCarryItems did not return boolean')

-- 9. AddItem + RemoveItem round-trip (only if CanCarryItem is true)
if carry then
    local added = exports.sp_bridge:AddItem(src, testItem, 1)
    assert(type(added) == 'boolean', 'AddItem did not return boolean')
    if added then
        local removed = exports.sp_bridge:RemoveItem(src, testItem, 1)
        assert(type(removed) == 'boolean', 'RemoveItem did not return boolean')
    end
end

-- 10. CreateUsableItem
local created = exports.sp_bridge:CreateUsableItem('sp_bridge_test_item', function(src)
    print('[smoke] usable item callback fired for ' .. src)
end)
assert(type(created) == 'boolean', 'CreateUsableItem did not return boolean')

print('[smoke] Inventory tests PASSED')
```

---

## Quick QBOX-specific Checks

These verify the critical QBOX code paths that were broken before refactoring:

```lua
local src = 1

-- QBOX client getPlayerData (run from client console or via TriggerClientEvent)
-- exports.sp_bridge:GetPlayerData() should return table, not nil

-- QBOX createUsableItem should return true (not false)
local ok = exports.sp_bridge:CreateUsableItem('sp_test', function() end)
assert(ok == true, 'QBOX CreateUsableItem failed (CoreObject path bug?)')

-- QBOX GetItemDefinitions should return non-empty table
local items = exports.sp_bridge:GetItemDefinitions()
assert(next(items) ~= nil, 'QBOX GetItemDefinitions returned empty (CoreObject path bug?)')

-- QBOX GetItemLabel should not always return raw item name
local label = exports.sp_bridge:GetItemLabel('phone')
-- If phone exists in qbx_core items, label should be the display name
print('[smoke] QBOX label for phone: ' .. tostring(label))

print('[smoke] QBOX-specific tests PASSED')
```

---

## Expected Console Output After /restart

```
[sp_bridge] [info] [provider] ESX server provider registered      -- or QBCore/QBOX
[sp_bridge] [info] [provider] ESX client provider registered       -- or QBCore/QBOX
[sp_bridge] [info] [provider] ox_inventory server provider registered  -- or qb-inventory/qs-inventory
```

If you see ZERO provider messages, the auto-detection in `modules/init.lua`
likely failed to set `sp.framework` or `sp.inventory` before provider files loaded.
Check `config.lua` → `Config.Framework` and `Config.Inventory`.
