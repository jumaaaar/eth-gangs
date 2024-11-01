local ox_inventory = exports.ox_inventory
local ESX = exports["es_extended"]:getSharedObject()
local PlayerData = {gang = "none", gang_rank = "none"}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
    TriggerServerEvent('eth-gangs:GetPlayerGang')
    SetupZones()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setGang')
AddEventHandler('esx:setGang', function(gang, gang_rank)
    PlayerData.gang = gang
    PlayerData.gang_rank = gang_rank
end)

local lastActionTime = 0
local COOLDOWN_TIME = 3000 -- 3 seconds cooldown

local function CanPerformAction()
    local currentTime = GetGameTimer()
    if (currentTime - lastActionTime) < COOLDOWN_TIME then
        local remainingTime = math.ceil((COOLDOWN_TIME - (currentTime - lastActionTime)) / 1000)
        Notify('error', ('You must wait %d seconds'):format(remainingTime))
        return false
    end
    lastActionTime = currentTime
    return true
end

local function OpenStashMenu(StashID)
    print(StashID .. "_stash")
    ox_inventory:openInventory('stash', { id = StashID .. "_stash" })
end

local function OpenGangBossAction(gangName, isBoss)
    if not isBoss then
        return Notify('error', 'You are not authorized to use this action.')
    end

    local gangFunds = lib.callback.await('eth-gangs:getGangAccount', false, gangName)
    
    lib.registerContext({
        id = 'menu_boss_action',
        title = 'Boss Action',
        options = {
            {
                title = ('Society Funds $%s'):format(ESX.Math.GroupDigits(gangFunds)),
                description = 'Open Society Action',
                event = 'eth-gangs:GangActions',
                args = { gangFunds = gangFunds, gangName = gangName, value = 'society_action' }
            },
            {
                title = 'Buy Items',
                description = 'Buy Weapon / items',
                event = 'eth-gangs:GangActions',
                args = { gangName = gangName, value = 'buy_items' }
            },
            {
                title = 'Boss Stash',
                description = 'Open Boss Stash',
                event = 'eth-gangs:GangActions',
                args = { gangFunds = gangFunds, gangName = gangName, value = 'boss_stash' }
            },
            {
                title = 'Gang Members',
                description = 'Open Gang Members Action',
                event = 'eth-gangs:GangActions',
                args = { gangName = gangName, value = 'gang_members_actions' }
            },
            {
                title = 'Invite Members',
                description = 'Open Invite Members Actions',
                event = 'eth-gangs:GangActions',
                args = { gangName = gangName, value = 'invite_members_action' }
            },
        },
    })
    lib.showContext('menu_boss_action')
end

function SetupZones()
    local inStashZone = false
    local inBossActionZone = false
    Citizen.CreateThread(function()
        for gangname, data in pairs(GangData) do
            local stashZones = data["StashLocation"]
            lib.zones.box({
                coords = vector3(stashZones.x, stashZones.y, stashZones.z),
                size = vec3(1, 1, 1),
                debug = false,  
                onEnter = function()
                    inStashZone = true
                    lib.showTextUI('[E] Stash', {position = "left-center"})
                    Citizen.CreateThread(function()
                        while inStashZone do
                            Wait(0)
                            if IsControlJustPressed(0, 38) then
                                if PlayerData.gang ~= gangname then
                                    TriggerEvent('esx:showNotification', 'error', 5000, "You can't access this", 'GANGS')
                                else
                                    OpenStashMenu(PlayerData.gang)
                                end
                            end
                        end
                    end)
                end,
                onExit = function()
                    lib.hideTextUI()
                    inStashZone = false
                end
            })

            --- BOSS ACTIONS
            local bossActionZone = data["BossActionLocation"]
            lib.zones.box({
                coords = vector3(bossActionZone.x, bossActionZone.y, bossActionZone.z),
                size = vec3(1, 1, 1),
                debug = false,  
                onEnter = function()
                    inBossActionZone = true
                    lib.showTextUI('[E] Boss Actions', {position = "left-center"})
                    Citizen.CreateThread(function()
                        while inBossActionZone do
                            Wait(0)
                            if IsControlJustPressed(0, 38) then
                                if PlayerData.gang == gangname and isGangBoss(PlayerData.gang, PlayerData.gang_rank) then
                                    OpenGangBossAction(PlayerData.gang, true)
                                else
                                    TriggerEvent('esx:showNotification', 'error', 5000, "You can't access this", 'GANGS')
                                end
                            end
                        end
                    end)
                end,
                onExit = function()
                    lib.hideTextUI()
                    inBossActionZone = false
                end
            })
        end
    end)
end




RegisterNetEvent('eth-gangs:GangActions')
AddEventHandler('eth-gangs:GangActions', function(data)
    local actions = {
        society_action = function()
            lib.registerContext({
                id = 'society_action_menu',
                title = 'Society Action',
                options = {
                    {
                        title = 'Withdraw Society Funds',
                        description = ('Your Current Society Funds $%s'):format(ESX.Math.GroupDigits(data.gangFunds)),
                        event = 'eth-gangs:SocietyFundsAction',
                        args = { action = 'withdraw', gangFunds = data.gangFunds, gangName = data.gangName }
                    },
                    {
                        title = 'Deposit Society Funds',
                        description = ('Your Current Society Funds $%s'):format(ESX.Math.GroupDigits(data.gangFunds)),
                        event = 'eth-gangs:SocietyFundsAction',
                        args = { action = 'deposit', gangFunds = data.gangFunds, gangName = data.gangName }
                    }
                },
            })
            lib.showContext('society_action_menu')
        end,
        buy_items = function()
            local ItemLists = {}
            for k, v in pairs(GangData[PlayerData.gang]["ItemShop"]) do
                table.insert(ItemLists, {
                    title = v.title .. " - " .. "$" ..ESX.Math.GroupDigits(v.price),
                    serverEvent = "eth-gangs:server:BuyItems",
                    args = { itemName = v.name , itemCost = v.price}
                })
            end
            lib.registerContext({
                id = 'gang_buy_items',
                title = 'Buy Items',
                options = ItemLists
            })
            lib.showContext('gang_buy_items')
        end,
        gang_members_actions = function()
            lib.callback('eth-gangs:getGangMembers', false, function(members)
                local options = {}
                for _, member in ipairs(members) do
                    table.insert(options, {
                        title = ('Name: %s'):format(member.name),
                        description = ('Grade: %s'):format(GangData[member.gang.name]['grades'][tostring(member.grade)]['name']),
                        event = 'eth-gangs:OpenMembersAction',
                        args = {
                            gang = member.gang.name,
                            identifier = member.identifier,
                            name = member.name,
                            grade = member.grade
                        }
                    })
                end
                lib.registerContext({
                    id = 'current_gang_members',
                    title = 'Gang Members',
                    options = options
                })
                lib.showContext('current_gang_members')
            end, data.gangName)
        end,
        invite_members_action = function()
            local input = lib.inputDialog('Invite Member', {'Player ID'})
            if input and input[1] then
                local playerId = tonumber(input[1])
                if playerId then
                    TriggerServerEvent('eth-gangs:AddNewMember', playerId, data.gangName)
                else
                    Notify('error', 'Invalid Player ID')
                end
            end
        end,
        boss_stash = function()
            ox_inventory:openInventory('stash', data.gangName .. '_boss_stash')
        end
    }

    local action = actions[data.value]
    if action then action() end
end)

RegisterNetEvent('eth-gangs:LeaveGang')
AddEventHandler('eth-gangs:LeaveGang', function(GangName)
    local alert = lib.alertDialog({
        header = 'Leave Gang',
        content = 'Are you sure you want to leave the gang?',
        centered = true,
        cancel = true
    })
    
    if alert == 'confirm' then
        TriggerServerEvent('eth-gangs:LeaveGang', GangName)
    end
end)

RegisterNetEvent('eth-gangs:OpenMembersAction')
AddEventHandler('eth-gangs:OpenMembersAction', function(data)
    lib.registerContext({
        id = 'member_action',
        title = 'Member Actions',
        options = {
            {
                title = 'Kick Action',
                description = 'Kick this member',
                event = 'eth-gangs:MemberAction',
                args = { action = 'kick', data = data }
            },
            {
                title = 'Demote Action',
                description = 'Demote this member',
                event = 'eth-gangs:MemberAction',
                args = { action = 'demote', data = data }
            },
            {
                title = 'Promote Action',
                description = 'Promote this member',
                event = 'eth-gangs:MemberAction',
                args = { action = 'promote', data = data }
            }
        },
    })
    lib.showContext('member_action')
end)

RegisterNetEvent('eth-gangs:MemberAction')
AddEventHandler('eth-gangs:MemberAction', function(actionData)
    local actions = {
        kick = function(data)
            TriggerServerEvent('eth-gangs:KickMember', data.gang, data.identifier, data.name)
        end,
        promote = function(data)
            TriggerServerEvent('eth-gangs:PromoteMember', data.gang, data.identifier, data.name, 1)
        end,
        demote = function(data)
            TriggerServerEvent('eth-gangs:DemoteMember', data.gang, data.identifier, data.name, 1)
        end
    }

    local action = actions[actionData.action]
    if action then action(actionData.data) end
end)

RegisterNetEvent('eth-gangs:SocietyFundsAction')
AddEventHandler('eth-gangs:SocietyFundsAction', function(data)
    local input = lib.inputDialog(('%s Society Funds'):format(data.action:gsub("^%l", string.upper)), {'Amount'})
    if not input or not input[1] then return end

    local amount = tonumber(input[1])
    if not amount or amount <= 0 then
        return Notify('error', 'Invalid Amount.')
    end

    if data.action == 'withdraw' then
        TriggerServerEvent('eth-gangs:WithdrawSoceityFunds', data.gangName, amount)
    elseif data.action == 'deposit' then
        local moneyCount = ox_inventory:Search('count', 'money')
        if moneyCount >= amount then
            TriggerServerEvent('eth-gangs:DepositSocietyFunds', data.gangName, amount)
        else
            Notify('error', ('You must have $%s to proceed with this action!'):format(ESX.Math.GroupDigits(amount)))
        end
    end
end)

-- Blips Creation
Citizen.CreateThread(function()
    for gangName, gangData in pairs(GangData) do
        if gangName ~= "none" then
            local blipPos = gangData.BossActionLocation
            local radiusBlip = AddBlipForRadius(blipPos, 50.0)
            local blip = AddBlipForCoord(blipPos.x, blipPos.y, blipPos.z)
            
            SetBlipSprite(blip, 378)
            SetBlipScale(blip, 0.6)
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, 1)
            
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(gangData.label)
            EndTextCommandSetBlipName(blip)
            
            SetBlipColour(radiusBlip, gangData.blipColor)
            SetBlipAlpha(radiusBlip, 128)
        end
    end
end)

