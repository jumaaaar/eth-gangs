
CollectiveS = {}
CollectiveS.GeneralWH = '' -- Discord Loggin for admin

function SNotify(_source, theType, message)
    if theType == 1 then
        TriggerClientEvent('esx:showNotification', _source, 'success', 5000, message, 'GANG')
    elseif theType == 2 then
        TriggerClientEvent('esx:showNotification', _source, 'info', 5000, message, 'GANG')
    elseif theType == 3 then
        TriggerClientEvent('esx:showNotification', _source, 'error', 5000, message, 'GANG')
    end
end


function Notify(src, type, message, duration, color)
    TriggerClientEvent('ox_lib:notify', src, { type = type, description = message, duration = duration or 5000, position = 'top', style = { color = color or "red" } })
end
