fx_version "cerulean"

game "gta5"

server_scripts {
	"server/server.lua",
}

client_scripts {
    "client/client.lua",
    "client/main.lua",
    "@PolyZone/client.lua",
    "@PolyZone/BoxZone.lua",
}

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    '@qb-core/shared/jobs.lua',
}

lua54 "yes"
server_scripts { '@mysql-async/lib/MySQL.lua' }