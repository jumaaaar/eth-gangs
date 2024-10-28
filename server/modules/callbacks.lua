-- Template
-- lib.callback.register('ox_inventory:getItemCount', function(source)
--     return 
-- end)

lib.callback.register('cfx-hu-gangs:getPlayerInfo', function(source, target)
    local src = source
    local targetxPlayer = ESX.GetPlayerFromId(target)
    local playerName = targetxPlayer.name
    return playerName
end)





lib.callback.register('cfx-hu-gangs:getGangMembers', function(source, gangName)
    local members = {}
    local result = MySQL.query.await('SELECT * FROM users WHERE gang = ?', {gangName})
    if result then
        for i=1, #result, 1 do
            local row = result[i]
            table.insert(members, {
                name = row.firstname..' '..row.lastname,
                identifier = row.identifier,
                grade = row.gang_rank,
                gang = {
                    name = row.gang,
                    grade = row.gang_rank,
                }
            })
        end
    end
    return members
end)

lib.callback.register('cfx-hu-gangs:GetPlayerGangPosition', function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local gang_rank = MySQL.scalar.await('SELECT gang_rank FROM users WHERE identifier = ?', {xPlayer.identifier})
    if gang_rank ~= nil then
        return gang_rank
    else
        return false
    end
end)

lib.callback.register('cfx-hu-gangs:getGangAccount', function(source, gangName)
    local gangFunds = MySQL.scalar.await('SELECT gangFunds FROM `cfx-hu-gangs` WHERE name = ?', {gangName})
    return gangFunds
end)

