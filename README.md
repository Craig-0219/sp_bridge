# sp_bridge (sofapotato_bridge)

以 `it_bridge` 的「模組化 API」風格重構的通用橋接層，目標是讓你的其他資源不需要知道伺服器使用的是 ESX / QBCore / QBX，也不需要知道使用的是哪套 Inventory / Notify。

這個資源會在啟動時自動偵測目前伺服器正在運行的系統，並提供一致的 exports 介面。

## 功能

- Framework：ESX / QBCore / QBX
- Inventory：ox_inventory / qb-inventory / qs-inventory
- Notifications：ox_lib / okokNotify / mythic_notify / ESX / QBCore / QBX
- Targets：ox_target / qb-target
- Bank：以 framework 的 money 系統為基礎提供 bank exports

## 目錄結構

```text
sp_bridge/
  fxmanifest.lua
  config.lua
  modules/
    variables.lua
    init.lua
    print/shared.lua
    framework/
      server/*.lua
      client/*.lua
    inventory/
      server/*.lua
      client/*.lua
    bank/
      server/*.lua
    notifications/
      server/*.lua
      client/*.lua
    target/
      client/*.lua
```

## 安裝

1. 將資料夾放到你的 resources 內（資料夾名稱建議保持 `sp_bridge`）
2. `ensure sp_bridge`

## 設定

設定檔：[config.lua](file:///D:/testserver/txData/QBBOX/sofapotato/sp_bridge/config.lua)

```lua
Config.Framework = 'auto-detect'      -- auto-detect | es_extended | qb-core | qbx_core
Config.Inventories = 'auto-detect'    -- auto-detect | ox_inventory | qb-inventory | qs-inventory
Config.Notifications = 'auto-detect'  -- auto-detect | ox_lib | es_extended | qb-core | qbx_core | okokNotify | mythic_notify
Config.Banking = 'auto-detect'        -- auto-detect | framework | qb-banking | qb-management | Renewed-Banking | okokBanking | esx_banking | esx_addonaccount
Config.Targets = 'auto-detect'        -- auto-detect | ox_target | qb-target
```

## 自動偵測

偵測邏輯在 [modules/init.lua](file:///D:/testserver/txData/QBBOX/sofapotato/sp_bridge/modules/init.lua)：

- Framework：依序嘗試 `qbx_core` → `es_extended` → `qb-core`
- Inventory：依序嘗試 `ox_inventory` → `qb-inventory` → `qs-inventory`
- Notifications：依序嘗試 `okokNotify` → `mythic_notify` → `es_extended` → `qbx_core` → `qb-core` → `ox_lib`
- Banking：依序嘗試 `Renewed-Banking` → `qb-banking` → `qb-management` → `okokBanking` → `esx_banking` → `esx_addonaccount` → `framework`
- Targets：依序嘗試 `qb-target` → `ox_target`

## 用法範例

### Framework（Server）

```lua
local Player = exports['sp_bridge']:GetPlayer(source)
local money = exports['sp_bridge']:GetMoney(source, 'bank')
exports['sp_bridge']:AddMoney(source, 'bank', 1000, 'reward')
exports['sp_bridge']:RemoveMoney(source, 'cash', 100, 'fee')
```

### Bank（Server）

```lua
local balance = exports['sp_bridge']:GetBankBalance(source)
exports['sp_bridge']:AddBankMoney(source, 500, 'deposit')
exports['sp_bridge']:RemoveBankMoney(source, 250, 'withdraw')
```

### Society / Shared Accounts（Server）

```lua
local job = 'police'
local bal = exports['sp_bridge']:GetAccountBalance(job)
exports['sp_bridge']:AddAccountMoney(job, 1000, 'fine')
exports['sp_bridge']:RemoveAccountMoney(job, 200, 'refund')
```

### Inventory（Server）

```lua
if exports['sp_bridge']:CanCarryItem(source, 'water', 1) then
  exports['sp_bridge']:AddItem(source, 'water', 1)
end

local count = exports['sp_bridge']:GetItemCount(source, 'water')
local has = exports['sp_bridge']:HasItem(source, 'water')
```

### Notifications

Server 端（轉發給指定玩家）：

```lua
exports['sp_bridge']:Notify(source, 'Hello', 'inform', { duration = 3000, title = 'Notice' })
```

Client 端（本地通知）：

```lua
exports['sp_bridge']:Notify('Hello', 'success', { duration = 2500 })
```

### Targets（Client）

```lua
local entity = PlayerPedId()
local options = {
  {
    name = 'hello',
    label = 'Say Hello',
    icon = 'fa-solid fa-hand',
    distance = 2.0,
    onSelect = function(ent)
      print('hello', ent)
    end,
  }
}

exports['sp_bridge']:AddTargetEntity(entity, options)
exports['sp_bridge']:RemoveTargetEntity(entity, { 'hello' })
```

## Exports 清單

以下 API 都以 `exports['sp_bridge']:*` 呼叫。

### Framework (Server)

- `GetPlayer(source)`
- `GetPlayers()`
- `GetOnlinePlayers()`
- `GetPlayerData(source)`
- `GetPlayerName(source)`
- `GetPlayerJob(source)`
- `GetCitizenId(source)`
- `GetPlayerByCitizenId(citizenId)`
- `GetMoney(source, moneyType)`
- `AddMoney(source, moneyType, amount, reason?)`
- `RemoveMoney(source, moneyType, amount, reason?)`
- `SetMoney(source, moneyType, amount, reason?)`

### Framework (Client)

- `GetPlayer()`
- `GetPlayerData()`
- `GetPlayerName()`
- `GetPlayerJob()`
- `GetCitizenId()`
- `GetMoney(moneyType)`

### Inventory (Server)

- `AddItem(source, item, count, metadata?)`
- `RemoveItem(source, item, count, metadata?)`
- `GetItemCount(source, item, metadata?)`
- `HasItem(source, item, metadata?)`
- `CanCarryItem(source, item, count, metadata?)`
- `CanCarryItems(source, items)`
- `GiveItem(source, item, count, metadata?)`
- `GetItemLabel(item)`
- `GetItemDefinitions()`
- `GetItems()`
- `GetAllItems()`
- `GetItemList()`
- `Items(itemName?)`
- `CreateUsableItem(item, cb)`
- `ItemDeployer(items, cb)`

### Inventory (Client)

- `GetInventoryImage(item)`
- `GetItemCountClient(item, metadata?)`
- `HasItemClient(item, metadata?)`
- `GetItemLabelClient(item)`
- `CanCarryItemClient(item, count, metadata?)`
- `CanCarryItemsClient(items)`

### Bank (Server)

- `GetBankBalance(source)`
- `AddBankMoney(source, amount, reason?)`
- `RemoveBankMoney(source, amount, reason?)`
- `GetAccountBalance(account)`
- `AddAccountMoney(account, amount, reason?)`
- `RemoveAccountMoney(account, amount, reason?)`
- `GetJobAccountBalance(job)`
- `AddJobAccountMoney(job, amount, reason?)`
- `RemoveJobAccountMoney(job, amount, reason?)`
- `GetGangAccountBalance(gang)`
- `AddGangAccountMoney(gang, amount, reason?)`
- `RemoveGangAccountMoney(gang, amount, reason?)`

### Notifications

- `Notify(source, message, notifyType?, data?)`（Server）
- `Notify(message, notifyType?, data?)`（Client）

### Targets (Client)

- `AddTargetEntity(entities, options)`
- `RemoveTargetEntity(entities, optionNames)`
- `AttachEntityTarget(entity, options)`
- `RemoveEntityTarget(entity, optionNames)`
- `AttachNpcTarget(entity, options)`（相容別名）
- `RemoveNpcTarget(entity, optionNames)`（相容別名）
