# to load a gang like esx:setjob

```lua
-- Client side only
RegisterNetEvent('esx:setGang')
AddEventHandler('esx:setGang', function(gang, gang_rank)
	ESX.PlayerData.gang = gang
    ESX.PlayerData.gang_rank = gang_rank
end)
```