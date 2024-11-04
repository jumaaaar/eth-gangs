local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function GetRandomNumber(length)
    Citizen.Wait(1)
    math.randomseed(GetGameTimer())
    if length > 0 then
        return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
    else
        return ''
    end
end

function GetRandomLetter(length)
    Citizen.Wait(1)
    math.randomseed(GetGameTimer())
    if length > 0 then
        return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
    else
        return ''
    end
end

function CheckPlayerisGang(thePlayer, theGang)
    local xPlayer = ESX.GetPlayerFromId(thePlayer)
    local gang = MySQL.scalar.await('SELECT gang FROM users WHERE identifier = ?', {xPlayer.identifier})
    local isGang = false
    if gang ~= nil then
        if gang == theGang then
            isGang = false
        else
            isGang = true
        end
    else
        isGang = false
    end
    return isGang
end

function GetPlayerGang(thePlayer)
    local xPlayer = ESX.GetPlayerFromId(thePlayer)
    local gang = MySQL.scalar.await('SELECT gang FROM users WHERE identifier = ?', {xPlayer.identifier})
    local GangName = nil
    if gang ~= nil then
        GangName = gang
    end
    return GangName
end

function GetGangLabel(gangName)
    local gang = GangData[gangName]

    if gang ~= nil then
        return gang['label']
    end

    return nil
end

function GetGangSpray(gangName)
    local GangSpray = GangData[gangName]['SprayPaint']

    if GangSpray ~= nil then
        return GangSpray
    end

    return nil
end

function GetGangFunds(gangName)
    local gangFunds = MySQL.scalar.await('SELECT gangFunds FROM `eth-gangs` WHERE name = ?', {gangName})
    if gangFunds then
        return gangFunds
    else
        return 0
    end
end

-- Function to add funds to a gang
function AddGangFunds(gangName, amount)
    local currentFunds = GetGangFunds(gangName)
    -- Calculate the new amount
    local newFunds = currentFunds + amount
    -- Update the database with the new funds amount
    MySQL.execute('UPDATE `eth-gangs` SET gangFunds = ? WHERE name = ?', {newFunds, gangName})
end

function isValidRank(gangName , gankRank)
    local Gang = GangData[gangName]

    if not Gang then
        return false
    end

    if not Gang['grades'][gankRank] then
        return false
    end

    return true
end

function isValidGang(gangName)
    local Gang = GangData[gangName]

    if gangName then
        return true
    end
    
    return false
end

function isGangBoss(gangName,gangRank)
    local gangRank = GangData[gangName]['grades'][gangRank]

    if not gangRank then
        return false
    end

    if gangRank["isboss"] then
        return true
    end
    
    return false
end

function GetGangName(gangName)
    local isGang = false
    local Gang = GangData[gangName]
    if Gang  then
        isGang = true
    end
    return isGang
end

function GetPlayerGangPosition(thePlayer)
    local xPlayer = ESX.GetPlayerFromId(thePlayer)
    local gang_rank = MySQL.scalar.await('SELECT gang_rank FROM users WHERE identifier = ?', {xPlayer.identifier})
    if gang_rank ~= nil then
        return gang_rank
    else
        return nil
    end
end

function GetPositionLabel(GangRank,PlayerGang)
    local GangPositionLabel = GangData[PlayerGang]['grades'][tostring(GangRank)]['name']
    if GangPositionLabel ~= nil then
        return GangPositionLabel
    else
        return nil
    end
end

function GetGangBlipColor(gangName)
    print("gagnName" , gangName)
    local GangBlipColor = GangData[gangName]["blipColor"]

    if GangBlipColor ~= nil then
        return GangBlipColor
    end

    return nil
end

exports('SVGetGangBlipColor', GetGangBlipColor)
exports('SVGetPositionLabel', GetPositionLabel)
exports('SVGetPlayerGangPosition', GetPlayerGangPosition)
exports('SVisValidGang', isValidGang)
exports('SVisGangBoss', isGangBoss)
exports('SVGetGangName', GetGangName)
exports('SVGetGangFunds', GetGangFunds)
exports('SVGetGangLabel', GetGangLabel)
exports('SVGetPlayerGang', GetPlayerGang)
exports('SVCheckPlayerisGang', CheckPlayerisGang)
exports('SVAddGangFunds', AddGangFunds)