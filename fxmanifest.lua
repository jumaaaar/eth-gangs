fx_version 'cerulean'
games {'gta5'}
author 'Ethereal'
description 'Ethereal Gang Scripts'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua', 
    '@es_extended/imports.lua' , 
    'shared/gangs.lua',
}


client_scripts{
    -- Config --
    'client/gangs.lua',
    'client/garage.lua',
    'config/config.lua',
    'config/notify.lua',
    'client/modules/exports.lua'
}

server_scripts{
    -- Core --
    '@oxmysql/lib/MySQL.lua',

    -- Config --
    'config/config.lua',
    'server/modules/callbacks.lua',
    'server/modules/commands.lua',
    'server/modules/commands.lua',
    'server/gangs.lua',


}
