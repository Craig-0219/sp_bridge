fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'sofapotato_bridge'
author 'sofapotato'
version '0.3.0'
description 'SofaPotato bridge core (Refactored to match it_bridge)'

identifier 'sp_bridge'

shared_scripts {
    'modules/variables.lua',
    'config.lua',
    'modules/print/shared.lua',
    'modules/init.lua',
    'modules/**/shared.lua'
}

client_scripts {
    -- framework providers must load before glob
    'modules/framework/providers/esx/client.lua',
    'modules/framework/providers/qbcore/client.lua',
    'modules/framework/providers/qbox/client.lua',
    'modules/**/client/*.lua',
}

server_scripts {
    -- framework providers must load before glob
    'modules/framework/providers/esx/server.lua',
    'modules/framework/providers/qbcore/server.lua',
    'modules/framework/providers/qbox/server.lua',
    -- inventory providers must load before glob
    'modules/inventory/providers/ox/server.lua',
    'modules/inventory/providers/qb/server.lua',
    'modules/inventory/providers/qs/server.lua',
    'modules/**/server/*.lua',
}
