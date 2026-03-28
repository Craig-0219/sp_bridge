# sp_bridge 已知限制（Beta 1）

> 版本：v0.5.0-beta.1
> 本文件列出目前已確認存在的限制，非 bug，而是在設計或整合上的已知邊界。

---

## 1. Client-side API 完整度

**限制描述**

Server-side API 有完整的 provider 架構支撐（`sp.frameworkProvider`、`sp.inventoryProvider`）。
Client-side 對應 export（`GetPlayerJob`、`GetPlayerData`、`GetMoney` 等）存在，但部分框架的 client-side player 物件欄位完整度低於 server-side。

**受影響範圍**
- `GetNormalizedPlayerData` client export：schema 完整度未保證與 server 一致。
- 部分 ESX client API 依賴 `ESX.PlayerData`，該物件在玩家初始化前呼叫可能回傳不完整資料。

**建議做法**
- 凡需要可靠的玩家資料，以 server callback / event 取得，不依賴 client-side export 的完整性。
- Client-side 的 `GetPlayerJob`、`GetMoney` 適合用於 UI 顯示，不適合用於業務邏輯驗證。

---

## 2. Inventory Metadata 支援程度不一致

**限制描述**

`metadata` 參數在各 provider 的支援程度不同：

| Provider | AddItem metadata | RemoveItem metadata filter | GetItemCount metadata filter | CanCarryItem metadata |
|----------|-----------------|---------------------------|-----------------------------|-----------------------|
| ox_inventory | ✅ 完整 | ✅ 完整 | ✅ 完整 | ⚠️ 依版本 |
| qb-inventory | ⚠️ 部分 | ⚠️ 部分 | ❌ 不支援精確過濾 | ❌ 不支援 |
| qs-inventory | ⚠️ 部分 | ⚠️ 部分 | ❌ 不支援精確過濾 | ❌ 不支援 |

**建議做法**
- 若 metadata 為必要業務邏輯，建議以 ox_inventory 為目標環境。
- 跨 provider 通用代碼不應假設 metadata 過濾一定生效；應在取得結果後自行驗證。
- `HasItem` / `CanCarryItem` 回傳 `boolean` 的型別契約保證，但 metadata 精確比對不保證。

---

## 3. Framework Banking Provider 不支援 Society Account

**限制描述**

當 `sp.banking == 'framework'`（即未偵測到任何外部 banking 資源）時，banking provider 使用框架金錢層代理 player bank。

此 provider 的 society capability 為 `false`：
- `GetSocietyBalance` 固定回傳 `0`
- `AddSocietyMoney` / `RemoveSocietyMoney` 固定回傳 `false`
- 失敗 log 會寫入 `reason=society_unsupported`

**這是設計決策，非 bug。**

**建議做法**
- 若需要 society account 功能，安裝 `Renewed-Banking`、`qb-banking`、`qb-management` 或 `okokBanking`。
- 使用 `GetBankProviderName()` 在 runtime 確認 provider 類型後再決定是否呼叫 society API。

---

## 4. ESX Banking 偵測但無 Provider

**限制描述**

`init.lua` 會偵測 `esx_banking` 與 `esx_addonaccount` 並設定 `sp.banking`，但 Beta 1 未實作對應的 banking provider。

呼叫任何 banking export 時，若這兩個 resource 被偵測為 banking source，系統會找不到 `sp.bankProvider`，所有 banking export 會回傳 `0` / `false` 並寫入 `reason=no_provider`。

**建議做法**
- 使用 `esx_banking` / `esx_addonaccount` 的伺服器，Beta 1 的 banking export 不可用。
- 可手動在 `config.lua` 設定 `Config.Banking = 'framework'` 強制使用框架金錢層。

---

## 5. `CreateUsableItem` 路徑依賴

**限制描述**

`CreateUsableItem(item, cb)` 在不同環境的實際執行路徑不同，且無標準化方式確認是否成功註冊：

- **ox_inventory**：透過 `exports.ox_inventory:RegisterUsableItem`（若 ox 支援），或框架層 fallback。
- **ESX（無第三方 inventory）**：三段 fallback（CoreObject → 直接 export → fresh getSharedObject）。
- **qs-inventory**：無 `RegisterUsableItem`，provider 不支援此 API，回傳 `false`。
- **ESX fork**：部分 ESX fork 不暴露 `RegisterUsableItem` 直接 export，所有三段 fallback 皆失敗時回傳 `false`。

**建議做法**
- 在使用 `CreateUsableItem` 後，建議用 `sp_test` 驗證 `CreateUsableItem` 測試項目通過。
- 若回傳 `false`，查看 server console `[inventory] createUsableItem` 相關 warn log。

---

## 6. `CanCarryItem` / `HasItem` Metadata 精確度

**限制描述**

`CanCarryItem(source, item, count, metadata)` 與 `HasItem(source, item, count, metadata)` 型別契約保證：

- **保證**：回傳值一定是 `boolean`
- **不保證**：`metadata` 參數在非 ox_inventory provider 下是否真正用於過濾

實際上，在 qb / qs provider 下，`metadata` 參數可能被忽略，`HasItem` 等同於不帶 metadata 的版本。

**建議做法**
- 跨 provider 使用 `HasItem` 時，不依賴 metadata 過濾的精確性。
- 若 metadata 是業務必要條件，以 ox_inventory 為 target provider。

---

## 7. Notification / Target 模組

**限制描述**

- `Notify` export 存在，但 provider 行為（通知格式、顯示時間、type mapping）因 resource 而異，Beta 1 尚未收斂。
- `AddTargetEntity` 等 target client exports 存在，但跨框架行為尚未標準化。

**這兩個模組在 Beta 1 不在正式支援範圍內。**

---

## 8. `GetPlayerByCitizenId` ESX 效能注意

**限制描述**

`GetPlayerByCitizenId(cid)` 在 ESX 環境下遍歷所有線上玩家進行比對，高玩家數伺服器可能有效能影響。

**建議做法**
- 不在高頻率 tick / event handler 中呼叫此 API。
- 若需頻繁查找，建議在應用層維護自己的玩家 cache。
