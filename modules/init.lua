local function detectFramework()
    local function detectESX()
        if GetResourceState('es_extended') == 'started' then
            local ok, esx = pcall(function()
                return exports['es_extended']:getSharedObject()
            end)
            if ok and esx then
                sp.framework = Framework.ESX
                return esx
            end
        end
    end

    local function detectQBCore()
        if GetResourceState('qb-core') == 'started' then
            local ok, qbCore = pcall(function()
                return exports['qb-core']:GetCoreObject()
            end)
            if ok and qbCore then
                sp.framework = Framework.QBCore
                return qbCore
            end
        end
    end

    local function detectQBOX()
        if GetResourceState('qbx_core') == 'started' then
            sp.framework = Framework.QBOX
            return Framework.QBOX
        end
    end

    if Config.Framework == AUTO_DETECT then
        local core = detectQBOX() or detectESX() or detectQBCore() or STANDALONE
        if core == STANDALONE then
            sp.print.warn('No framework was detected!')
            return
        else
            return core
        end
    end
    
    -- Manual config handling
    if Config.Framework == Framework.ESX then return detectESX() end
    if Config.Framework == Framework.QBCore then return detectQBCore() end
    if Config.Framework == Framework.QBOX then return detectQBOX() end
end

local function detectInventory()
    local function detectOX()
        if GetResourceState('ox_inventory') == 'started' then
            sp.inventory = Inventories.OX
            return Inventories.OX
        end
    end

    local function detectQB()
        if GetResourceState('qb-inventory') == 'started' then
            sp.inventory = Inventories.QB
            return Inventories.QB
        end
    end
    
    local function detectQS()
        if GetResourceState('qs-inventory') == 'started' then
            sp.inventory = Inventories.QS
            return Inventories.QS
        end
    end

    if Config.Inventories == AUTO_DETECT then
        local inventory = detectOX() or detectQB() or detectQS() or STANDALONE
        if inventory == STANDALONE then
            sp.print.warn('No inventory was detected!')
            return
        else
            return inventory
        end
    end
    
    if Config.Inventories == Inventories.OX then return detectOX() end
    if Config.Inventories == Inventories.QB then return detectQB() end
    if Config.Inventories == Inventories.QS then return detectQS() end
end

local function detectNotify()
    local function detectOX()
        if GetResourceState('ox_lib') == 'started' then
            sp.notification = Notifications.OX
            return Notifications.OX
        end
    end

    local function detectOKOK()
        if GetResourceState('okokNotify') == 'started' then
            sp.notification = Notifications.OKOK
            return Notifications.OKOK
        end
    end

    local function detectMYTHIC()
        if GetResourceState('mythic_notify') == 'started' then
            sp.notification = Notifications.MYTHIC
            return Notifications.MYTHIC
        end
    end

    local function detectQBOX()
        if GetResourceState('qbx_core') == 'started' then
            sp.notification = Notifications.QBOX
            return Notifications.QBOX
        end
    end

    local function detectQBCORE()
        if GetResourceState('qb-core') == 'started' then
            sp.notification = Notifications.QBCore
            return Notifications.QBCore
        end
    end

    local function detectESX()
        if GetResourceState('es_extended') == 'started' then
            sp.notification = Notifications.ESX
            return Notifications.ESX
        end
    end

    if Config.Notifications == AUTO_DETECT then
        local notify = detectOKOK() or detectMYTHIC() or detectESX() or detectQBOX() or detectQBCORE() or detectOX() or STANDALONE
        if notify == STANDALONE then
            sp.print.warn('No notifications was detected!')
            return
        else
            return notify
        end
    end

    if Config.Notifications == Notifications.OX then return detectOX() end
    if Config.Notifications == Notifications.OKOK then return detectOKOK() end
    if Config.Notifications == Notifications.MYTHIC then return detectMYTHIC() end
    if Config.Notifications == Notifications.QBOX then return detectQBOX() end
    if Config.Notifications == Notifications.QBCore then return detectQBCORE() end
    if Config.Notifications == Notifications.ESX then return detectESX() end
end

local function getProvideSource(aliasName)
    if type(aliasName) ~= 'string' or aliasName == '' then
        return nil
    end

    local ok, resourceCount = pcall(GetNumResources)
    if not ok or type(resourceCount) ~= 'number' then
        return nil
    end

    for i = 0, resourceCount - 1 do
        local resourceName = GetResourceByFindIndex(i)
        if type(resourceName) == 'string' and resourceName ~= '' then
            if GetResourceState(resourceName) == 'started' then
                local metadataCount = GetNumResourceMetadata(resourceName, 'provide') or 0
                for j = 0, metadataCount - 1 do
                    local provided = GetResourceMetadata(resourceName, 'provide', j)
                    if provided == aliasName then
                        return resourceName
                    end
                end
            end
        end
    end

    return nil
end

local function isProvidedAlias(aliasName)
    local provider = getProvideSource(aliasName)
    if provider and provider ~= aliasName then
        return true, provider
    end

    return false, provider
end

local function detectTargets()
    local function detectOX()
        if GetResourceState('ox_target') == 'started' then
            sp.target = Targets.OX
            return Targets.OX
        end
    end

    local function detectQB()
        if GetResourceState('qb-target') == 'started' then
            local isAlias, provider = isProvidedAlias('qb-target')
            if isAlias and provider == Targets.OX then
                return nil
            end

            sp.target = Targets.QB
            return Targets.QB
        end
    end

    if Config.Targets == AUTO_DETECT then
        local target = detectQB() or detectOX() or STANDALONE
        if target == STANDALONE then
            sp.print.warn('No target was detected!')
            return
        else
            return target
        end
    end

    if Config.Targets == Targets.OX then return detectOX() end
    if Config.Targets == Targets.QB then return detectQB() end
end

local function detectBanking()
    local function detectRenewed()
        if GetResourceState('Renewed-Banking') == 'started' then
            sp.banking = Bankings.RENEWED
            return Bankings.RENEWED
        end
    end

    local function detectQbBanking()
        if GetResourceState('qb-banking') == 'started' then
            sp.banking = Bankings.QB_BANKING
            return Bankings.QB_BANKING
        end
    end

    local function detectQbManagement()
        if GetResourceState('qb-management') == 'started' then
            sp.banking = Bankings.QB_MANAGEMENT
            return Bankings.QB_MANAGEMENT
        end
    end

    local function detectOkokBanking()
        if GetResourceState('okokBanking') == 'started' then
            sp.banking = Bankings.OKOK
            return Bankings.OKOK
        end
    end

    local function detectEsxBanking()
        if GetResourceState('esx_banking') == 'started' then
            sp.banking = Bankings.ESX_BANKING
            return Bankings.ESX_BANKING
        end
    end

    local function detectEsxAddon()
        if GetResourceState('esx_addonaccount') == 'started' then
            sp.banking = Bankings.ESX_ADDON_ACCOUNT
            return Bankings.ESX_ADDON_ACCOUNT
        end
    end

    local function detectFrameworkMoney()
        sp.banking = Bankings.FRAMEWORK
        return Bankings.FRAMEWORK
    end

    if Config.Banking == AUTO_DETECT then
        local bank = detectRenewed() or detectQbBanking() or detectQbManagement() or detectOkokBanking() or detectEsxBanking() or detectEsxAddon() or detectFrameworkMoney() or STANDALONE
        if bank == STANDALONE then
            sp.print.warn('No banking was detected!')
            return
        else
            return bank
        end
    end

    if Config.Banking == Bankings.RENEWED then return detectRenewed() end
    if Config.Banking == Bankings.QB_BANKING then return detectQbBanking() end
    if Config.Banking == Bankings.QB_MANAGEMENT then return detectQbManagement() end
    if Config.Banking == Bankings.OKOK then return detectOkokBanking() end
    if Config.Banking == Bankings.ESX_BANKING then return detectEsxBanking() end
    if Config.Banking == Bankings.ESX_ADDON_ACCOUNT then return detectEsxAddon() end
    if Config.Banking == Bankings.FRAMEWORK then return detectFrameworkMoney() end
end

local function getResourceStateSafe(resourceName)
    if type(resourceName) ~= 'string' or resourceName == '' then
        return 'n/a'
    end

    local ok, state = pcall(GetResourceState, resourceName)
    if not ok or type(state) ~= 'string' then
        return 'unknown'
    end

    return state
end

local function printDetectedSystem(name, configured, detected)
    local detectedName = detected and tostring(detected) or 'not-detected'
    local state = 'n/a'

    if detected == Bankings.FRAMEWORK then
        state = 'virtual'
    elseif detected and detected ~= STANDALONE then
        state = getResourceStateSafe(detected)
    end

    sp.print.info(('[detect] %s | config=%s | detected=%s | state=%s'):format(
        tostring(name),
        tostring(configured),
        detectedName,
        tostring(state)
    ))
end

local function detectTargetServerSide()
    local oxState = getResourceStateSafe('ox_target')
    local qbState = getResourceStateSafe('qb-target')
    local isQbAlias, qbProvider = isProvidedAlias('qb-target')

    local function detectOX()
        if oxState == 'started' then
            return Targets.OX
        end
    end

    local function detectQB()
        if qbState == 'started' then
            if isQbAlias and qbProvider == Targets.OX then
                return nil
            end

            return Targets.QB
        end
    end

    if Config.Targets == AUTO_DETECT then
        return detectQB() or detectOX() or STANDALONE
    end

    if Config.Targets == Targets.OX then
        return detectOX() or STANDALONE
    end

    if Config.Targets == Targets.QB then
        return detectQB() or STANDALONE
    end

    return STANDALONE
end

local function printStartupSummary()
    sp.print.info(('Bridge detection summary (context=%s)'):format(tostring(sp.context)))

    printDetectedSystem('framework', Config.Framework, sp.framework)
    printDetectedSystem('inventory', Config.Inventories, sp.inventory)
    printDetectedSystem('notifications', Config.Notifications, sp.notification)

    if sp.context == 'client' then
        printDetectedSystem('target', Config.Targets, sp.target)
    else
        local serverTarget = detectTargetServerSide()
        printDetectedSystem('target(server)', Config.Targets, serverTarget)
        sp.print.info(('[detect] target.resources | ox_target=%s | qb-target=%s'):format(
            getResourceStateSafe('ox_target'),
            getResourceStateSafe('qb-target')
        ))
        sp.print.info(('[detect] target.provide | qb-target provider=%s'):format(
            tostring(getProvideSource('qb-target') or 'none')
        ))
    end

    printDetectedSystem('banking', Config.Banking, sp.banking)
end

if Config.Framework then
    CoreObject = detectFramework()
end

if Config.Inventories then
    InventoryObject = detectInventory()
end

if Config.Notifications then
    NotifyObject = detectNotify()
end

if Config.Targets and sp.context == 'client' then
    TargetObject = detectTargets()
end

if Config.Banking then
    BankingObject = detectBanking()
end

printStartupSummary()

sp.loaded = true
