tasks = {}
playerTasks = {}
local ox_inventory = exports.ox_inventory
local GetCurrentResourceName = GetCurrentResourceName()
GlobalState.isGangTasksLoaded = false

CreateThread(function()
	while GetResourceState('ox_inventory') ~= 'started' do Wait(1000) end
    for gangName, gangData in pairs(GangData) do
        local stash = {
            id = gangName .. '_stash',
            label = gangData.label .. ' Stash',
            slots = 1000,
            weight = 1000000,
            owner = false,
            jobs = false
        }      
        exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner, stash.jobs)
        exports.ox_inventory:RegisterStash(gangName ..'_boss_stash', gangData.label .. ' Boss Stash', stash.slots, stash.weight, stash.owner, stash.jobs)
    end
end)


----- CALL BACKS ------
-----------------------

lib.callback.register('eth-gangs:getGangMembers', function(source, gangName)
    local members = {}
    local result = MySQL.query.await('SELECT * FROM users WHERE gang = ?', {gangName})

    if result then
        for i=1, #result, 1 do
            local row = result[i]
            local memberdata = {
                name = row.firstname..' '..row.lastname,
                identifier = row.identifier,
                grade = row.gang_rank,
                gang = {
                    name = row.gang,
                    grade = row.gang_rank,
                }
            }
            -- Correctly insert the member data into the members table
            table.insert(members, memberdata)
        end
    end

    return members
end)


lib.callback.register('eth-gangs:GetPlayerGangPosition', function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local gang_rank = MySQL.scalar.await('SELECT gang_rank FROM users WHERE identifier = ?', {xPlayer.identifier})
    if gang_rank ~= nil then
        return gang_rank
    else
        return false
    end
end)

lib.callback.register('eth-gangs:GetPlayerGang', function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local gang = MySQL.scalar.await('SELECT gang FROM users WHERE identifier = ?', {xPlayer.identifier})
    if gang ~= nil then
        return gang
    else
        return false
    end
end)

lib.callback.register('eth-gangs:getGangAccount', function(source, gangName)
    local gangFunds = MySQL.scalar.await('SELECT gangFunds FROM `eth-gangs` WHERE name = ?', {gangName})
    return gangFunds
end)



RegisterServerEvent('eth-gangs:AddNewMember')
AddEventHandler('eth-gangs:AddNewMember', function(target, gangName)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromId(target)
    if xPlayer == nil then return end
    if xTarget == nil then
        TriggerClientEvent('eth-gangs:Notify',_source, 'error', 'Player not online!')
        return 
    end
    if not CheckPlayerisGang(xTarget.source, gangName) then
        TriggerClientEvent('eth-gangs:Notify',_source, 'error', 'The person you are trying to invite is already a member of a gang.')
        return
    end

    MySQL.update('UPDATE users SET gang = ?, gang_rank = ? WHERE identifier = ?', {gangName, '0' , xTarget.identifier}, function(affectedRows)
        if affectedRows then
            TriggerClientEvent('esx:setGang' , xTarget.source , gangName , '0')
            TriggerClientEvent('eth-gangs:Notify',xPlayer.source, 'success', 'You hired '..xTarget.name..'!')
            TriggerClientEvent('eth-gangs:Notify',xTarget.source, 'success', 'You were hired in the gang by '..xPlayer.name)
        end
    end)
end)

RegisterServerEvent('eth-gangs:LeaveGang')
AddEventHandler('eth-gangs:LeaveGang', function(gangName)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer == nil then return end
    MySQL.update('UPDATE users SET gang = ?, gang_rank = ? WHERE identifier = ?', {'none', '0', xPlayer.identifier}, function(affectedRows)
        if affectedRows then
            TriggerClientEvent('eth-gangs:Notify',xPlayer.source, 'error', 'You left the gang!')
            TriggerClientEvent('esx:setGang' , xTarget.source , 'none' , '0')
        end
    end)
end)

RegisterServerEvent('eth-gangs:KickMember')
AddEventHandler('eth-gangs:KickMember', function(gangName, identifier, membername)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer == nil then return end
    MySQL.update('UPDATE users SET gang = ?, gang_rank = ? WHERE identifier = ?', {'none', '0', identifier}, function(affectedRows)
        if affectedRows then
            TriggerClientEvent('eth-gangs:Notify',xPlayer.source, 'success', 'You kicked '..membername..' out of the gang!')
            if xTarget ~= nil then
                --xTarget.triggerEvent('esx:setGang', 'none', '0')
                TriggerClientEvent('esx:setGang' , xTarget.source , 'none' , '0')
            end
        end
    end)
end)

RegisterServerEvent('eth-gangs:PromoteMember')
AddEventHandler('eth-gangs:PromoteMember', function(gangName, identifier, membername)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer == nil then return end
    print(gangName, identifier, membername)
    -- Retrieve current gang rank first
    MySQL.query('SELECT gang_rank FROM users WHERE identifier = ?', {identifier}, function(result)
        if result and result[1] then
            local currentRank = tonumber(result[1].gang_rank)
            if currentRank then
                local newRank = currentRank + 1
                print(newRank)
                MySQL.update('UPDATE users SET gang = ?, gang_rank = ? WHERE identifier = ?', {gangName, newRank, identifier}, function(affectedRows)
                    if affectedRows then
                        TriggerClientEvent('eth-gangs:Notify',xPlayer.source, 'success', 'You promoted '..membername..' to rank '..GetPositionLabel(newRank,gangName)..' in the gang!')
                        
                        if xTarget ~= nil then
                            --xTarget.triggerEvent('esx:setGang', gangName, newRank)
                            TriggerClientEvent('esx:setGang' , xTarget.source , gangName , tostring(newRank))
                        end
                        
                    else
                        print('[^4ETH-GANGS^0]: Error Code. Line 386')
                    end
                end)
            else
                print('[^4ETH-GANGS^0]: Error - Invalid rank value.')
            end
        else
            print('[^4ETH-GANGS^0]: Error - Member not found.')
        end
    end)
end)


RegisterServerEvent('eth-gangs:DemoteMember')
AddEventHandler('eth-gangs:DemoteMember', function(gangName, identifier, membername)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer == nil then return end

    MySQL.query('SELECT gang_rank FROM users WHERE identifier = ?', {identifier}, function(result)
        if result and result[1] then
            local currentRank = tonumber(result[1].gang_rank)

            if currentRank then
    
                local newRank = currentRank - 1
                local newGangName = gangName
                local isDemotedOut = false

                if newRank < 0 then
                    newRank = 0
                    newGangName = 'none'
                    isDemotedOut = true
                end

                MySQL.update('UPDATE users SET gang = ?, gang_rank = ? WHERE identifier = ?', {newGangName, newRank, identifier}, function(affectedRows)
                    if affectedRows then
                        if isDemotedOut then
                            TriggerClientEvent('eth-gangs:Notify',xPlayer.source, 'success', 'You have removed '..membername..' from the gang!')
                        else
                            TriggerClientEvent('eth-gangs:Notify',xPlayer.source, 'success', 'You demoted '..membername..' to rank '..GetPositionLabel(newRank,gangName)..' in the gang!')
                        end

                        if xTarget ~= nil then
                            --xTarget.triggerEvent('esx:setGang', newGangName, newRank)
                            TriggerClientEvent('esx:setGang' , xTarget.source , gangName , tostring(newRank))
                        end
                    else
                        print('[^4ETH-GANGS^0]: Error Code. Line 400')
                    end
                end)
            else
                print('[^4ETH-GANGS^0]: Error - Invalid rank value.')
            end
        else
            print('[^4ETH-GANGS^0]: Error - Member not found.')
        end
    end)
end)




RegisterServerEvent('eth-gangs:DepositSocietyFunds')
AddEventHandler('eth-gangs:DepositSocietyFunds', function(gangName, Amount)
    local _source = source
    local funds = GetGangFunds(gangName)
    local MoneyCount = ox_inventory:Search(_source, 'count', 'money')
    if MoneyCount >= Amount then
        MySQL.update('UPDATE `eth-gangs` SET gangFunds = ? WHERE name = ?', {funds + Amount, gangName}, function(affectedRows) end)
        ox_inventory:RemoveItem(_source, 'money', Amount)
        TriggerClientEvent('eth-gangs:Notify',_source, 'success',  string.format('you have deposited $%s', ESX.Math.GroupDigits(Amount)))
    
    else
        TriggerClientEvent('eth-gangs:Notify',_source, 'error',  'You don\'t have $'..ESX.Math.GroupDigits(Amount))
    end
end)

RegisterServerEvent('eth-gangs:WithdrawSoceityFunds')
AddEventHandler('eth-gangs:WithdrawSoceityFunds', function(gangName, Amount)
    local _source = source
    local funds = GetGangFunds(gangName)
    if funds >= Amount then
        MySQL.update('UPDATE `eth-gangs` SET gangFunds = ? WHERE name = ?', {funds - Amount, gangName}, function(affectedRows) end)
        ox_inventory:AddItem(_source, 'money', Amount)
        TriggerClientEvent('eth-gangs:Notify',_source, 'success',  string.format('you have withdrawn $%s', ESX.Math.GroupDigits(Amount)))
    else
        TriggerClientEvent('eth-gangs:Notify',_source, 'error', 'Insufficent balance.')
    end
end)




RegisterServerEvent('eth-gangs:GetPlayerGang')
AddEventHandler('eth-gangs:GetPlayerGang', function(gangName, Amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local gangName = GetPlayerGang(_source)
    local gang_rank = GetPlayerGangPosition(_source)
    xPlayer.triggerEvent('esx:setGang', gangName , gang_rank) 
    print("[ETH-GANGS] "..GetPlayerName(_source).." has joined gang "..gangName.." with rank "..GetPositionLabel(gang_rank,gangName))
end)




-- AddEventHandler('esx:playerLoaded', function(player, xPlayer, isNew)
--     local gangName = GetPlayerGang(xPlayer.source)
--     local gang_rank = GetPlayerGangPosition(xPlayer.source)
--     xPlayer.triggerEvent('esx:setGang', gangName , gang_rank) 
--     if not isNew then
--         print("[ETH-GANGS] "..GetPlayerName(xPlayer.source).." has joined gang "..gangName.." with rank "..GetPositionLabel(gang_rank,gangName))
--     end
-- end)