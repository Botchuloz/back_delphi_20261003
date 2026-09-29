local print = DelphiPrint
local function RuneCount()
    local numReady = 0;
    for runeSlot=1,6 do
        local start, duration, runeReady = GetRuneCooldown(runeSlot);
        if (runeReady) then
            numReady = numReady + 1;
        end
    end
    return numReady
end

-- function GetPartyClassCount(class_name)
--     local class_count = 0
--     for groupindex = 1,MAX_PARTY_MEMBERS do
--         local unit_name = "party"..groupindex
--         if (UnitExists(unit_name)) then
--             if(UnitClass(unit_name) == class_name)then
--                 class_count = class_count + 1
--             end
--         else
--             return class_count + (UnitClass("player")==class_name and 1 or 0) -- catering to group1-grou4 not including player, but raid1-40 always does.
--         end
--     end
--     return class_count + (UnitClass("player")==class_name and 1 or 0)
-- end

-- function GetRaidClassCount(class_name)
--     local class_count = 0
--     for groupindex = 1,MAX_RAID_MEMBERS do
--         local unit_name = "raid"..groupindex
--         if (UnitExists(unit_name)) then
--             if(UnitClass(unit_name) == class_name)then
--                 class_count = class_count + 1
--             end
--         else
--             return class_count
--         end
--     end
--     return class_count
-- end


-- function GetClassCount(class_name)
--     local class_count = 0
--     if(UnitExists("raid1"))then
--         return GetRaidClassCount(class_name)
--     else
--         return GetPartyClassCount(class_name)
--     end
-- end

function TalentEnabled(talent_tree,talent_row,talent_column)
    local talentID, talentName,_,_,_,spellId,_,_,_,haveTalent,haveFakeTalent = GetTalentInfo(class_spec_number, talent_row_number,1)
    return haveTalent, haveFakeTalent
end

function GetGroupSize()
    if(UnitExists("raid1"))then
        return GetRaidSize()
    else
        return GetPartySize()+1
    end
end

function GetPartySize()
    local memberCount = 0
    for groupindex = 1,MAX_PARTY_MEMBERS do
        if (UnitExists("party"..groupindex)) then
            memberCount = memberCount + 1
        else
            return memberCount + 1 -- catering to group1-grou4 not including player, but raid1-40 always does.
        end
    end
    return memberCount + 1 -- catering to group1-grou4 not including player, but raid1-40 always does.
end

function GetRaidSize()
    local memberCount = 0
    for groupindex = 1,MAX_RAID_MEMBERS do
        if (UnitExists("raid"..groupindex)) then
            memberCount = memberCount + 1
        else
            return memberCount
        end
    end
    return memberCount
end

function GetPartyHealth()
    local member_health = 0
    local member_max_health = 0
    for groupindex = 1,MAX_PARTY_MEMBERS do
        local unitid = "party"..groupindex
        if (UnitExists(unitid)) then
            member_health = member_health + UnitHealth(unitid)
            member_max_health = member_max_health + UnitHealthMax(unitid)
        else
            return member_health,member_max_health  -- catering to group1-grou4 not including player, but raid1-40 always does.
        end
    end
    return member_health,member_max_health  -- catering to group1-grou4 not including player, but raid1-40 always does.
end

function GetRaidHealth()
    local member_health = 0
    local member_max_health = 0
    for groupindex = 1,MAX_RAID_MEMBERS do
        local unitid = "raid"..groupindex
        if (UnitExists(unitid)) then
            member_health = member_health + UnitHealth(unitid)
            member_max_health = member_max_health + UnitHealthMax(unitid)
        else
            return member_health,member_max_health  -- catering to group1-grou4 not including player, but raid1-40 always does.
        end
    end
    return member_health,member_max_health  -- catering to group1-grou4 not including player, but raid1-40 always does.
end


function GetGroupHealth()
    if(UnitExists("raid1"))then
        local raid_health,raid_max_health = GetRaidHealth()
        return raid_health,raid_max_health
    else
        local party_health,party_max_health = GetPartyHealth()
        party_health = party_health + UnitHealth("player")
        party_max_health = party_max_health + UnitHealthMax("player")

        return party_health,party_max_health
    end
end

local delphi_meta = {__index = function(t,metric) 
    if 1==0 then
    elseif metric == "group_size" then 
        return GetGroupSize() or 0
    elseif metric == "group_health" then 
        return GetGroupHealth() or 0
    elseif metric == "spec" then 
        return GetSpecialization() or 0 
    elseif metric == "stationary" then -- _unit[unit].hostile
        local moving,moving_for,stationary,stationary_for,speed = MovementStatus()
        return stationary
    elseif metric == "stationary_for" then -- _unit[unit].hostile
        local moving,moving_for,stationary,stationary_for,speed = MovementStatus()
        return stationary_for
    elseif metric == "moving" then -- _unit[unit].hostile
        local moving,moving_for,stationary,stationary_for,speed = MovementStatus()
        return moving
    elseif metric == "moving_for" then -- _unit[unit].hostile
        local moving,moving_for,stationary,stationary_for,speed = MovementStatus()
        return moving_for
    elseif metric == "resource" then -- _unit[unit].resource
        local resource_data = {}
        local resource_meta = {}
        resource_meta.__index = 
            function(t,resource_metric) -- _unit[unit].resource[resource_metric]
                --[[resource METRICS HERE]]
                if 1==0 then -- https://wow.gamepedia.com/PowerType
                elseif resource_metric == "mana" then -- _unit[unit].resource.mana
                    return UnitPower("player",0)
                elseif resource_metric == "mana_percent" then
                    local current_mana = UnitPower("player",0)
                    local max_mana = UnitPowerMax("player",0)
                    if issecretvalue(current_mana) or issecretvalue(max_mana) then
                    return 0
                    end
                    return current_mana / max_mana
                elseif resource_metric == "rage" then
                    return UnitPower("player",1)
                elseif resource_metric == "energy" then
                    return UnitPower("player",3)
                elseif resource_metric == "cp" then
                    return UnitPower("player",4)
                elseif resource_metric == "chi" then
                    return UnitPower("player",4)
                elseif resource_metric == "runes" then -- 5 is runes, but it always returns 6 (as in you have 6 slots for runes, but not 6 available)
                    return RuneCount()
                elseif resource_metric == "runepower" then
                    return UnitPower("player",6)
                elseif resource_metric == "holy_power" then
                    return UnitPower("player",9)
                elseif resource_metric == "insanity" then
                    return UnitPower("player",13)
                elseif resource_metric == "shards" then
                    local casting_spell,cast_remaining,cast_remaining_perc,cast_interruptable,spell_is_channel = CastInfo("player")
                    local shards = UnitPower("player",7)
                    if casting_spell == "Malefic Rapture" or casting_spell == "Seed of Corruption" then
                        return shards - 1
                    end
                    return shards
                else -- _unit[unit].resource.???
                    print("Unknown 'resource_metric' in table:delphi.resource[",resource_metric,"]")
                    return -1
                end
            end
        setmetatable(resource_data,resource_meta)
        return resource_data          
    end             
end}
setmetatable(delphi,delphi_meta)

local _unit = delphi.unit -- _unit
local unit_meta = {}
unit_meta.__index = 
    function(t,unit) -- _unit[unit]
        local unit_data = {}
        local unit_meta = {}
        unit_meta.__index = 
            function(t,metric) -- _unit[unit][metric]
                if 1==0 then
                elseif metric == "valid" then -- _unit[unit].valid
                    return UnitAlive(unit) or false
                elseif metric == "friendly" then -- _unit[unit].friendly
                    return UnitAliveAndFriendly(unit) or false
                elseif metric == "hostile" then -- _unit[unit].hostile
                    return UnitAliveAndHostile(unit) or false
                elseif metric == "boss" then -- _unit[unit].boss
                    return UnitIsBossFrameUnit(unit) or false
                elseif metric == "guid" then -- _unit[unit].valid
                    return UnitGUID(unit) or ""
                elseif metric == "combat" then -- _unit[unit].valid
                    return UnitAffectingCombat(unit) or false
                elseif metric == "name" then -- _unit[unit].valid
                    return UnitNameServer(unit) or ""
                elseif metric == "cast_name" then -- _unit[unit].valid
                    local cast_name,cast_remaining,cast_remaining_perc,cast_interruptable,spell_is_channel = CastInfo(unit)
                    return cast_name
                elseif metric == "cast_remaining" then -- _unit[unit].valid
                    local casting_spell,cast_remaining,cast_remaining_perc,cast_interruptable,spell_is_channel = CastInfo(unit)
                    return cast_remaining
                elseif metric == "cast_remaining_perc" then -- _unit[unit].valid
                    local casting_spell,cast_remaining,cast_remaining_perc,cast_interruptable,spell_is_channel = CastInfo(unit)
                    return cast_remaining_perc
                elseif metric == "interruptable" then -- _unit[unit].valid
                    local casting_spell,cast_remaining,cast_remaining_perc,cast_interruptable,spell_is_channel = CastInfo(unit)
                    return cast_interruptable
                elseif metric == "channelling" then
                    local casting_spell,cast_remaining,cast_remaining_perc,cast_interruptable,spell_is_channel = CastInfo(unit)
                    return spell_is_channel
    
--BUFFS & DEBUFFS
                elseif metric == "buff" or metric == "debuff" then  -- _unit[unit].buff
                    local aura_data = {}
                    local aura_meta = {}
                    local aura_player_string = metric == "buff" and "PLAYER|HELPFUL" or "PLAYER|HARMFUL" 
                    local aura_string        = metric == "buff" and "HELPFUL" or "HARMFUL"

                    aura_meta.__index =
                        function(t,spell)  -- _unit[unit].buff.[spell]
                            local spell_data = {}
                            local spell_meta = {}
                            spell_meta.__index = 
                                function(t,spell_metric) -- _unit[unit].buff.[spell][spell_metric]
                                    --[[BUFF METRICS HERE]]
                                    if 1==0 then
                                    elseif spell_metric == "stacks" then
                                        local remaining,source,stacks = CheckAura(spell,unit,aura_player_string)
                                        return stacks
                                    elseif spell_metric == "remaining" then -- _unit[unit].buff.[spell].remaining
                                        return CheckAura(spell,unit,aura_player_string)
                                    elseif spell_metric == "remaining_or_high" then
                                        return CheckAura(spell,unit,aura_player_string,nil,nil,true) -- remaining, but 999 if missing, to allow things like "cast when remaining_or_high < 5" and not have to cater to ==0
                                    elseif spell_metric == "remaining_any" then -- _unit[unit].buff.[spell].remaining
                                        return CheckAura(spell,unit,aura_string)
                                    elseif spell_metric == "remaining_other" then -- _unit[unit].buff.[spell].remaining
                                        return CheckAura(spell,unit,aura_string,true)                                        
                                    else -- _unit[unit].buff.[spell].???
                                        print("Unknown 'spell_metric' in table:unit => unit[",unit,"] metric[",metric,"] spell_metric[",spell_metric,"]")
                                        return -1
                                    end
                                end
                            setmetatable(spell_data,spell_meta)
                            return spell_data
                        end
                    setmetatable(aura_data,aura_meta)
                    return aura_data
--HEALTH DATA
                elseif metric == "health" then -- _unit[unit].health
                    local health_data = {}
                    local health_meta = {}
                    health_meta.__index = 
                        function(t,health_metric) -- _unit[unit].health[health_metric]
                            --[[HEALTH METRICS HERE]]
                            if 1==0 then
                            elseif health_metric == "percent" then -- _unit[unit].health.percent
                                local unit_health,unit_health_perc,unit_health_max,unit_health_deficit = UnitHealthInfo(unit)
                                return unit_health_perc
                            elseif health_metric == "deficit" then
                                local unit_health,unit_health_perc,unit_health_max,unit_health_deficit = UnitHealthInfo(unit)
                                return unit_health_deficit
                            elseif health_metric == "deficit_percent" then
                                local unit_health,unit_health_perc,unit_health_max,unit_health_deficit = UnitHealthInfo(unit)
                                return unit_health_deficit / unit_health_max
                            elseif health_metric == "max" then
                                local unit_health,unit_health_perc,unit_health_max,unit_health_deficit = UnitHealthInfo(unit)
                                return unit_health_max
                            elseif health_metric == "remaining" then
                                local unit_health,unit_health_perc,unit_health_max,unit_health_deficit = UnitHealthInfo(unit)
                                return unit_health
                            else -- _unit[unit].health.???
                                print("Unknown 'health_metric' in table:unit => unit[",unit,"] metric[",metric,"] health_metric[",health_metric,"]")
                                return -1
                            end
                        end
                    setmetatable(health_data,health_meta)
                    return health_data
                -- -- -- --RESOURCE DATA  --- do we care about anyone other than ourselves?
                -- -- -- elseif metric == "resource" then -- _unit[unit].resource
                -- -- --     local resource_data = {}
                -- -- --     local resource_meta = {}
                -- -- --     resource_meta.__index = 
                -- -- --         function(t,resource_metric) -- _unit[unit].resource[resource_metric]
                -- -- --             --[[resource METRICS HERE]]
                -- -- --             if 1==0 then -- https://wow.gamepedia.com/PowerType
                -- -- --             elseif resource_metric == "mana" then -- _unit[unit].resource.mana
                -- -- --                 return UnitPower(unit,0)
                -- -- --             elseif resource_metric == "mana_percent" then
                -- -- --                 return UnitPower(unit,0) / UnitPowerMax(unit,0)
                -- -- --             elseif resource_metric == "rage" then
                -- -- --                 return UnitPower(unit,1)
                -- -- --             elseif resource_metric == "energy" then
                -- -- --                 return UnitPower(unit,3)
                -- -- --             elseif resource_metric == "chi" then
                -- -- --                 return UnitPower(unit,4)

                -- -- --             --runes aren't available for non-player units as far as I know
                -- -- --             -- elseif resource_metric == "runes" then -- 5 is runes, but it always returns 6 (as in you have 6 slots for runes, but not 6 available)
                -- -- --             --     return RuneCount()
                -- -- --             elseif resource_metric == "runepower" then
                -- -- --                 return UnitPower(unit,6)
                -- -- --             elseif resource_metric == "shards" then
                -- -- --                 return UnitPower(unit,7)
                -- -- --             else -- _unit[unit].resource.???
                -- -- --                 print("Unknown 'resource_metric' in table:unit => unit[",unit,"] metric[",metric,"] resource_metric[",resource_metric,"]")
                -- -- --                 return -1
                -- -- --             end
                -- -- --         end
                -- -- --     setmetatable(resource_data,resource_meta)
                -- -- --     return resource_data                       
                else -- _unit[unit].???
                    print("Unknown 'metric' in table:unit => unit[",unit,"] metric[",metric,"]")
                    return -1
                end
            end
        setmetatable(unit_data,unit_meta)
        return unit_data
    end
setmetatable(_unit,unit_meta)

-- local spell = "Renew"
-- local unit  = "player"

-- print("_unit[unit].buff[spell].remaining => 1.0")
-- print(_unit[unit].buff[spell].remaining) 

-- print("_unit[unit].debuff[spell].remaining_or_high => 999.0")
-- print(_unit[unit].debuff[spell].remaining_or_high) 

-- print("_unit[unit].health.percent=0.9/max=1000/remaining=900/deficit=100")
-- print(_unit[unit].health.percent) 
-- print(_unit[unit].health.max) 
-- print(_unit[unit].health.remaining) 
-- print(_unit[unit].health.deficit) 

-- print("_unit[unit].resource.runes=6/mana=1000")
-- print(_unit[unit].resource.runes) 
-- print(_unit[unit].resource.mana) 

-- print("_unit[unit].health.missing_health_metric=>missing")
-- print(_unit[unit].health.missing_health_metric)
-- print("_unit[unit].missing_metric=>missing")
-- print(_unit[unit].missing_metric) 
