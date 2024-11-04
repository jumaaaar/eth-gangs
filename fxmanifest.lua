fx_version 'cerulean'
games {'gta5'}
author 'Ethereal'
description 'Ethereal Gang Scripts'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua', 
    '@es_extended/imports.lua' , 
}


client_scripts{
    -- Config --
    'config/config.lua',
    'shared/gangs.lua',
    'client/gangs.lua',
    'client/garage.lua',
    'config/notify.lua',
    'client/modules/exports.lua'
}

server_scripts{
    -- Core --
    'config/config.lua',
    '@oxmysql/lib/MySQL.lua',
    'shared/gangs.lua',
    -- Config --
    'server/modules/callbacks.lua',
    'server/modules/commands.lua',
    'server/modules/exports.lua',
    'server/gangs.lua',
}

