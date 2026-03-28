# sp_bridge Beta 1 發版前 Checklist

> 適用版本：v0.5.0-beta.1

---

## 一、環境確認

- [ ] `sp_bridge` 資源已啟動（`ensure sp_bridge`）
- [ ] `sp_bridge_test` 資源已啟動（`ensure sp_bridge_test`，排在 `sp_bridge` 之後）
- [ ] `config.lua` 中 `Config.Framework` 與實際環境吻合（或設為 `auto-detect`）
- [ ] `config.lua` 中 `Config.Banking` 與實際環境吻合（或設為 `auto-detect`）

---

## 二、啟動 Log 確認

啟動後在 server console 確認以下 log 存在且正確：

- [ ] `[detect] framework | config=... | detected=... | state=started`
  - `detected` 值應為 `es_extended` / `qb-core` / `qbx_core`
  - `state` 應為 `started`

- [ ] `[detect] inventory | config=... | detected=... | state=started`
  - 若無第三方 inventory，`detected` 為 `standalone`（可接受，視情況而定）

- [ ] `[detect] banking | config=... | detected=... | state=...`
  - `detected` 應為已知 provider 名稱或 `framework`

- [ ] `[banking] provider=xxx playerBank=true/false society=true/false`
  - 確認 banking provider 成功載入
  - `provider=none` 表示未載入任何 provider（異常）

- [ ] `[provider] ox_inventory server provider registered`（若使用 ox）
  - 類似 provider 載入 log 需存在

---

## 三、無 src 基礎測試

在 server console 執行：

```
sp_test
```

確認：

- [ ] 無 `SCRIPT ERROR`（`attempt to call a nil value` 等 Lua 錯誤為不可接受）
- [ ] `[PASS] GetFrameworkName returns string`
- [ ] `[PASS] GetFrameworkName is esx/qbcore/qbx`
- [ ] `[PASS] GetDetectedSystems returns table`
- [ ] `[PASS] Bank provider registered`（banking 測試）
- [ ] `[PASS] GetBankProviderName returns string`
- [ ] 其餘 `[SKIP]` 項目說明為 `no player src`（正常，無玩家時預期跳過）

---

## 四、有 src 完整測試

有玩家在線時執行（替換 `1` 為實際 server id）：

```
sp_test 1
```

確認：

- [ ] 無 `SCRIPT ERROR`
- [ ] `[PASS] GetPlayerJob returns table`
- [ ] `[PASS] job.name exists`
- [ ] `[PASS] job.grade is table`
- [ ] `[PASS] job.isBoss exists`
- [ ] `[PASS] GetCharacterId returns non-empty string`
- [ ] `[PASS] GetFrameworkIdentifier returns string`
- [ ] `[PASS] NormalizedPlayerData.identifier not nil`
- [ ] `[PASS] GetPlayerBankBalance returns number`
- [ ] `[PASS] AddPlayerBankMoney / RemovePlayerBankMoney`（round-trip）

### 可接受的 SKIP

以下 SKIP 在 Beta 1 環境中可接受：

| SKIP 項目 | 可接受條件 |
|-----------|-----------|
| `GetSocietyBalance` | banking provider 不支援 society（如 `framework` provider） |
| `AddSocietyMoney` | 同上 |
| `RemoveSocietyMoney` | 同上 |
| `CreateUsableItem` inventory 測試 | 使用 qs-inventory（不支援 RegisterUsableItem） |

### 不可接受的 FAIL

以下項目出現 FAIL 須在發版前修復：

| FAIL 項目 | 說明 |
|-----------|------|
| `GetFrameworkName is esx/qbcore/qbx` | framework 偵測失敗 |
| `GetNormalizedPlayerData` 任何欄位 nil | provider normalizePlayerData 實作問題 |
| `GetPlayerJob returns table` | NormalizedJob 路由失敗 |
| `GetCharacterId returns non-empty string` | ESX identity 路徑問題 |
| `GetPlayerBankBalance returns number` | banking provider 載入失敗 |
| `AddItem` / `RemoveItem` 任何基本測試 | inventory provider 路由失敗 |

---

## 五、文件確認

- [ ] 已閱讀 `docs/support-matrix.md`，確認目前環境的支援狀態
- [ ] 已閱讀 `docs/known-limitations.md`，確認已知限制是否影響此次發版
- [ ] `docs/releases/v0.5.0-beta.1.md` release note 已準備好

---

## 六、Tag 前最後確認

- [ ] `git log --oneline -5` 確認最新 commit 正確
- [ ] `git status` 無未提交修改
- [ ] `sp_test 1` 最後執行結果無不可接受的 FAIL
- [ ] Server console 無 `SCRIPT ERROR`
- [ ] `README.md` 版本號與 `fxmanifest.lua` 一致（若有更新）

---

## 快速確認指令

```lua
-- 在 server console 呼叫（F8 或 txAdmin console）
sp_test
sp_test 1

-- 在另一個 resource 中確認系統狀態
local systems = exports.sp_bridge:GetDetectedSystems()
print(json.encode(systems))

local provider = exports.sp_bridge:GetBankProviderName()
print('bank provider: ' .. tostring(provider))
```
