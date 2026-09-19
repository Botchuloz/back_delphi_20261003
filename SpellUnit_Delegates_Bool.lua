_unit = delphi.unit
_event = delphi.event
_player = delphi.player

-- /run print(UnitIsDeadOrGhost("target"))
function SpellUnit_UnitIsDeadOrGhost(spell,unit)
    return UnitIsDeadOrGhost(unit)
end

-- /run print(C_Spell.IsSpellInRange("Shadow Word: Pain","target"))
function SpellUnit_RangeCheck(spell,unit)
    return C_Spell.IsSpellInRange(spell,unit) == true
end

function SpellUnit_ValidHarm(spell,unit)
    local enemy = SpellUnit_UnitAliveAndHostile(spell,unit)
    if not enemy then
        return false
    end

    local combat = UnitAffectingCombat(unit) or false
    local in_group = UnitExists("party1") or false
    if not combat and in_group then
        return false
    end

    return true
end

function SpellUnit_EvalTrueForXkd(spell,unit)
    if UnitName(unit) == "Xkd" then
        print("unit ",unit," is me")
        return true
    end
    print("unit ",unit," is not me")
    return false
end

function SpellUnit_UnitAliveAndHostile(spell,unit)
    local result = UnitAliveAndHostile(unit) or false
    -- if unit == "focus" then
    --     print("UnitAliveAndHostile(focus)",result)
    -- end
    return result
end

function SpellUnit_MyDebuffExpiringUnder5(spell,unit)
    return RemainingDebuffFromMe(spell,unit) < 5.0
end

function SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired(spell,unit) -- /run print(SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired("Unstable Affliction","target"))
    local remaining = RemainingDebuffFromMe(spell,unit)
    return remaining > 0.0 and remaining < 5.0
end

function SpellUnit_MyDebuffExpired(spell,unit) -- /run print(SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired("Unstable Affliction","target"))
    local remaining = RemainingDebuffFromMe(spell,unit)
    return remaining == 0.0
end

function SpellUnit_MyBuffExpiringUnder5(spell,unit)
    return RemainingBuffFromMe(spell,unit) < 5.0
end

function SpellUnit_MyBuffExpired(spell,unit)
    return RemainingBuffFromMe(spell,unit) == 0
end

function SpellUnit_BuffExpiringUnder5(spell,unit)
    return RemainingBuff(spell,unit) < 5.0
end

function SpellUnit_BuffExpiringUnder300(spell,unit) -- 5 minutes
    return RemainingBuff(spell,unit) < 300.0
end

function SpellUnit_BuffActive(spell,unit)
    return RemainingBuff(spell,unit) > 0
end

function SpellUnit_BuffExpired(spell,unit)
    return RemainingBuff(spell,unit) == 0
end

function SpellUnit_DebuffExpired(spell,unit)
    return RemainingDebuff(spell,unit) == 0
end


function SpellUnit_AliveAndFriendly(spell,unit)
    return UnitAliveAndFriendly(unit)
end

function SpellUnit_UnitDeadAndFriendly(spell,unit)
    return UnitDeadAndFriendly(unit)
end

function SpellUnit_LowHealth(spell,unit)
    local unit_role  = UnitGroupRolesAssigned(unit) or ""
    local unit_health_percent = _unit[unit].health.percent

    if unit_role == "TANK" and unit_health_percent < 0.55 then
        return true
    elseif unit_role == "HEALER" and unit_health_percent < 0.45 then
        return true
    elseif unit_health_percent < 0.44 then
        return true
    end
    return false
end

function SpellUnit_VeryLowHealth(spell,unit)
    local unit_role  = UnitGroupRolesAssigned(unit) or ""
    local unit_health_percent = _unit[unit].health.percent

    if unit_role == "TANK" and unit_health_percent < 0.4 then
        return true
    elseif unit_role == "HEALER" and unit_health_percent < 0.3 then
        return true
    elseif unit_health_percent < 0.20 then
        return true
    end
    return false
end


function SpellUnit_MediumHealth(spell,unit)
    local unit_role  = UnitGroupRolesAssigned(unit) or ""
    local unit_health_percent = _unit[unit].health.percent

    if unit_role == "TANK" and unit_health_percent < 0.7 then
        return true
    elseif unit_role == "HEALER" and unit_health_percent < 0.70 then
        return true
    elseif unit_health_percent < 0.50 then
        return true
    end
    return false
end

function SpellUnit_HighHealth(spell,unit)
    local unit_role  = UnitGroupRolesAssigned(unit) or ""
    local unit_health_percent = _unit[unit].health.percent

    if unit_role == "TANK" and unit_health_percent < 0.9 then
        return true
    elseif unit_role == "HEALER" and unit_health_percent < 0.75 then
        return true
    elseif unit_health_percent < 0.60 then
        return true
    end
    return false
end


function SpellUnit_AlmostEmpty(spell,unit)
    local unit_role  = UnitGroupRolesAssigned(unit) or ""
    local unit_health_percent = _unit[unit].health.percent

    if unit_role == "TANK" and unit_health_percent < 0.3 then
        return true
    elseif unit_role == "HEALER" and unit_health_percent < 0.2 then
        return true
    elseif unit_health_percent < 0.1 then
        return true
    end
    return false
end

function SpellUnit_AlmostFull(spell,unit)
    local unit_role  = UnitGroupRolesAssigned(unit) or ""
    local unit_health_percent = _unit[unit].health.percent

    if unit_health_percent < 0.99 then
        return true
    end
    return false
end

-----------from druid-------------

function SpellUnit_ExpiringOrExpired(spell,unit)
    if _unit[unit].buff[spell].remaining < 4.5 then
        return true
    end
    return false
end

function SpellUnit_Expiring(spell,unit)
    if _unit[unit].buff[spell].remaining_or_high < 4.5 then
        return true
    end
    return false
end

function SpellUnit_Expired(spell,unit)
    if _unit[unit].buff[spell].remaining == 0 then
        return true
    end
    return false
end

function SpellUnit_Debuff_ExpiringNextGCDOrExpired(spell,unit)
    if _unit[unit].debuff[spell].remaining < 1.5 then
        return true
    end
    return false
end

function SpellUnit_Debuff_ExpiringOrExpired(spell,unit)
    if _unit[unit].debuff[spell].remaining < 4.5 then
        return true
    end
    return false
end

function SpellUnit_Debuff_Expiring(spell,unit)
    if _unit[unit].debuff[spell].remaining_or_high < 4.5 then
        return true
    end
    return false
end

function SpellUnit_Debuff_Expired(spell,unit)
    if _unit[unit].debuff[spell].remaining == 0 then
        return true
    end
    return false
end

function SpellUnit_HealthBelow99(spell,unit)
    return _unit[unit].health.percent < 0.99
end

function SpellUnit_HealthBelow95(spell,unit)
    return _unit[unit].health.percent < 0.95
end

function SpellUnit_HealthBelow90(spell,unit)
    return _unit[unit].health.percent < 0.9
end

function SpellUnit_HealthBelow80(spell,unit)
    return _unit[unit].health.percent < 0.8
end

function SpellUnit_HealthBelow75(spell,unit)
    return _unit[unit].health.percent < 0.75
end

function SpellUnit_HealthBelow70(spell,unit)
    return _unit[unit].health.percent < 0.7
end


function SpellUnit_HealthBelow60(spell,unit)
    return _unit[unit].health.percent < 0.6
end

function SpellUnit_HealthBelow50(spell,unit)
    return _unit[unit].health.percent < 0.5
end

function SpellUnit_HealthBelow40(spell,unit)
    return _unit[unit].health.percent < 0.4
end

function SpellUnit_HealthBelow35(spell,unit)
    return _unit[unit].health.percent < 0.35
end


function SpellUnit_HealthBelow30(spell,unit)
    return _unit[unit].health.percent < 0.3
end

function SpellUnit_HealthBelow25(spell,unit)
    return _unit[unit].health.percent < 0.25
end

function SpellUnit_HealthBelow20(spell,unit)
    return _unit[unit].health.percent < 0.2
end

function SpellUnit_HealthBelow10(spell,unit)
    return _unit[unit].health.percent < 0.1
end

function SpellUnit_IsTank(spell,unit)
    local unit_role  = UnitGroupRolesAssigned(unit) or ""
    return unit_role == "TANK"
end

function SpellUnit_30secBetweenRecasts(spell,unit)
    if LastCastSpellAtAnything(spell) > 30 then
        return true
    end
    return false
end












-- function SpellUnit_NoRecasting(spell,unit)

--     local test_unit_name = UnitName(unit) or ""
--     local dest_unit_name = _player.casting.dest_name or ""
--     if test_unit_name == dest_unit_name then

--         local casting_spell,cast_remaining,cast_remaining_perc,cast_interruptable = CastInfo("player")
--         if casting_spell == spell then

--             local cast_time = select(4,GetSpellInfo(spell)) / 1000.0 -- the base data is millisec
--             --local current_cast_start = _event.player_current_cast_start or 0
--             local current_cast_start = _player.casting.start or 0
--             print("THIS LINE ABOVE IS NOT WORKINg, I REPEAT CAST LIKE AN IDIOT")
--             if _now - cast_time - 0.5 > current_cast_start then
--                 return false
--             end
--         end
--     end
--     return true
-- end
