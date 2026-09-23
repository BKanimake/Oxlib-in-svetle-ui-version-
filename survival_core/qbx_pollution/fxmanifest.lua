fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Jules'
description 'Once Human Stardust Pollution & Sanity System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua'
}

exports {
    'GetSanity',
    'SetSanity'
}
