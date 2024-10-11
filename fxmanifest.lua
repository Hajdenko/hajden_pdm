fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'hajdenkoo'
description 'Advanced PDM using ox_lib for ESX'
version '1.0.4'

files {
    'locales/*.json'
}

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'EDIT_ME/cl_config.lua',
    'client/utils.lua',
    'client/vehicleSpawner.lua',
    'client/main.lua'
}

server_scripts {
    '@es_extended/locale.lua',
    '@mysql-async/lib/MySQL.lua',
    'EDIT_ME/sv_config.lua',
    'server/plate.lua',
    'server/db.lua',
    'server/main.lua',
    'server/utils.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}
