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
    -- providers must be first so sp.clientProvider is set before export files load
    'modules/framework/providers/esx/client.lua',
    'modules/framework/providers/qbcore/client.lua',
    'modules/framework/providers/qbox/client.lua',
    'modules/**/client/*.lua',
}

server_scripts {
    -- providers must be first so sp.frameworkProvider is set before export files load
    'modules/framework/providers/esx/server.lua',
    'modules/framework/providers/qbcore/server.lua',
    'modules/framework/providers/qbox/server.lua',
    'modules/**/server/*.lua',
}
