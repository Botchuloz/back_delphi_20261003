
--local unit_health,unit_health_perc,unit_health_max,unit_health_deficit = UnitHealthInfo(unit)
function UnitHealthInfo(unit)
    local unit_health = SafeNumber(UnitHealth(unit), 0)
    local unit_health_max = SafeNumber(UnitHealthMax(unit), 100)
    local unit_health_perc = 0

    if unit_health == 0 or unit_health_max <= 0 then
    return 0,0,100,0
    else
    unit_health_perc = unit_health / unit_health_max
    local unit_health_deficit = unit_health_max - unit_health
    return unit_health,unit_health_perc,unit_health_max,unit_health_deficit
    end
end

function UnitAlive(unit)
    local exists = UnitExists(unit)
    if not exists then
        return false
    end

    local alive = not UnitIsDeadOrGhost(unit)
    if not alive then
        return false
    end

    return true
end

function UnitAliveAndHostile(unit)
    local unit_name = UnitName(unit) or ""
    if unit_name == "Training Dummy" or unit_name == "Raider's Training Dummy" then
        return true
    end
    local alive = UnitAlive(unit)

    if not alive then
        return false
    end

    local hostile = (UnitReaction(unit,"player") or 999)<5
    if not hostile then
        return false
    end
    return true
end

function UnitDeadAndFriendly(unit)
    local exists = UnitExists(unit)
    if not exists then
        return false
    end

    local alive = not UnitIsDeadOrGhost(unit)
    if alive then
        return false
    end

    local friendly = (UnitReaction(unit,"player") or 0)>=5
    if not friendly then
        return false
    end

    return true
end

function UnitAliveAndFriendly(unit)
    local alive = UnitAlive(unit)
    if not alive then
        return false
    end

    local friendly = (UnitReaction(unit,"player") or 0)>=5
    if not friendly then
        return false
    end
    return true
end

--/run print(UnitIsBossFrameUnit("target"))
function UnitIsBossFrameUnit(unit)
    --testing dummy!
    local unit_name = UnitName(unit) or ""
    if unit_name == "Raider's Training Dummy" then
        return true
    end

    if unit_name == "Highlord's Nemesis Trainer" then
        return true
    end

    -- if unit_name == "High Torturer Darithos" then -- castle nathia, non-boss mob that you start the fight facing
    --     return true
    -- end

    --regular boss
    for i = 1,4 do
        local compare_unit = "boss"..i
        local unit_exists = UnitAliveAndHostile(compare_unit)
        if unit_exists and UnitIsUnit(compare_unit,unit) then
            return true
        end
    end

    --not a boss
    return false
end

--/run print(UniqueCountSpellInstances("Unstable Affliction",3))
function UniqueCountSpellInstances(spell,spell_tick_speed)
    if not delphi.track_aura[spell] then
        return 0 
    end

    local count = 0
    for spell_name,unit in next,delphi.track_aura[spell] do
        local applied = unit.applied or 0
        local ticked  = unit.ticked or 0

        if applied + spell_tick_speed > _now or ticked + spell_tick_speed > _now then
            count = count + 1
        end
    end
    return count
end

function UniqueCountSpellPermitted(spell,unit,spell_unique_limit,spell_tick_speed,clip_in_seconds)
    local casting_spell,cast_remaining,cast_remaining_perc,cast_interruptable = CastInfo("player")

    
    --/run print(SpellUnit_NoRecasting("Unstable Affliction","target"))
    if not SpellUnit_NoRecasting(spell,unit) then -- SpellUnit_NoRecasting returns true if they are not recasting on same unit
        return false
    end

    if delphi.unit[unit].debuff[spell].remaining_or_high < clip_in_seconds then -- we are allowed to pandemic-clip
        return true
    end


    if UniqueCountSpellInstances(spell,spell_tick_speed) >= spell_unique_limit then
        return false
    end

    return true 
end


function GodlyIsOff()
    local mode = delphi.runtime.profile
    return mode ~= "dd" and mode ~= "aoe"
end

function GodlyIsDD()
    local current_state = delphi.runtime.profile == "dd"
    if current_state then
        local state_swapped = _now - delphi.runtime.changedprofile
        return current_state,state_swapped
    end
    return false,999
end

function GodlyIsAOE()
    local current_state = delphi.runtime.profile == "aoe"
    if current_state then
        local state_swapped = _now - delphi.runtime.changedprofile
        return current_state,state_swapped
    end
    return false,999
end

function RedLight()
    if GetCurrentKeyBoardFocus()~=nil then
        --PrintRateLimited("Redlight : chat_up")
        return true
    elseif GodlyIsOff() then
        --PrintRateLimited("Redlight : hades_off")
        return true
    elseif not UnitAlive("player") then
        --PrintRateLimited("Redlight : player_dead")
        return true
    elseif IsMounted() then
        --PrintRateLimited("Redlight : player_mounted")
        return true
    elseif C_PetBattles.IsInBattle() then
        --PrintRateLimited("Redlight : in_pet_battle")
        return true        
    elseif UnitInVehicle("player") and UnitHasVehicleUI("player") then
        --PrintRateLimited("Redlight : player_in_restricted_vehicle")
        return true
    else
        return false
    end
end
