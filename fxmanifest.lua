fx_version 'cerulean'
game 'gta5'

description 'Advanced Radio Script for ESX, QBCore, Qbox'
version '1.0.0'

ui_page 'web/dist/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'web/dist/index.html',
    'web/dist/**/*'
}

lua54 'yes'
