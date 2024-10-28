local gangTasksCFG = {
	[1] = {
		instructions = "Acquire %s recyclable materials that can be recycled.",
		rate = 500,
		max_rate = 10000,
	},
	
	[2] = { 
		instructions = "Punch cops %s times.",
		rate = 40,
		max_rate = 50,
	},
	
	[3] = { 
		instructions = "Punch mechanics %s times.",
		rate = 40,
		max_rate = 50,
	},
	
	[4] = { 
		instructions = "Punch ems %s times.",
		rate = 40,
		max_rate = 50,
	},
	
	-- [5] = { 
	-- 	instructions = "Kill %s cops.",
	-- 	rate = 2,
	-- 	max_rate = 50,
	-- },
	
	[5] = { 
		instructions = "Unlock doors using thermite %s times.",
		rate = 5,
		max_rate = 50,
	},

	[6] = { 
		instructions = "Rob small stores %s times.",
		rate = 5,
		max_rate = 10,
	},

	[7] = { 
		instructions = "Rob Jewerly Store %s times.",
		rate = 5,
		max_rate = 8,
	},

	[8] = { 
		instructions = "Search in house robbery %s times.",
		rate = 20,
		max_rate = 400,
	},

	-- [10] = { 
	-- 	instructions = "Be the first one to open the plane crashed crate %s times.",
	-- 	rate = 5,
	-- 	max_rate = 30,
	-- },

	[9] = { 
		instructions = "Be the first one to open the Bucaneer shipment container %s times.",
		rate = 5,
		max_rate = 10,
	},
	
	-- [11] = { 
	-- 	instructions = "Rob Humane Lab %s times.",
	-- 	rate = 5,
	-- 	max_rate = 8,
	-- },	
	
	-- [12] = { 
	-- 	instructions = "Rob Warship %s times.",
	-- 	rate = 5,
	-- 	max_rate = 8,
	-- },	

	[10] = { 
		instructions = "Rob Traphouses %s times.",
		rate = 5,
		max_rate = 8,
	},	

	[11] = { 
		instructions = "Rob Fleeca Bank %s times.",
		rate = 5,
		max_rate = 8,
	},	

	-- [16] = { 
	-- 	instructions = "Rob Lifeinvader %s times.",
	-- 	rate = 5,
	-- 	max_rate = 8,
	-- },	

	[12] = { 
		instructions = "Rob Yacht %s times.",
		rate = 5,
		max_rate = 8,
	},		
}

local cfgreward = {
	'sprayremover',
	'spraycan',
}
local currentTasks = {}


generateGangtasks = function()
    for k, v in pairs(GangData) do
        if k ~= 'none' then
            local currentGangLevel = math.random(1,3)
            local randomTasks = math.random(1, #gangTasksCFG)
            local taskConfig = gangTasksCFG[randomTasks]
            local progress = taskConfig.rate * currentGangLevel
            
            if progress > taskConfig.max_rate then
                progress = taskConfig.max_rate
            end

            local taskData = {
                id = randomTasks,
                instructions = (taskConfig.instructions):format(progress),
                progress = progress,
                completed = 0,
                reward = cfgreward[math.random(#cfgreward)]
            }
            
            if currentTasks[k] == nil then
                currentTasks[k] = taskData
            end

        end
    end
end


RegisterCommand("stasks" , function()
    print(json.encode(currentTasks))
end)

lib.callback.register("eth-gangs:server:GetGangTasks", function(source, gang)
    return currentTasks[gang]
end)

CreateThread(generateGangtasks)


RegisterServerEvent("eth-gangs:server:completeGangTasks", function(gangName)
    local src = source
    local player = ESX.GetPlayerFromId(src)
	
	local gangInfo = GangData[gangName]
	
	if not gangInfo then return end

    local currentGangLevel = math.random(0,20)
	local rewards = currentGangLevel * math.random(50, 70)
	
	AddGangFunds(gangName, rewards)

	if currentTasks[gangName].reward == 'spraycan' then
		local paintModel = GetGangSpray(gangName)
		if paintModel then
			exports.ox_inventory:AddItem(src, currentTasks[gangName].reward, 1, {
				model = tonumber(paintModel),
				name = GetGangLabel(gangName),
				gang = gangName
			})
		end
	else
		exports.ox_inventory:AddItem(src, currentTasks[gangName].reward, 1)
	end
     SNotify(src, 1, "You have completed your gang tasks!")
	currentTasks[gangName] = nil	
end)

local function updateGangProgression(id, player, amount)
	local curGang = GetPlayerGang(player)
	if not curGang then return end
	local gangTasks = currentTasks[curGang]
	if gangTasks and gangTasks.id == id then
		gangTasks.completed = gangTasks.completed + amount
		currentTasks[curGang] = gangTasks
	end
end

-- RegisterCommand('gangTasks', function(source, args)	
-- 	local Player = ESX.GetPlayerFromId(source)
	
-- 	updateGangProgression(1, source, 500)
-- end, false)

exports('updateGangProgression', updateGangProgression)


RegisterServerEvent('eth-gangs:server:updatePunchTasks', function(target)
	local Player = ESX.GetPlayerFromId(target)
	local Target = ESX.GetPlayerFromId(source)
	
	local PGang =  GetPlayerGang(target)
	local TGang =  GetPlayerGang(source)
	
	if PGang then
		if TGang and TGang == PGang then
			return
		end
		
		if Target.job.name == 'police' then
			updateGangProgression(2, Player, 1)
		elseif Target.job.name == 'mechanic' then
			updateGangProgression(3, Player, 1)
		elseif Target.job.name == 'ambulance' then
			updateGangProgression(4, Player, 1)
		end
	end
end)
