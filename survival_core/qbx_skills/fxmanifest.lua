fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Jules'
description 'Once Human-inspired Multi-Skill Upgrade Engine for Qbox'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/shared.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

exports {
    'AddXP',
    'GetSkillState',
    'HasNodeUnlocked',
    'HasNodeUnlockedClient'
}
