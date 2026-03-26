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
    'modules/**/client/*.lua'
}

server_scripts {
    'modules/**/server/*.lua'
}
