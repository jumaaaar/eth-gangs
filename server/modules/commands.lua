lib.addCommand('group.user', {'leavegang', 'quitgang'}, function(source, args)
    local _source = source
    local GangName = GetPlayerGang(_source)
    if GangName then
        TriggerClientEvent('cfx-hu-gangs:LeaveGangMenu', _source, GangName)
    else
        SNotify(_source, 3, 'You must have a gang.')
    end
end)

lib.addCommand('group.admin', {'setgang', 'addgang'}, function(source, args)
    
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTargetID = tonumber(args.target)
    local targetPlayer = ESX.GetPlayerFromId(xTargetID)
    if targetPlayer == nil then SNotify(_source, 3, 'Player not online.') return end
    if args.target == nil or args.target == '' or type(xTargetID) ~= 'number' or xTargetID < 0 then SNotify(_source, 3, 'Invalid Player ID.') return end
    if not GetGangName(args.gangname) or args.gangname == nil then
        SNotify(_source, 3, 'Invalid Gang Name.')
        return
    end
    if not isValidRank(args.gangname , args.rank ) or args.rank == nil then
        SNotify(_source, 3, 'Invalid Gang Rank.')
        return
    end
    if not CheckPlayerisGang(targetPlayer.source, args.gangname) then
        SNotify(_source, 3, 'The person you are trying to invite is already a member of a gang.')
        return
    end

    local RankLabel = GangData[args.gangname]['grades'][args.rank]['name']
    MySQL.update('UPDATE users SET gang = ?, gang_rank = ? WHERE identifier = ?', {tostring(args.gangname), tostring(args.rank), targetPlayer.identifier}, function(affectedRows)
        if affectedRows then
            SNotify(xPlayer.source, 1, 'You hired '..targetPlayer.name..'!')
            SNotify(targetPlayer.source, 1, 'You were hired in the '..GetGangLabel(args.gangname)..' as a '..tostring(RankLabel))
            TriggerClientEvent('esx:setGang', targetPlayer.source , args.gangname, args.rank)
        else
            print('[^4CFX-HU-GANG^0]: System Error')
        end
    end)
end, {'target:number', 'gangname:string', 'rank:string'})




lib.addCommand('group.admin', {'gpsray'}, function(source, args)
    
    local _source = source
    print(args.gang)
    if not GetGangName(args.gang) or args.gang == nil then
        SNotify(_source, 3, 'Invalid Gang Name.')
        return
    end
    local gangName = args.gang
    local paintModel = GetGangSpray(gangName)
    if paintModel then
        exports.ox_inventory:AddItem(_source,'spraycan', 1, {
            model = tonumber(paintModel),
            name = GetGangLabel(gangName),
            gang = gangName
        })
    end
end, {'gang:string'})


local GangLimit = 0
lib.addCommand('group.user', {'checkgang', 'gang'}, function(source, args)
    local _source = source
    if (GetGameTimer() - GangLimit) < 5000 then 
        SNotify(_source, 3, 'You must wait '..(5 - math.floor((GetGameTimer() - GangLimit) / 1000))..' seconds')
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
    SNotify(_source, 2, 'Current Gang: '..myCurrentGangLabel..'\nCurrent Gang Rank: '..Positionlabel)
end)


-- lib.addCommand('group.admin', {'removegang'}, function(source, args)
--     local _source = source
--     local xPlayer = ESX.GetPlayerFromId(_source)
--     local xTargetID = tonumber(args.target)
--     local targetPlayer = ESX.GetPlayerFromId(xTargetID)
--     if targetPlayer == nil then SNotify(_source, 3, 'Player not online.') return end
--     if args.target == nil or args.target == '' or type(xTargetID) ~= 'number' or xTargetID < 0 then SNotify(_source, 3, 'Invalid Player ID.') return end
--     MySQL.update('UPDATE users SET gang = ?, gang_rank = ? WHERE identifier = ?', {'Citizen', 'None', targetPlayer.identifier}, function(affectedRows)
--         if affectedRows > 0 then
--             SNotify(xPlayer.source, 1, 'You removed '..targetPlayer.name..' from the gang!')
--             targetPlayer.triggerEvent('esx:setGang', args.gangname, args.rank)
--             TriggerClientEvent('cfx-hu-gangs:UpdateClient', targetPlayer.source, 'Citizen', 'None')
--         else
--             print('[^4CFX-HU-GANG^0]: System Error')
--         end
--     end)
-- end, {'target:number'})