RegisterServerEvent('eth-gangs:claimProtectionReward', function(id)
    local src = source
    local protectedArea = Config.ProtectionArea[tonumber(id)]

    if protectedArea.isTaken then
        TriggerClientEvent("esx:showNotification", src , "error" , 5000 , "You already claim the reward" , "GANG")
        return
    end
    TriggerClientEvent("esx:showNotification", src , "success" , 5000 , "Thank you for protecting the store" , "GANG")
    local rewardMoney= math.random(5000,10000)
    exports.ox_inventory:AddItem(src, 'black_money', rewardMoney)
    protectedArea.isTaken = true
end)