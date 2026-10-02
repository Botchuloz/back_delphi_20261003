local print = DelphiPrint
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

local NIGHT_WATCHMANS_TORCH_CAPITAL_CITIES = {
    ["Dalaran"] = true,
    ["Darnassus"] = true,
    ["Exodar"] = true,
    ["Ironforge"] = true,
    ["Orgrimmar"] = true,
    ["Shattrath City"] = true,
    ["Silvermoon City"] = true,
    ["Stormwind"] = true,
    ["Stormwind City"] = true,
    ["The Exodar"] = true,
    ["Thunder Bluff"] = true,
    ["Undercity"] = true,
}

function NightWatchmansTorchReady()
    local item_id = 280612
    if InCombatLockdown() or type(IsResting) ~= "function"
        or type(IsSwimming) ~= "function"
        or type(GetRealZoneText) ~= "function"
        or not (C_Item and C_Item.GetItemCount)
        or not (C_Container and C_Container.GetItemCooldown)
        or not (C_Item and C_Item.IsUsableItem) then
        return false
    end

    local resting_ok, resting = pcall(IsResting)
    if not resting_ok or type(resting) ~= "boolean" or resting then
        return false
    end

    local swimming_ok, swimming = pcall(IsSwimming)
    if not swimming_ok or type(swimming) ~= "boolean" or swimming then
        return false
    end

    local zone_ok, zone_name = pcall(GetRealZoneText)
    if not zone_ok or type(zone_name) ~= "string" then
        return false
    end
    if NIGHT_WATCHMANS_TORCH_CAPITAL_CITIES[zone_name] then
        return false
    end

    local count_ok, count = pcall(C_Item.GetItemCount, item_id, false, false, false)
    if not count_ok or type(count) ~= "number"
        or (issecretvalue and issecretvalue(count)) or count < 1 then
        return false
    end

    local usable_ok, usable, insufficient_power =
        pcall(C_Item.IsUsableItem, item_id)
    if not usable_ok or type(usable) ~= "boolean"
        or (issecretvalue and (issecretvalue(usable)
            or issecretvalue(insufficient_power)))
        or not usable or insufficient_power == true then
        return false
    end

    local cooldown_ok, start_time, duration, enabled =
        pcall(C_Container.GetItemCooldown, item_id)
    if not cooldown_ok or type(start_time) ~= "number"
        or type(duration) ~= "number" or type(enabled) ~= "number"
        or (issecretvalue and (issecretvalue(start_time)
            or issecretvalue(duration) or issecretvalue(enabled))) then
        return false
    end

    return enabled == 1
        and (start_time == 0 or duration == 0
            or start_time + duration - GetTime() < 0.5)
end

print("world.lua loaded")
