sp = setmetatable({
    name = GetCurrentResourceName(),
    context = IsDuplicityVersion() and "server" or "client",
}, {
    __newindex = function(self, name, fn)
        rawset(self, name, fn)
    end
})

cache = {
    resource = GetResourceMetadata(sp.name, 'identifier', 0),
    game = GetGameName(),
    version = GetResourceMetadata(sp.name, 'version', 0),
}

STANDALONE = 'standalone'
AUTO_DETECT = 'auto-detect'

Framework = {
    ESX = 'es_extended',
    QBCore = 'qb-core',
    QBOX = 'qbx_core',
}

Inventories = {
    ESX = 'es_extended',
    QB = 'qb-inventory',
    OX = 'ox_inventory',
    QS = 'qs-inventory',
}

Notifications = {
    OX = 'ox_lib',
    QBCore = 'qb-core',
    QBOX = 'qbx_core',
    ESX = 'es_extended',
    MYTHIC = 'mythic_notify',
    OKOK = 'okokNotify',
}

Bankings = {
    FRAMEWORK = 'framework',
    QB_BANKING = 'qb-banking',
    QB_MANAGEMENT = 'qb-management',
    RENEWED = 'Renewed-Banking',
    OKOK = 'okokBanking',
    ESX_BANKING = 'esx_banking',
    ESX_ADDON_ACCOUNT = 'esx_addonaccount',
}

Targets = {
    OX = 'ox_target',
    QB = 'qb-target',
}
