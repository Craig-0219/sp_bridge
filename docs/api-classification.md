# sp_bridge API 分類總表

> 版本：v0.5.0-beta.1
> 本文件定義每個 server export 的分類與未來方向。

---

## 分類定義

| 分類 | 定義 |
|------|------|
| **Canonical** | 跨框架統一 schema，回傳值穩定，新開發應優先使用 |
| **Raw** | 回傳框架原始物件，schema 因框架而異，用於需要直接操作框架資料的場景 |
| **Legacy-compatible** | 舊 API 名稱保留，實際委派至 canonical / raw，不建議新開發依賴 |
| **Soft-deprecated** | 仍可用，但明確建議改用對應的 canonical API；未來版本可能移除 |

---

## Framework API

### Canonical

| Export | 說明 |
|--------|------|
| `GetNormalizedPlayerData(source)` | 回傳跨框架統一 player 資料：`{ name, identifier, job, money }` |
| `GetNormalizedJob(source)` | 回傳統一 job schema：`{ name, label, onduty, isBoss, grade={level,name,label,salary} }` |
| `GetNormalizedMoney(source)` | 回傳統一 money schema：`{ cash, bank, dirty }` |
| `GetCharacterId(source)` | 回傳角色 ID（ESX=identifier, QB/QBOX=citizenid） |
| `GetFrameworkIdentifier(source)` | 回傳平台 identifier（`license:xxx`），用於 DB key |
| `GetFrameworkName([mode])` | 回傳 `'esx'`、`'qbcore'`、`'qbx'`；`mode='resource'` 回傳原始名稱 |
| `GetDetectedSystems()` | 回傳所有偵測結果（framework, inventory, banking, ...） |
| `GetOnlinePlayers()` | 回傳線上玩家清單 |
| `GetPlayers()` | 回傳 player 物件清單 |
| `GetPlayerByCitizenId(cid)` | 依角色 ID 查找 player |
| `GetPlayerName(source)` | 回傳玩家名稱 |

### Raw

| Export | 說明 |
|--------|------|
| `GetRawPlayerJob(source)` | 回傳框架原始 job 物件（ESX: `Player.job`，QB: `pd.job`），schema 不保證跨框架一致 |
| `GetPlayer(source)` | 回傳框架原始 player 物件（ESX: Player instance，QB: player table） |

### Legacy-compatible

| Export | 說明 | 實際行為 |
|--------|------|---------|
| `GetPlayerJob(source)` | 原為回傳原始 job，現委派至 `GetNormalizedJob` | **Breaking change from v0.3.0**：schema 已改為 normalized |
| `GetPlayerData(source)` | 回傳框架原始 player 資料 | ESX 回傳 Player 物件，QB 回傳 PlayerData table，同 `GetRawPlayerData` |
| `GetRawPlayerData(source)` | `GetPlayerData` 的明確 raw alias | 同 `GetPlayerData` |

### Soft-deprecated

| Export | 建議替換 | 說明 |
|--------|---------|------|
| `GetCitizenId(source)` | → `GetCharacterId(source)` | 名稱混淆（ESX 稱 identifier，QB 稱 citizenid），`GetCharacterId` 語義更清晰 |
| `GetPlayerData(source)` | → `GetNormalizedPlayerData(source)` | 若你的代碼依賴 normalized 欄位（如 `pd.identifier`、`pd.job.name`），應改用 canonical API；若確實需要原始物件，改用明確的 `GetRawPlayerData` |
| `GetMoney(source, moneyType)` | → `GetNormalizedMoney(source)` | moneyType 字串在不同框架意義不同（ESX `'money'` vs QB `'cash'`），normalized API 消除此歧義 |
| `AddMoney(source, moneyType, amount, reason)` | → 各框架直接呼叫或未來 canonical API | 目前透過 frameworkProvider 路由，但 moneyType 語意不統一 |
| `RemoveMoney(source, moneyType, amount, reason)` | → 同上 | 同上 |
| `SetMoney(source, moneyType, amount, reason)` | → 同上 | 同上 |

---

## Inventory API

### Canonical

| Export | 說明 |
|--------|------|
| `AddItem(source, item, count, metadata, slot)` | 新增物品至玩家背包 |
| `RemoveItem(source, item, count, metadata, slot)` | 從玩家背包移除物品 |
| `GiveItem(fromSource, toSource, item, count, metadata)` | 玩家間物品轉移 |
| `GetItemCount(source, item, metadata)` | 查詢物品數量 |
| `HasItem(source, item, count, metadata)` | 確認是否持有物品 |
| `CanCarryItem(source, item, count, metadata)` | 確認是否可攜帶物品 |
| `CanCarryItems(source, items)` | 批次確認是否可攜帶多個物品 |
| `CreateUsableItem(item, cb)` | 註冊可使用物品 |
| `GetItemLabel(item)` | 取得物品顯示名稱 |
| `GetItemDefinitions()` | 取得所有物品定義清單 |

> Inventory API 無 soft-deprecated 項目；所有 API 均已 provider 化，直接使用即可。

---

## Banking API

### Canonical

| Export | 說明 |
|--------|------|
| `GetBankProviderName()` | 取得目前 banking provider 名稱，用於診斷 |
| `GetPlayerBankBalance(source)` | 查詢玩家銀行帳戶餘額 |
| `AddPlayerBankMoney(source, amount, reason)` | 增加玩家銀行餘額 |
| `RemovePlayerBankMoney(source, amount, reason)` | 減少玩家銀行餘額 |
| `GetSocietyBalance(accountId)` | 查詢組織帳戶餘額（依 provider 能力而定） |
| `AddSocietyMoney(accountId, amount, reason)` | 增加組織帳戶餘額（依 provider 能力而定） |
| `RemoveSocietyMoney(accountId, amount, reason)` | 減少組織帳戶餘額（依 provider 能力而定） |

### Soft-deprecated（舊 bank module）

| Export | 建議替換 | 說明 |
|--------|---------|------|
| `GetBankBalance(source)` | → `GetPlayerBankBalance(source)` | 舊 `modules/bank` 模組 export，名稱不符合新命名規範 |
| `AddBankMoney(source, amount, reason)` | → `AddPlayerBankMoney(source, amount, reason)` | 同上 |
| `RemoveBankMoney(source, amount, reason)` | → `RemovePlayerBankMoney(source, amount, reason)` | 同上 |

---

## 未納入分類的模組

### Notification

`Notify(source, message, type, duration)` 存在但行為因 provider 而異，**尚未納入正式分類**。

### Target

`AddTargetEntity` 等 client exports 存在但尚未標準化，**尚未納入正式分類**。

---

## API 設計原則（供參考）

1. **Canonical API** 一律回傳穩定 schema，從不回傳 framework-specific 物件。
2. **Raw API** 名稱帶有 `Raw` 前綴，明確標示使用者承擔 schema 不一致的風險。
3. **Legacy API** 與 canonical / raw 同名但語意已改變，以文件說明取代強制移除。
4. **所有 API 失敗時一律回傳安全值**（`nil`、`0`、`false`、`{}`），不拋出例外。
