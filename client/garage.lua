local ESX = exports['es_extended']:getSharedObject()
local PlayerData = {gang = "none", gang_rank = "none"}
local currentAction = "none"

-- Use a single event handler for player loaded and gang update
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


local function createMenu(menuItems)
    exports['cfx-hu-menu']:openMenu(menuItems)
end

local function GangVehicleMenu()
    createMenu({
        {header = "Gang Vehicle", icon = "fab fa-whmcs", isMenuHeader = true},
        {header = "Vehicle List", txt = "  ", icon = "fas fa-car", params = {event = "eth-gangs:client:VehicleList"}},
        {header = "Store Vehicle", txt = "  ", icon = "fas fa-arrow-right-to-bracket", params = {event = "eth-gangs:client:VehicleDelete"}},
        {header = "Close", txt = "", icon = "fas fa-circle-right", params = {event = "cfx-hu-menu:closeMenu"}}
    })
end

RegisterNetEvent("eth-gangs:client:VehicleList")
AddEventHandler("eth-gangs:client:VehicleList", function()
    local VehicleList = {{header = " Vehicle List", icon = "fab fa-whmcs", isMenuHeader = true}}
    for k, v in pairs(GangData[PlayerData.gang]["VehicleActions"]["vehicles"]) do
        table.insert(VehicleList, {
            header = v,
            icon = "fas fa-circle",
            params = {event = "eth-gangs:client:SpawnListVehicle", args = k}
        })
    end
    table.insert(VehicleList, {
        header = "Close",
        txt = "",
        icon = "fas fa-circle-xmark",
        params = {event = "cfx-hu-menu:closeMenu"}
    })
    createMenu(VehicleList)
end)

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
                lib.showTextUI('[E] Gang Garage', {
                    position = "left-center",
                })

    
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



RegisterNetEvent("eth-gangs:client:VehicleDelete")
AddEventHandler("eth-gangs:client:VehicleDelete", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    if vehicle ~= 0 then DeleteVehicle(vehicle) end
end)

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