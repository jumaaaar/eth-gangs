lib.__addCommand('group.user', {'leavegang', 'quitgang'}, function(source, args)
    local _source = source
    local GangName = GetPlayerGang(_source)
    if GangName then
        TriggerClientEvent('eth-gangs:LeaveGang', _source, GangName)
    else
        TriggerClientEvent('eth-gangs:Notify', _source, 'error', 'You must have a gang.')
    end
end)

lib.__addCommand('group.admin', {'setgang', 'addgang'}, function(source, args)
    
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTargetID = tonumber(args.target)
    local targetPlayer = ESX.GetPlayerFromId(xTargetID)
    if targetPlayer == nil then TriggerClientEvent('eth-gangs:Notify', _source, 'error', 'Player not online.') return end
    if args.target == nil or args.target == '' or type(xTargetID) ~= 'number' or xTargetID < 0 then TriggerClientEvent('eth-gangs:Notify', _source, 'error', 'Invalid Player ID.') return end
    if not GetGangName(args.gangname) or args.gangname == nil then
        TriggerClientEvent('eth-gangs:Notify', _source, error, 'Invalid Gang Name.')
        return
    end
    if not isValidRank(args.gangname , args.rank ) or args.rank == nil then
        TriggerClientEvent('eth-gangs:Notify', _source, 'error', 'Invalid Gang Rank.')
        return
    end
    if not CheckPlayerisGang(targetPlayer.source, args.gangname) then
        TriggerClientEvent('eth-gangs:Notify', _source, 'error', 'The person you are trying to invite is already a member of a gang.')
        return
    end

    local RankLabel = GangData[args.gangname]['grades'][args.rank]['name']
    MySQL.update('UPDATE users SET gang = ?, gang_rank = ? WHERE identifier = ?', {tostring(args.gangname), tostring(args.rank), targetPlayer.identifier}, function(affectedRows)
        if affectedRows then
            TriggerClientEvent('eth-gangs:Notify', xPlayer.source, 'inform', 'You hired '..targetPlayer.name..'!')
            TriggerClientEvent('eth-gangs:Notify', targetPlayer.source, 'inform', 'You were hired in the '..GetGangLabel(args.gangname)..' as a '..tostring(RankLabel))
            TriggerClientEvent('esx:setGang', targetPlayer.source , args.gangname, args.rank)
        else
            print('[^4CFX-HU-GANG^0]: System Error')
        end
    end)
end, {'target:number', 'gangname:string', 'rank:string'})



local GangLimit = 0
lib.__addCommand('group.user', {'checkgang', 'gang'}, function(source, args)
    local _source = source
    if (GetGameTimer() - GangLimit) < 5000 then 
        TriggerClientEvent('eth-gangs:Notify', _source, 'error', 'You must wait '..(5 - math.floor((GetGameTimer() - GangLimit) / 1000))..' seconds')
        return 
    end
    GangLimit = GetGameTimer()
    local myCurrentGang = GetPlayerGang(_source)
    local myCurrentPosition = GetPlayerGangPosition(_source)
    local Positionlabel = GangData[myCurrentGang]["grades"][myCurrentPosition]["name"]
    local myCurrentGangLabel = nil
    if myCurrentGang ~= 'none' then
        myCurrentGangLabel = GetGangLabel(myCurrentGang)
    else
        myCurrentGangLabel = myCurrentGang
    end
    TriggerClientEvent('eth-gangs:Notify', _source, 'inform', 'Current Gang: '..myCurrentGangLabel..'\nCurrent Gang Rank: '..Positionlabel)
end)


-- lib.__addCommand('group.admin', {'removegang'}, function(source, args)
--     local _source = source
--     local xPlayer = ESX.GetPlayerFromId(_source)
--     local xTargetID = tonumber(args.target)
--     local targetPlayer = ESX.GetPlayerFromId(xTargetID)
--     if targetPlayer == nil then TriggerClientEvent('eth-gangs:Notify', _source, 3, 'Player not online.') return end
--     if args.target == nil or args.target == '' or type(xTargetID) ~= 'number' or xTargetID < 0 then TriggerClientEvent('eth-gangs:Notify', _source, 3, 'Invalid Player ID.') return end
--     MySQL.update('UPDATE users SET gang = ?, gang_rank = ? WHERE identifier = ?', {'Citizen', 'None', targetPlayer.identifier}, function(affectedRows)
--         if affectedRows > 0 then
--             TriggerClientEvent('eth-gangs:Notify', xPlayer.source, 1, 'You removed '..targetPlayer.name..' from the gang!')
--             targetPlayer.triggerEvent('esx:setGang', args.gangname, args.rank)
--             TriggerClientEvent('cfx-hu-gangs:UpdateClient', targetPlayer.source, 'Citizen', 'None')
--         else
--             print('[^4CFX-HU-GANG^0]: System Error')
--         end
--     end)
-- end, {'target:number'})