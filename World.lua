--name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()

function pvp_zone_or_pvp_target()
    local name,type = GetInstanceInfo()
    if type == "arena" or type == "pvp" then
        return true
    elseif SpellUnit_UnitAliveAndHostile("","target") and UnitPlayerControlled("target") then
        return true
    end
    return false
end

function shadowlands()
    local name = GetInstanceInfo()
    if name == "The Shadowlands" or name == "Torghast" or name == "Torghast, Tower of the Damned" or name == "Zereth Mortis" then
        return true
    end
    return false
end

function zereth_mortis()
    local name = GetInstanceInfo()
    if name == "Zereth Mortis" then
        return true
    end
    return false
end

function special_awakening_the_machine()
    local name = GetInstanceInfo()
    if name == "Awakening The Machine" then
        return true
    end
    return false
end

function special_delve()
    local _, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Delves" then
        return true
    end
    return false
end

function isBrannInParty()
    local name = UnitName("party1")
    if name == "Brann Bronzebeard" then
        return true
    end
    return false
end

function siren_isle()
    local name = GetInstanceInfo()
    if name == "Siren Isle" then
        return true
    end
    return false
end

print("world.lua loaded")
