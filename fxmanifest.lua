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
    'config.lua',
    'config/client_config.lua',
    'shared/gangs.lua',
    'client/modules/exports.lua',
    -- Files --
    'client/**/*.lua'
}

server_scripts{
    -- Core --
    '@oxmysql/lib/MySQL.lua',

    -- Config --
    'config.lua',
    'config/server_config.lua',

    -- Files --
    'server/**/*.lua',
    'shared/gangs.lua',
--     -- Modules --
--     'server/modules/callbacks.lua',
--     'server/modules/commands.lua',
--     'server/modules/exports.lua'
}
