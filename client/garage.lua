local ESX = exports['es_extended']:getSharedObject()
local PlayerData = {gang = "none", gang_rank = "none"}
local currentAction = "none"

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:setGang')
AddEventHandler('esx:setGang', function(gang, gang_rank)
    PlayerData.gang = gang
    PlayerData.gang_rank = gang_rank
end)

-- Function to create and show the menu using ox_lib
local function createMenu(menuItems)
    lib.registerContext({
        id = 'gang_vehicle_menu',
        title = 'Gang Vehicle',
        options = menuItems
    })
    lib.showContext('gang_vehicle_menu')
end

-- Gang Vehicle Menu
local function GangVehicleMenu()
    createMenu({
        {title = "Vehicle List", description = "View available vehicles", icon = "fas fa-car", event = "eth-gangs:client:VehicleList"},
        {title = "Store Vehicle", description = "Store the current vehicle", icon = "fas fa-arrow-right-to-bracket", event = "eth-gangs:client:VehicleDelete"},
        {title = "Close", icon = "fas fa-circle-right"}
    })
end

-- Vehicle List Menu
RegisterNetEvent("eth-gangs:client:VehicleList")
AddEventHandler("eth-gangs:client:VehicleList", function()
    local VehicleList = {}
    for k, v in pairs(GangData[PlayerData.gang]["VehicleActions"]["vehicles"]) do
        table.insert(VehicleList, {
            title = v,
            icon = "fas fa-circle",
            event = "eth-gangs:client:SpawnListVehicle",
            args = k
        })
    end
    table.insert(VehicleList, {
        title = "Close",
        icon = "fas fa-circle-xmark"
    })
    createMenu(VehicleList)
end)

-- Garage Zone Management
local isInGarage = false
Citizen.CreateThread(function()
    for gangname, data in pairs(GangData) do
        local v = data["VehicleActions"]["coords"]
        lib.zones.box({
            coords = vector3(v.x, v.y, v.z),
            size = vec3(10, 10, 3),
            rotation = v.h,
            debug = false,  
            onEnter = function()
                isInGarage = true
                lib.showTextUI('[E] Gang Garage', {position = "left-center"})
                Citizen.CreateThread(function()
                    while isInGarage do
                        Wait(0)
                        if IsControlJustPressed(0, 38) then
                            if PlayerData.gang ~= gangname then
                                TriggerEvent('esx:showNotification', 'error', 5000, "You can't access this", 'GANGS')
                            else
                                GangVehicleMenu()
                            end
                        end
                    end
                end)
            end,
            onExit = function()
                lib.hideTextUI()
                isInGarage = false
            end
        })
    end
end)

-- Vehicle Deletion
RegisterNetEvent("eth-gangs:client:VehicleDelete")
AddEventHandler("eth-gangs:client:VehicleDelete", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    if vehicle ~= 0 then DeleteVehicle(vehicle) end
end)

-- Vehicle Spawning
RegisterNetEvent("eth-gangs:client:SpawnListVehicle")
AddEventHandler("eth-gangs:client:SpawnListVehicle", function(model)
    local coords = GangData[PlayerData.gang]["VehicleActions"]["coords"]
    ESX.Game.SpawnVehicle(model, vector3(coords.x, coords.y, coords.z), coords.w, function(veh)
        ESX.Game.SetVehicleProperties(veh, model)
        SetEntityHeading(veh, coords.w)
        SetVehicleColours(veh, GangData[PlayerData.gang]["VehicleActions"]["colors"][1], GangData[PlayerData.gang]["VehicleActions"]["colors"][2])
        SetVehicleEngineOn(veh, true, true)
        SetVehicleDirtLevel(veh, 0.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    end)
end)
