# sofapotato_skill 整合指南

`sofapotato_skill` 是一個基於 `sp_bridge` 的等級 × 天賦系統。本文件說明其所使用到的 bridge exports，以及如何讓其他資源與它協作。

## 所依賴的 sp_bridge exports

`sofapotato_skill` 僅依賴 `sp_bridge` 的標準 API，無需對 `sp_bridge` 做任何修改：

| 層面 | Export | 用途 |
| --- | --- | --- |
| Framework (Server) | `GetCitizenId(source)` | 以 citizenid 索引 MySQL 資料 |
| Framework (Server) | `RemoveMoney(source, moneyType, amount, reason)` | 天賦重置扣費 |
| Notifications | `Notify(source, msg, type, data)` (Server)、`Notify(msg, type, data)` (Client) | UI / 操作回饋 |

## 生命週期與觸發時機

- Server 端會在以下時機載入玩家資料：
    - `QBCore:Server:OnPlayerLoaded`
    - `qbx_core:server:onPlayerLoaded`
    - `esx:playerLoaded`
- Client 端在 `sp_bridge` 啟動完成後向 server 請求 sync，並在玩家 login 後接收天賦資料。

## 在其他資源中使用天賦效果

```lua
-- 例：挖礦腳本完成一次挖礦時發放 XP
exports['sofapotato_skill']:GrantJobXP(source, 'mining_ore')

-- 例：自定義金額 XP
exports['sofapotato_skill']:AddXP(source, 42, 'custom_reason')

-- 例：針對製作腳本讀取「雙倍產出」機率
local chance = exports['sofapotato_skill']:GetEffect(source, 'double_output_chance')
if math.random() < chance then
    -- 額外給予一份物品
    exports['sp_bridge']:AddItem(source, 'iron_ore', 1)
end
```

## 預設提供的效果 key

- `damage_multiplier` ｜進攻傷害修正（已自動套用到 `SetPlayerWeaponDamageModifier`）
- `defense_multiplier` ｜受到傷害折扣（自動套用，負值 perRank 表示減傷）
- `accuracy_bonus` ｜武器精準度，由武器腳本讀取
- `low_hp_regen` ｜低於 25% 血量時每 30s 回復 10 HP（內建）
- `action_speed` ｜動作速度，由工作腳本讀取
- `double_output_chance` ｜產出候額外一份的機率
- `xp_multiplier_job` / `xp_multiplier_vehicle` ｜XP 加成（已內建）
- `stamina_bonus` ｜身體能量 / 辣甲增益（已內建）
- `needs_decay_reduction` ｜飢餓口渴流失減緩，由需求腳本讀取
- `damage_immunity_proc` ｜被擊後短暫無敵，由戰鬥腳本讀取

> 自定義 effect key：在 `config/talents.lua` 的 `talent.effect.key` 設定任何字串名即可。其他腳本用 `GetEffect(source, 'your_key')` 取得聚合值 (對應階數 × perRank 之和)。
