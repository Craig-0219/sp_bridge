# sp_bridge Beta 1 支援矩陣

> 版本：v0.5.0-beta.1
> 更新日期：2026-03-28

---

## 狀態說明

| 符號 | 意義 |
|------|------|
| ✅ beta-ready | API 已穩定，通過自動測試，可在生產環境使用 |
| ⚠️ experimental | 架構已建立，但部分路徑未全面測試或有已知限制 |
| 🔲 not-standardized | 偵測邏輯存在，但 API 尚未收斂，不建議依賴 |
| ❌ 不支援 | 該組合在此版本未實作 |

---

## Framework 支援矩陣

| Framework | 偵測 | Provider | GetNormalizedPlayerData | GetNormalizedJob | GetCharacterId | GetFrameworkIdentifier | GetNormalizedMoney |
|-----------|------|----------|------------------------|-----------------|---------------|----------------------|-------------------|
| ESX (es_extended) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| QBCore (qb-core) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| QBOX (qbx_core) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Framework 備註

- **ESX**：`GetPlayerFromId` 以 `exports.es_extended:GetPlayerFromId` 為主路徑，`CoreObject` 為備援。`identifier` 屬性若不存在，自動 fallback 至 `Player.getIdentifier()`。
- **QBCore**：透過 `CoreObject.Functions.GetPlayer` 取得 player 物件，`PlayerData` 為正式資料來源。
- **QBOX**：透過 `exports.qbx_core:GetPlayer` 直接呼叫，不依賴 CoreObject。
- **client side**：`GetPlayer` / `GetPlayerData` / `GetPlayerJob` client exports 存在，但部分欄位完整度低於 server side，詳見 `docs/known-limitations.md`。

---

## Inventory 支援矩陣

| Inventory | 偵測 | Provider | AddItem | RemoveItem | GetItemCount | HasItem | CanCarryItem | CreateUsableItem | GetItemLabel | GetItemDefinitions |
|-----------|------|----------|---------|------------|-------------|---------|-------------|-----------------|-------------|-------------------|
| ox_inventory | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ |
| qb-inventory | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ⚠️ |
| qs-inventory | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ❌ | ⚠️ | ⚠️ |
| ESX native（無第三方） | ✅ | ❌ | ⚠️ | ❌ | ❌ | ❌ | ❌ | ⚠️ | ❌ | ❌ |

### Inventory 備註

- **CanCarryItem**：各 provider 皆已實作，但 metadata filter 的精確度因版本而異，只保證型別契約（回傳 boolean），不保證 metadata 完全比對。詳見 `docs/known-limitations.md`。
- **ESX native fallback**：僅 `AddItem`（透過 `Player.addInventoryItem`）與 `CreateUsableItem`（三段 fallback）有 ESX 原生路徑；其他 API 在無第三方 inventory 時回傳 `false` / `0` / `{}`。
- **qs-inventory `CreateUsableItem`**：qs-inventory 無標準 `RegisterUsableItem` export，該 API 在 qs 環境下不支援。
- **GetItemDefinitions**：ox 透過 `exports.ox_inventory:Items()` 取得完整清單；qb / qs 透過 `GetItemList()` / `Items()` 取得，格式不完全一致。

---

## Banking 支援矩陣

| Banking Provider | 偵測 | Provider | GetPlayerBankBalance | AddPlayerBankMoney | RemovePlayerBankMoney | GetSocietyBalance | AddSocietyMoney | RemoveSocietyMoney |
|-----------------|------|----------|---------------------|-------------------|----------------------|------------------|----------------|-------------------|
| framework（框架金錢層） | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ society_unsupported | ❌ | ❌ |
| Renewed-Banking | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| qb-banking | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| qb-management | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| okokBanking | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| esx_banking | ✅ 偵測 | ❌ 無 provider | — | — | — | — | — | — |
| esx_addonaccount | ✅ 偵測 | ❌ 無 provider | — | — | — | — | — | — |

### Banking 備註

- **framework provider**：player bank 透過 `sp.getMoney/addMoney/removeMoney('bank')` 代理至框架金錢層。Society API 固定回傳 `0` / `false`，並寫入 `society_unsupported` failure log。
- **qb / okok society**：player bank 走框架金錢層；society account 走外部 resource export。已在 provider 中實作，但尚未有完整的真實環境驗測，標記為 ⚠️ experimental。
- **esx_banking / esx_addonaccount**：init.lua 會偵測並設定 `sp.banking`，但 Beta 1 未建立對應 provider，所有 banking export 呼叫時將 fallback 至 `no_provider` 失敗路徑。
- **capability log**：所有 provider 在載入時印出 `[banking] provider=xxx playerBank=true/false society=true/false`，可用來確認 provider 是否正確啟動。

---

## Notification 支援狀態

| Resource | 偵測 | Export 標準化 |
|----------|------|--------------|
| ox_lib | ✅ | 🔲 not-standardized |
| okokNotify | ✅ | 🔲 not-standardized |
| mythic_notify | ✅ | 🔲 not-standardized |
| es_extended | ✅ | 🔲 not-standardized |
| qb-core | ✅ | 🔲 not-standardized |
| qbx_core | ✅ | 🔲 not-standardized |

> **Notification 模組尚未進入正式標準化範圍。** `sp.notification` 偵測值存在，但 `Notify` export 的跨框架行為尚未收斂，Beta 1 不應依賴其穩定性。

---

## Target 支援狀態

| Resource | 偵測 | Export 標準化 |
|----------|------|--------------|
| ox_target | ✅ | 🔲 not-standardized |
| qb-target | ✅ | 🔲 not-standardized |

> **Target 模組尚未進入正式標準化範圍。** 偵測邏輯與 alias 解析（`qb-target` 可能由 `ox_target` 提供）已實作，但 `AddTargetEntity` 等 API 的跨框架行為尚未收斂，Beta 1 不應依賴其穩定性。
