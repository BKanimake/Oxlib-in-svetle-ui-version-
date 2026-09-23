fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Jules'
description 'Tiered Workbenches & Production Engine for Qbox'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/shared.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
