fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Jules'
description 'Grid-based Local Zombie Threat Director & Target Looting'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
