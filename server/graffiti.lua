ESX = exports['es_extended']:getSharedObject()

lib.callback.register("eth-gangs:server:getGangCounts", function(source, gang)
    return tonumber(getGangCount(gang))
end)


CreateThread(function()
    MySQL.query('SELECT `key`, `owner`, `model`, `coords`, `rotation` FROM `graffitis`', {}, function(result)
        if result and #result > 0 then
            for _, v in pairs(result) do
                if v then
                    local coords = json.decode(v.coords)
                    local rotation = json.decode(v.rotation)
                    local graffitiData = {
                        id = v.key,
                        model = tostring(v.model),
                        coords = vector3(tonumber(string.format("%.2f", coords.x)), tonumber(string.format("%.2f", coords.y)), tonumber(string.format("%.2f", coords.z))),
                        rotation = vector3(tonumber(string.format("%.2f", rotation.x)), tonumber(string.format("%.2f", rotation.y)), tonumber(string.format("%.2f", rotation.z))),
                        gang = v.owner,
                        blipcolor = GetGangBlipColor(v.owner)
                    }
                    Config.Graffitis[v.key] = graffitiData
                end
            end
        end
    end)
end)

lib.callback.register("eth-gangs:server:getGraffitiData", function(source, gang)
    return Config.Graffitis
end)

function generateGraffitiID()
	local id = math.random(111, 999).."-ETH-" .. math.random(111, 999)
	
	while Config.Graffitis[id] ~= nil do
		id = math.random(111, 999).."-ETH-" .. math.random(111, 999)
	end
	
	return id
end

local function getGraffiti(gangName)
	for k, v in pairs(Config.Sprays) do
		if v.gang == gangName then
			return k, v
		end
	end
	
	return false
end 


RegisterServerEvent("eth-gangs:server:notifyGangMember", function(gang, location, coords)
    local gangData = GangData[gang]
    
    if not gangData then 
        return
    end

	local message = string.format("Homies, heads up! Our graffiti in %s is being removed. Time to rally and defend our art!", location)
	local subject = gangData['label']
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        local PlayerGang = GetPlayerGang(playerId)
        if PlayerGang == gang then
            TriggerClientEvent('phone:addnotification', xPlayer.source, subject, message)
        end
    end
end)

RegisterServerEvent('eth-gangs:client:addServerGraffiti', function(model, coords, rotation, gang)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    
    if player then
        local id = generateGraffitiID()
        local gangData = GangData[gang]

        if gangData then

            local roundedCoords = vector3(tonumber(string.format("%.2f", coords.x)), tonumber(string.format("%.2f", coords.y)), tonumber(string.format("%.2f", coords.z)))
            local roundedRotation = vector3(tonumber(string.format("%.2f", rotation.x)), tonumber(string.format("%.2f", rotation.y)), tonumber(string.format("%.2f", rotation.z)))

            MySQL.insert('INSERT INTO `graffitis` (`key`, `owner`, `model`, `coords`, `rotation`) VALUES (@key, @owner, @model, @coords, @rotation)', {
                ['@key'] = id,
                ['@owner'] = gang,
                ['@model'] = tostring(model),
                ['@coords'] = json.encode(roundedCoords),
                ['@rotation'] = json.encode(roundedRotation)
            }, function(key)

                local graffitiData = {
                    id = id,
                    model = tostring(model),
                    coords = coords,
                    rotation = rotation,
                    gang = gang,
                    blipcolor = GetGangBlipColor(gang)
                }
    
                Config.Graffitis[id] = graffitiData        
                TriggerClientEvent('eth-gangs:client:updateGraffitiData', -1, id, Config.Graffitis[id], true)
            end)
        end
    end
end)


RegisterServerEvent('eth-gangs:server:removeServerGraffitiByID', function(id)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
	
	if not Config.Graffitis[id] then return end

    MySQL.query('DELETE from graffitis WHERE `key` = ?', {
        id
    }, function(response)
        if response then
            Config.Graffitis[id] = nil	
            TriggerClientEvent('eth-gangs:client:updateGraffitiData', -1, id, {}, false)
        end
    end)
end)


RegisterServerEvent('eth-gangs:server:Graffitishop', function(pTarget, pContext)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    if Player then
		local moneyCount = exports.ox_inventory:Search(src, 'count', 'money')
		
		if moneyCount >= pContext.price then
			print(pContext.gang)
			exports.ox_inventory:RemoveItem(src, 'money', pContext.price)

			exports.ox_inventory:AddItem(src, 'spraycan', 1, {
                model = pContext.model,
                name = pContext.name,
				gang = pContext.gang
            })
			
			Notify(src, 'success', 'You bought a graffiti can for $'..pContext.price..' with the name: '..pContext.name)		
		else
            local morePrice = pContext.price - moneyCount
			Notify(src, 'success', 'You not have enough money. You need more '..morePrice)							
		end
    end
end)


-- ITEMS

ESX.RegisterUsableItem('spraycan', function(source, item, info)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    if Player then
        if info.metadata then			
            TriggerClientEvent('eth-gangs:client:placeGraffiti', source, info.metadata.gang, info.metadata.model, info.slot)
        else
			Notify(src, 'error', 'Seems like I can\'t do that at the moment...', 5000, 'red')     	       
        end
    end
end)

ESX.RegisterUsableItem('sprayremover', function(source, item, info)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    if Player then
		-- if getGangCount(info.metadata.gang) < 4 then
		-- 	return Notify(src, 'error', 'Yo, your crew’s too small for this job. Get more members!', 5000, 'red')	      
		-- end	
		
        TriggerClientEvent('eth-gangs:client:removeClosestGraffiti', source, info.slot)
    end
end)


RegisterServerEvent('eth-gangs:server:removeServerItem', function(item, amount, slot)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    if Player then
        if slot then
			exports.ox_inventory:RemoveItem(Player.source, item, amount, nil, slot)
        else
            exports.ox_inventory:RemoveItem(Player.source, item, amount)
        end
    end
end)