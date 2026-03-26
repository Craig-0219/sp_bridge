# sp_bridge API Reference

## Schemas

### NormalizedJob
```lua
{
    name   = 'police',           -- string
    label  = 'Police Department', -- string
    onduty = true,                -- boolean (ESX: always true)
    isBoss = false,               -- boolean
    grade  = {
        level  = 2,               -- number
        name   = 'officer',       -- string
        label  = 'Officer',       -- string
        salary = 500,             -- number|nil
    }
}
```

### NormalizedMoney
```lua
{
    cash  = 5000,   -- number (always present)
    bank  = 25000,  -- number (always present)
    black = nil,    -- number|nil (nil when 0 or unsupported)
}
```

### NormalizedGang
```lua
-- nil when player has no gang or gang.name == 'none'
{
    name   = 'ballas',   -- string
    label  = 'Ballas',   -- string
    isBoss = false,       -- boolean
    grade  = { level = 0, name = 'recruit', label = 'Recruit' }
}
```

### NormalizedPlayerData
```lua
{
    source      = 1,              -- number|nil (server only)
    identifier  = 'license:xxx',  -- string|nil (platform ID)
    characterId = 'CHAR_abc',     -- string|nil (ESX: same as identifier)
    name        = 'John Doe',     -- string|nil
    job         = NormalizedJob,
    gang        = NormalizedGang, -- nil for ESX
    money       = NormalizedMoney,
    metadata    = {},             -- table|nil (QB/QBOX only)
}
```

### NormalizedItemDef
```lua
{
    name        = 'bread',    -- string
    label       = 'Bread',    -- string
    weight      = 100,        -- number
    description = nil,        -- string|nil
    image       = nil,        -- string|nil
    stack       = nil,        -- boolean|nil
    unique      = nil,        -- boolean|nil
}
```

---

## Framework Exports (Server)

| Export | Params | Returns | Notes |
|---|---|---|---|
| `GetFrameworkName(mode?)` | `mode`: `'resource'` for raw | `string\|nil` | `'esx'`/`'qbcore'`/`'qbx'` |
| `GetDetectedSystems()` | — | `table` | framework, inventory, target, etc. |
| `GetPlayer(source)` | `source`: player id | `Player\|nil` | raw framework Player object |
| `GetPlayerData(source)` | `source` | raw table | **soft-deprecated** — use GetNormalizedPlayerData |
| `GetRawPlayerData(source)` | `source` | raw table | explicit alias for GetPlayerData |
| `GetNormalizedPlayerData(source)` | `source` | `NormalizedPlayerData` | **canonical** |
| `GetPlayerJob(source)` | `source` | `NormalizedJob` | **breaking**: was raw pre-Sprint 2 |
| `GetRawPlayerJob(source)` | `source` | raw framework job | ESX/QB/QBOX native schema |
| `GetNormalizedJob(source)` | `source` | `NormalizedJob` | canonical; same as GetPlayerJob |
| `GetCitizenId(source)` | `source` | `string\|nil` | legacy alias for GetCharacterId |
| `GetCharacterId(source)` | `source` | `string\|nil` | ESX: identifier; QB/QBOX: citizenid |
| `GetFrameworkIdentifier(source)` | `source` | `string\|nil` | platform license:xxx |
| `GetMoney(source, moneyType)` | `source`, `'cash'\|'bank'\|...` | `number` | |
| `GetNormalizedMoney(source)` | `source` | `NormalizedMoney` | |
| `AddMoney(source, type, amount, reason?)` | | `boolean` | |
| `RemoveMoney(source, type, amount, reason?)` | | `boolean` | |
| `SetMoney(source, type, amount)` | | `boolean` | |
| `GetPlayerName(source)` | `source` | `string\|nil` | |
| `GetPlayerByCitizenId(cid)` | `cid`: string | `Player\|nil` | |
| `GetPlayers()` | — | `table` | |
| `GetOnlinePlayers()` | — | `table` | |

## Framework Exports (Client)

| Export | Params | Returns | Notes |
|---|---|---|---|
| `GetPlayerData()` | — | raw table | soft-deprecated |
| `GetRawPlayerData()` | — | raw table | alias |
| `GetNormalizedPlayerData()` | — | `NormalizedPlayerData` | canonical |
| `GetPlayerJob()` | — | `NormalizedJob` | breaking |
| `GetRawPlayerJob()` | — | raw framework job | |
| `GetNormalizedJob()` | — | `NormalizedJob` | canonical |
| `GetCitizenId()` | — | `string\|nil` | legacy alias |
| `GetCharacterId()` | — | `string\|nil` | |
| `GetFrameworkIdentifier()` | — | `string\|nil` | |
| `GetMoney(moneyType)` | `'cash'\|'bank'\|...` | `number` | |
| `GetNormalizedMoney()` | — | `NormalizedMoney` | |
| `GetPlayerName()` | — | `string\|nil` | |

---

## Inventory Exports (Server)

| Export | Params | Returns | Notes |
|---|---|---|---|
| `CreateUsableItem(item, cb)` | `item`: string, `cb`: function | `boolean` | QBOX: via exports.qbx_core |
| `GetItemCount(src, item, meta?)` | | `number` | QB/QS: meta ignored |
| `HasItem(src, item, count?, meta?)` | count default 1 | `boolean` | backward-compat 3-arg |
| `AddItem(src, item, count, meta?, slot?)` | | `boolean` | |
| `RemoveItem(src, item, count, meta?, slot?)` | | `boolean` | meta not dropped |
| `CanCarryItem(src, item, count, meta?)` | | `boolean` | no-provider: true |
| `CanCarryItems(src, items)` | items: `{name,count?,metadata?}[]` | `boolean` | count defaults to 1 |
| `GetItemLabel(item)` | | `string` | fallback: item name |
| `GetItemDefinitions()` | — | `table<string, NormalizedItemDef>` | |
| `GetItems()` | — | same | alias |
| `GetAllItems()` | — | same | alias |
| `GetItemList()` | — | same | alias |
| `Items(item?)` | optional item name | `NormalizedItemDef\|table` | single or all |
| `ItemDeployer(items, cb)` | items: string[] | `number` | count of registered items |

---

## Inventory Provider Limitations

### Per-provider metadata support

| Capability | OX | QB | QS |
|---|---|---|---|
| AddItem metadata | Yes | Yes (5th param) | Yes (5th param) |
| RemoveItem metadata | Yes | Yes (4th param) | Yes (5th param) |
| GetItemCount metadata filter | Yes | **No** | **No** |
| HasItem metadata filter | Yes | **No** | **No** |
| CanCarryItem metadata | Varies by version | **No** | Yes |
| AddItem slot | Not standard | Yes (4th param) | Yes (4th param) |
| RemoveItem slot | Yes (5th param) | Yes (5th param) | Yes (4th param) |

### createUsableItem routing

`createUsableItem` is fundamentally a framework-level operation, not an
inventory operation. The inventory provider handles it internally by
dispatching based on `sp.framework`:

| Framework | Method |
|---|---|
| ESX | `CoreObject.RegisterUsableItem(item, cb)` |
| QBCore | `CoreObject.Functions.CreateUseableItem(item, cb)` |
| QBOX | `exports.qbx_core:CreateUseableItem(item, cb)` |
| OX (any framework) | `exports.ox_inventory:RegisterUsableItem(item, cb)` first, then framework fallback |

### getItemLabel / getItemDefinitions routing

| Inventory + Framework | Source |
|---|---|
| OX (any) | `exports.ox_inventory:Items()` |
| QB + QBCore | `CoreObject.Shared.Items` |
| QB + QBOX | `exports.qbx_core:GetItems()` |
| QS + QBCore | `CoreObject.Shared.Items` |
| QS + QBOX | `exports.qbx_core:GetItems()` |

### CanCarryItem fallback policy

| Scenario | Return | Rationale |
|---|---|---|
| No provider registered | `true` | Permissive dev fallback; prevents blocking during startup |
| Provider exists, pcall fails | `false` | Conservative; prevents item dupe on inventory crash |
| Provider exists, returns value | value | Normal operation |
