# Banking API Reference

This document covers the `sp_bridge` banking module introduced in Sprint 9.

---

## Overview

The banking module provides a **provider-agnostic** interface for two distinct concepts:

| Concept | What it is | API prefix |
|---|---|---|
| **Player bank** | A single player’s bank account balance managed by the framework (ESX `bank`, QB `bank`) | `*PlayerBankMoney` |
| **Society / shared account** | A named organisational account managed by an external banking resource (Renewed-Banking, qb-banking, okokBanking) | `*SocietyMoney` |

> These two concepts are intentionally separated. Player bank **never** touches society account tables, and society mutations **never** modify a player’s personal balance.

The existing `GetMoney` / `AddMoney` / `RemoveMoney` exports are **unchanged**. The banking module sits alongside them.

---

## Server Exports

### Player bank

```lua
-- Returns the player's bank balance.
-- Contract: always returns number >= 0; returns 0 on any error.
exports.sp_bridge:GetPlayerBankBalance(source)  -- -> number

-- Adds amount to the player's bank balance.
-- Contract: returns true on success, false on any failure.
exports.sp_bridge:AddPlayerBankMoney(source, amount, reason?)  -- -> boolean

-- Removes amount from the player's bank balance.
-- Contract: returns true on success, false on any failure.
exports.sp_bridge:RemovePlayerBankMoney(source, amount, reason?)  -- -> boolean
```

**Guards applied at the wrapper level (before provider call):**
- `amount <= 0` → returns `false` immediately, no provider call

### Society / shared account

```lua
-- Returns the named account's balance.
-- Contract: always returns number >= 0; returns 0 on unsupported or error.
exports.sp_bridge:GetSocietyBalance(accountId)  -- -> number

-- Adds amount to the named account.
-- Contract: returns true on success, false on unsupported or failure.
exports.sp_bridge:AddSocietyMoney(accountId, amount, reason?)  -- -> boolean

-- Removes amount from the named account.
-- Contract: returns true on success, false on unsupported or failure.
exports.sp_bridge:RemoveSocietyMoney(accountId, amount, reason?)  -- -> boolean
```

**Guards applied at the wrapper level:**
- `accountId` empty or nil → returns `0` / `false` immediately
- `amount <= 0` → returns `false` immediately

---

## Provider Support Matrix

| Provider | Detected when | `playerBank` | `society` | Notes |
|---|---|---|---|---|
| `framework` | No third-party banking resource detected (default fallback) | ✓ via `sp.getMoney/addMoney/removeMoney('bank')` | ✗ not supported | Society calls return `0` / `false` and log `society_unsupported` |
| `renewed` | `Renewed-Banking` resource started | ✓ via `Renewed-Banking` exports | ✓ via `GetAccount / AddAccountMoney / RemoveAccountMoney` | |
| `qb-banking` | `qb-banking` resource started | ✓ via framework layer | ✓ via `qb-banking` exports | |
| `qb-management` | `qb-management` resource started | ✓ via framework layer | ✓ via `qb-management` exports | |
| `okokBanking` | `okokBanking` resource started | ✓ via framework layer | ✓ via `okokBanking` exports | `source=0` passed for server-initiated calls |

---

## Capability Log

On resource start, sp_bridge prints one capability line per active provider:

```
[banking] provider=framework playerBank=true society=false
[banking] provider=renewed playerBank=true society=true
[banking] provider=qb-banking playerBank=true society=true
[banking] provider=qb-management playerBank=true society=true
[banking] provider=okokBanking playerBank=true society=true
```

This lets you immediately confirm which provider is active and whether society is supported, without reading code.

You can also query the active provider name at runtime:

```lua
exports.sp_bridge:GetBankProviderName()  -- -> string  e.g. 'framework'
```

---

## Failure Debug Logs

When a banking call fails, sp_bridge logs a structured warning or error to the server console. The log always includes the API name, provider name, context (source / accountId / amount), and a `reason` code.

### Reason codes

| Reason | Meaning | What to check |
|---|---|---|
| `no_provider` | `sp.bankProvider` is nil; no provider registered | Check that a supported banking resource is started; check `[detect] banking` lines in the startup log |
| `method_missing` | Provider object exists but the required method is absent | Version mismatch between provider and sp_bridge |
| `pcall_error` | The provider method threw a Lua error | See the `error=` field in the log; usually a missing export or wrong resource name |
| `unexpected_return` | Provider returned an unexpected type (e.g. table instead of number) | External resource API mismatch; check the `got=` field |
| `provider_returned_false` | Provider call succeeded but returned `false` | External resource rejected the operation (e.g. insufficient funds, locked account); check that resource’s own log |
| `society_unsupported` | Current provider has `capabilities.society = false` | Switch to a provider that supports society accounts, or handle society logic directly in your job resource |

### Log examples

```
-- Query failures
[banking] GetPlayerBankBalance source=12 reason=no_provider
[banking] GetPlayerBankBalance provider=renewed source=12 reason=pcall_error error=attempt to index nil
[banking] GetSocietyBalance provider=framework accountId=society_police reason=society_unsupported
[banking] GetSocietyBalance provider=renewed accountId=society_police reason=unexpected_return got=table

-- Mutation failures
[banking] AddPlayerBankMoney provider=framework source=12 amount=1000 reason=provider_returned_false
[banking] AddSocietyMoney provider=qb-banking accountId=society_cardealer amount=5000 reason=provider_returned_false
[banking] RemoveSocietyMoney provider=framework accountId=society_police amount=500 reason=society_unsupported
[banking] RemovePlayerBankMoney provider=framework source=12 amount=1000 reason=method_missing
```

---

## Smoke Tests (manual)

These can be run from the server console after both `sp_bridge` and `sp_bridge_test` are started.

```
# Full test suite against player 1
sp_test 1

# Server-console only (no player src; player bank tests will be skipped)
sp_test
```

Expected output for a **framework** provider (no society support):

```
[sp_bridge_test] ==== Banking Tests ====
[sp_bridge_test] ---- Bank provider registered
[sp_bridge_test] PASS  GetBankProviderName returns string
[sp_bridge_test] PASS  GetBankProviderName not empty
[sp_bridge_test]   active bank provider = framework
[sp_bridge_test] ---- GetPlayerBankBalance
[sp_bridge_test] PASS  GetPlayerBankBalance returns number
[sp_bridge_test] PASS  GetPlayerBankBalance >= 0
[sp_bridge_test] ---- AddPlayerBankMoney / RemovePlayerBankMoney round-trip
[sp_bridge_test] PASS  AddPlayerBankMoney returns bool
[sp_bridge_test] PASS  RemovePlayerBankMoney returns bool
[sp_bridge_test] PASS  RemovePlayerBankMoney returned true
[sp_bridge_test] ---- Framework provider society_unsupported contract
[sp_bridge_test] PASS  GetSocietyBalance returns number (framework)
[sp_bridge_test] PASS  GetSocietyBalance == 0 when unsupported
[sp_bridge_test] PASS  AddSocietyMoney returns bool (framework)
[sp_bridge_test] PASS  AddSocietyMoney == false when unsupported
[sp_bridge_test] PASS  RemoveSocietyMoney returns bool (framework)
[sp_bridge_test] PASS  RemoveSocietyMoney == false when unsupported
[sp_bridge_test] ---- Society mutation contract (non-framework providers)
[sp_bridge_test] SKIP  AddSocietyMoney / RemoveSocietyMoney -- framework provider does not support society accounts
```

Expected output for a **renewed / qb / okok** provider:

```
[sp_bridge_test] ---- Framework provider society_unsupported contract
[sp_bridge_test] SKIP  society_unsupported contract -- provider=renewed; only checked for framework
[sp_bridge_test] ---- Society mutation contract (non-framework providers)
[sp_bridge_test] PASS  AddSocietyMoney returns bool
[sp_bridge_test] PASS  RemoveSocietyMoney returns bool
```

---

## Design Decisions

### Why separate player bank and society?

Framework money (ESX `bank` account, QB `bank` money type) is always available and represents the individual player’s wealth. Society / shared accounts are a separate database table managed by external resources. Mixing the two would either force every ESX/QB server to install a banking resource, or silently shadow the player’s real bank balance with a society value.

### Why does `framework` provider return 0/false for society instead of erroring?

The export contract guarantees a safe return value (`number` / `boolean`) regardless of configuration. Returning `0` / `false` lets callers use the same code path without a try/catch. The `society_unsupported` log at call time gives the operator full visibility without breaking the resource.

### Why is `reason?` optional?

Most banking resources accept an optional reason string for audit logs. Omitting it is valid; providers default it to `''` before passing to the external resource.
