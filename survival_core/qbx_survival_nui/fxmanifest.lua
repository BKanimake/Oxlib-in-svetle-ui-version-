fx_version 'cerulean'
game 'gta5'
ui_page 'web/dist/index.html'

author 'Jules'
description 'Svelte SPA Single Page Frontend for Skills, Crafting, and Sanity HUD'
version '1.0.0'

files {
    'web/dist/index.html',
    'web/dist/assets/*.*'
}

client_scripts {
    'client/main.lua'
}

exports {
    'OpenUI',
    'OpenCraftingUI',
    'UpdateSanity',
    'UpdateSkills'
}
