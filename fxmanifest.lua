game 'gta5'
fx_version 'cerulean'

lua54 'yes'

name 'DAdminMenu'
author '.dark0toto'

dependencies {
    "ox_inventory",
    "ox_lib",
    "oxmysql",
}

shared_scripts {
    "@ox_lib/init.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server.lua"
}

client_scripts {
    "RageUI/RMenu.lua",
    "RageUI/menu/RageUI.lua",
    "RageUI/menu/Menu.lua",
    "RageUI/menu/MenuController.lua",
    "RageUI/components/*.lua",
    "RageUI/menu/elements/*.lua",
    "RageUI/menu/items/*.lua",
    "RageUI/menu/panels/*.lua",
    "RageUI/menu/windows/*.lua",
    
    "functions.lua",
    "client.lua"
}