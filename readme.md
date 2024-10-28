# PlayerGangs for ESX
Simple Gang Script for ESX

# Features
* Vehicle System(You can set Gang Car on Config)
* Boss Actions and Gang Funds
* Stashes
* Blips for each Gang Locations
* Ox Inventory Ready
* Easy to Configure

# Short Showcase
* [video](https://youtu.be/Q0a4BnBR0w8)

# Requirements
* [ESX](https://documentation.esx-framework.org/legacy/installation/)
* [ox_lib](https://github.com/overextended/ox_lib)
* [ox_inventory](https://github.com/overextended/ox_inventory)

# Commands
```
/setgang [id] [gangName] [gangRank] - You can see ranks and gang names on shared/gangs.lua
/leavegang to leave gang
/checkgang to check current gang
```
#Configure Gangs
* You can set gangs in shared/gangs.lua
* example config below
```
    santo = {
        label = 'S A N T O',
        grades = {
            ['0'] = { name = 'ASSOCIADO' },
            ['1'] = { name = 'CARNAL' },
            ['2'] = { name = 'CHAPO' },
            ['3'] = { name = 'OG' },
            ['4'] = { name = 'SENIORES', isboss = true },
        },
        ["blipColor"] = 38,
        ["StashLocation"] = vec3(-16.97, -1440.79, 31.1),
        ["BossActionLocation"] = vec3(-10.75, -1440.64, 31.1),
        ["VehicleActions"] = {
            ["coords"] =  vec4(-24.31, -1436.46, 30.65, 183.32),
            ["colors"] =  { 83, 0 },
            ["vehicles"] = {
                ["jugular"] = "Jugular",
                
            },

        }
    },

```



# to load a gang like setjob
```lua
-- Client side only
local PlayerData = {gang = "none", gang_rank = "none"}

RegisterNetEvent('esx:setGang')
AddEventHandler('esx:setGang', function(gang, gang_rank)
    PlayerData.gang = gang
    PlayerData.gang_rank = gang_rank
end)

```