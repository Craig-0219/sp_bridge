# sp_bridge Migration Guide

This document covers breaking changes, new APIs, and migration steps
for the refactored sp_bridge (Sprint 1–6).

---

## Breaking Changes

### 1. `GetPlayerJob` returns NormalizedJob (Sprint 2)

**Before:**
```lua
local job = exports.sp_bridge:GetPlayerJob(source)
-- ESX:  { name='police', grade=0, grade_name='officer', grade_label='Officer', grade_salary=500 }
-- QB:   { name='police', isboss=false, onduty=true, grade={ level=0, name='officer', label='Officer', payment=500 } }
```

**After:**
```lua
local job = exports.sp_bridge:GetPlayerJob(source)
-- ALL frameworks:
-- { name='police', label='Police', onduty=true, isBoss=false,
--   grade={ level=0, name='officer', label='Officer', salary=500 } }
```

**Migration:**
```lua
-- OLD (QB-specific)          -- NEW (cross-framework)
job.isboss                    job.isBoss
job.grade.payment             job.grade.salary
job.grade_name    (ESX)       job.grade.name
job.grade_label   (ESX)       job.grade.label
job.grade_salary  (ESX)       job.grade.salary
```

**Need raw job?** Use `GetRawPlayerJob(source)` — returns the framework-native table.

---

### 2. `Config.Framework` default changed (Sprint 1)

**Before:** `Config.Framework = 'es_extended'`
**After:** `Config.Framework = 'auto-detect'`

Impact: QB/QBOX servers that relied on the old default (without setting config)
now auto-detect correctly instead of being forced to ESX.

---

### 3. ESX + OX manual money sync removed (Sprint 1)

The `addMoney` / `removeMoney` ESX+OX branch that manually synced
`ox_inventory` cash with ESX account memory has been removed.
ESX's own `Player.addMoney()` / `Player.addAccountMoney()` now handles
all accounting. This eliminates the double-money risk.

---

## New APIs (non-breaking)

| Export | Side | Returns | Added |
|---|---|---|---|
| `GetRawPlayerJob` | server + client | raw framework job table | Sprint 3 |
| `GetNormalizedJob` | server + client | NormalizedJob | Sprint 1 |
| `GetNormalizedMoney` | server + client | NormalizedMoney | Sprint 1 |
| `GetNormalizedPlayerData` | server + client | NormalizedPlayerData | Sprint 1 |
| `GetCharacterId` | server + client | citizenid or identifier | Sprint 1 |
| `GetFrameworkIdentifier` | server + client | platform license ID | Sprint 3 |
| `GetRawPlayerData` | server + client | alias for GetPlayerData | Sprint 3 |

---

## Soft-deprecated APIs

| Export | Replacement | Notes |
|---|---|---|
| `GetPlayerData` | `GetNormalizedPlayerData` | Raw schema varies per framework; kept for compat |
| `GetCitizenId` | `GetCharacterId` | Same behavior, legacy name kept |

These exports still work and will not be removed in the near term.
`GetRawPlayerData` is the explicit raw-intent alias.

---

## Inventory Changes (Sprint 5–6)

### Metadata no longer silently dropped

**QB `RemoveItem`:** previously hardcoded `nil` for metadata (4th param).
Now passes caller-provided metadata through to `qb-inventory:RemoveItem`.

### `HasItem` signature extended

Old: `HasItem(source, item, metadata?)`
New: `HasItem(source, item, count?, metadata?)`

Backward-compatible: if 3rd arg is not a number, treated as legacy metadata.

### `AddItem` / `RemoveItem` gain `slot` parameter

Old: `AddItem(source, item, count, metadata)`
New: `AddItem(source, item, count, metadata, slot)`

Backward-compatible: slot is optional, defaults to nil.

### `CanCarryItem` no-provider fallback

When no inventory provider is registered (e.g. during startup or standalone dev):
- `CanCarryItem` returns `true` (permissive)
- `CanCarryItems` returns `true` (permissive)

When provider IS registered but the underlying export errors:
- Returns `false` (conservative, prevents item duplication)

---

## QBOX Fixes Summary

| Function | Old bug | Fix |
|---|---|---|
| `createUsableItem` | `type(CoreObject)=='table'` false for QBOX string | QBOX branch uses `exports.qbx_core:CreateUseableItem` |
| `getPlayerData` (client) | `CoreObject.Functions.GetPlayerData()` on string | QBOX branch uses `exports.qbx_core:GetPlayerData()` |
| `getItemLabel` | `CoreObject.Shared.Items` inaccessible | QB provider uses `exports.qbx_core:GetItems()` for QBOX |
| `getItemDefinitions` | Same CoreObject guard | Same fix via provider routing |
| `getCitizenId` / `getMoney` / `getPlayerJob` | Inline if-chains with broken QBOX path | Routed through framework provider |
| `RemoveTargetEntity` (QB) | No option names passed, cleared ALL options | Now passes names array |
