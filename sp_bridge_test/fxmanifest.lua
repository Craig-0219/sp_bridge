fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'sp_bridge_test'
description 'Automated test runner for sp_bridge'
version     '1.0.0'

dependencies { 'sp_bridge' }

shared_scripts {
    'config.lua',
}

server_scripts {
    'server/util.lua',
    'server/runner.lua',
    'server/tests_framework.lua',
    'server/tests_inventory.lua',
    'server/tests_qbox.lua',
    'server/main.lua',
}

client_scripts {
    'client/probe.lua',
    'client/main.lua',
}
