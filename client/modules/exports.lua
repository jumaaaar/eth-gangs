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

function GetGangLabel(gangName)
    local gang = GangData[gangName]

    if gang ~= nil then
        return gang['label']
    end

    return nil
end

function GetPositionLabel(GangRank,PlayerGang)
    print(GangRank,PlayerGang)
    local GangPositionLabel = GangData[PlayerGang]['grades'][GangRank]['name']
    if GangPositionLabel ~= nil then
        return GangPositionLabel
    else
        return nil
    end
end

exports('Cl_GetPositionLabel', GetPositionLabel)
exports('Cl_GetGangLabel', GetGangLabel)
exports('Cl_isGangBoss', isGangBoss)