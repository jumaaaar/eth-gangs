function Notify(theType, message)
    lib.notify({
        title = 'GANGS',
        description = message,
        type = theType
    })
end

RegisterNetEvent('eth-gangs:Notify')
AddEventHandler('eth-gangs:Notify', function(theType, message)
    Notify(theType, message)
end)