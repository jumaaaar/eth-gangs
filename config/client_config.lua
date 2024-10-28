
CollectiveC = {}
function CNotify(theType, message)
    if theType == 1 then
        TriggerEvent('esx:showNotification', 'success' , 5000 , message , 'GANG')
    elseif theType == 2 then
        TriggerEvent('esx:showNotification', 'inform' , 5000 , message , 'GANG')
    elseif theType == 3 then
        TriggerEvent('esx:showNotification', 'error' , 5000 , message , 'GANG')
    end
end
