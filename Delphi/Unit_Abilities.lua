function RemainingCooldown(spell)
    if not spell then
        --print("Error: 'spell' parameter is nil.")
        return 0
    end
    local spellCooldownInfo = C_Spell.GetSpellCooldown(spell) --    cd_start,cd_duration = GetSpellCooldown(spell)
    local cd_start = spellCooldownInfo and spellCooldownInfo.startTime or 0
    local cd_duration = spellCooldownInfo and spellCooldownInfo.duration or 0

    if (cd_start and cd_start ~= 0)then          --    if(cd_start and cd_start ~= 0)then
        return cd_start + cd_duration - _now    --        return cd_start + cd_duration - _now
    else                                            --    else
        return 0                                    --        return 0
    end                                          --    end
end                                             --end

--/run print(CastInfo("player"))
--local casting_spell,cast_remaining,cast_remaining_perc,cast_interruptable,spell_is_channel = CastInfo("player")
function CastInfo(unit)
    spell, rank, icon, startTime, endTime, isTradeSkill, castID, interrupt, unknown_int_arg = UnitCastingInfo(unit)
    local spell_is_channel = false
    if not spell then
        spell, rank, icon, startTime, endTime, isTradeSkill, interrupt, unknown_int_arg = UnitChannelInfo(unit)
        spell_is_channel = true
    end
    -- print("spell "..spell)
    -- print("rank "..rank)
    -- print("icon "..icon)
    -- print("startTime "..startTime)
    -- print("endTime "..endTime)
    -- print("_now ".._now)
    
    
    if spell then
        local cast_duration     = endTime/1000 - startTime/1000
        local seconds_remaining = endTime/1000 - _now
        local percent_remaining = seconds_remaining/cast_duration
        local spell_interruptable = spell ~= "" and interrupt == false -- if it's unkickable, "interrutp" = true, false if kickable, or nil if not casting
        return spell,seconds_remaining,percent_remaining,spell_interruptable,spell_is_channel
    else
        return "",0,0,false,false
    end
end

function BaseCooldown(spell)
    if not spell then
        return 0
    end

    local baseCooldownMS = GetSpellBaseCooldown(spell)
    if not baseCooldownMS or baseCooldownMS < 0 then
        return 0
    end

    -- Convert milliseconds to seconds
    local baseCooldown = baseCooldownMS / 1000

    return baseCooldown
end

-- function RemainingCast(unit)
--     spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitCastingInfo(unit)
--     if spell == nil then
--         spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitChannelInfo(unit)
--         name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId = UnitChannelInfo(unit)
--     end
--     return some stuff
-- end

--TrinketStatus()

function ItemCooldownRemaining(slotNo)
    local cd_started, cd_duration, item_has_on_use = GetInventoryItemCooldown("player",slotNo)
    if(item_has_on_use ~= 1)then
        return false,9999
    end

    if(cd_started==nil)then -- safety catch for weird
        cd_started=0;
        cd_duration=0;
    end

    local cd_remaining = cd_started + cd_duration - _now
    local cd_available = cd_started==0

    return cd_available,cd_remaining
end

function TrinketStatus()
    local t1_cd = ItemCooldownRemaining(13)
    local t2_cd = ItemCooldownRemaining(14)

    return t1_cd or t2_cd
end

-- --/run print(GetItemCooldown(GetInventoryItemID("player",14)))
-- function CDTrinketsReadyToUse()
--     local trinket1 = GetInventoryItemID("player",13)
--     local trinket2 = GetInventoryItemID("player",14)

--     local t1_up_at, t1_cd_duration, _ = GetItemCooldown(trinket1)
--     local t2_up_at, t2_cd_duration, _ = GetItemCooldown(trinket2)


--     return zhc_ready or toep_ready
-- end


--/run print(GetSpellCharges("Barbed Shot"))
--/run print(RemainingCharges("Barbed Shot"))
--local current_charges,next_charge,max_charges = RemainingCharges("Blood Boil")
--/run print(RemainingCharges("Blood Boil"))
function RemainingCharges(spell)
    local chargesInfo = C_Spell.GetSpellCharges(spell) -- /run print(C_Spell.GetSpellCharges("Mind Blast"))
    
        if not chargesInfo then
            return 0, 0, 0
        end
    
    local currentCharges = chargesInfo.currentCharges
    local maxCharges = chargesInfo.maxCharges
    local cooldownStart = chargesInfo.start
    local cooldownDuration = chargesInfo.duration
    local chargeModRate = chargesInfo.modRate

    if not maxCharges then
        return 0,0,0
    end

    local current_cast = CastInfo("player") or "Nothing"
    if current_cast == spell then 
        currentCharges = currentCharges - 1
    end

    local next_charge_in = cooldownDuration
    if currentCharges < maxCharges then
        next_charge_in = cooldownStart + cooldownDuration -  _now
    end

    local max_charges_in = next_charge_in + (cooldownDuration * (maxCharges-(currentCharges+1)))
    if currentCharges == maxCharges then 
        max_charges_in = 0
    end

    return currentCharges,next_charge_in,max_charges_in
end


function CheckAura(spell,unit,filter,excludePlayer,debug,high_if_missing_flag)  -- function CheckAura(spell,unit,filter,excludePlayer,debug,high_if_missing_flag)
    for i = 1, 40 do                                                            --     for i = 1,40 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, filter)            --         name, icon, count, auratype, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitAura(unit, i, filter)
        if not aura then    --         if(name==nil)then
            break           --             break
        end                 --         end

        local applications = aura.applications or 0 -- Number of stacks or charges
        local auraInstanceID = aura.auraInstanceID -- Unique identifier for the aura instance
        local canApplyAura = aura.canApplyAura -- Whether the player can apply this aura
        local charges = aura.charges or 0 -- Current number of charges
        local auratype = aura.dispelName or "n/a" -- The dispel type (e.g., "Magic", "Curse")
        local duration = aura.duration -- Duration of the aura
        local expirationTime = aura.expirationTime -- When the aura will expire
        local icon = aura.icon -- The icon texture ID for the aura
        local isBossAura = aura.isBossAura -- Whether the aura was applied by a boss
        local isFromPlayerOrPlayerPet = aura.isFromPlayerOrPlayerPet -- Whether the aura was applied by a player or their pet
        local isHarmful = aura.isHarmful -- Whether the aura is a debuff
        local isHelpful = aura.isHelpful -- Whether the aura is a buff
        local isNameplateOnly = aura.isNameplateOnly -- Whether the aura should appear on nameplates only
        local isRaid = aura.isRaid -- Whether the aura meets the RAID filter conditions
        local isStealable = aura.isStealable -- Whether the aura can be stolen
        local maxCharges = aura.maxCharges or 0 -- Maximum number of charges
        local name = aura.name -- The name of the aura
        local nameplateShowAll = aura.nameplateShowAll -- Whether the aura should always be shown on nameplates
        local nameplateShowPersonal = aura.nameplateShowPersonal -- Whether the aura should only be shown on nameplates if applied by you
        local points = aura.points or {} -- Some auras return additional values for the tooltip
        local sourceUnit = aura.sourceUnit or nil -- The unit that applied the aura
        local spellId = aura.spellId -- The spell ID of the aura
        local timeMod = aura.timeMod or 1 -- Modifier for the aura's duration, often related to haste effects

        if(debug~=nil)then                                                      --         if(debug~=nil)then
            print("Aura details", aura)                                     --             print("aura args",UnitAura(unit, i, filter))
            print("Aura name", name)                                        --             print("aura name",name)
            print("Aura expiration", expirationTime-_now)                 --             print("aura expire",expirationTime-_now)
            print("Aura sourceUnit", sourceUnit)                 

        end                                                                 --         end


        if (name == spell and (not(excludePlayer) or (sourceUnit and not UnitIsUnit(sourceUnit, "player")))) then       --         if(name == spell and (not(excludePlayer) or source ~= "player")) then
                return expirationTime - _now, sourceUnit, applications, auratype ~= nil and auratype or "n/a"           --             return expirationTime-_now,source,count,auratype ~= nil and auratype or "n/a"
            end                                                                                                         --         end
        end                                                                                                             --     end                                                                                              
                         

    -- sometimes it's convenient to be able to say "remaining < 5" and not worry about remaining == 0
    if high_if_missing_flag then        --     if high_if_missing_flag then
        return 999,_null,0,"n/a"     --         return 999,_null,0,"n/a"
    end                                 --     end
                                        
    return 0,_null,0,"n/a"           --     return 0,_null,0,"n/a"
end                                     -- end 


--PLAYER|
function RemainingDebuff(spell,unit)
    -- Debugging: Log the function call detailsd
    --  print("Checking RemainingDebuff for spell:", spell, "on unit:", unit)
    --              (spell,unit,filter,excludePlayer,debug,high_if_missing_flag)
    return CheckAura(spell,unit,"HARMFUL",nil)
end

function RemainingBuff(spell,unit)
    -- print("Checking RemainingBuff for spell:", spell, "on unit:", unit)
    --              (spell,unit,filter,excludePlayer,debug,high_if_missing_flag)
    return CheckAura(spell,unit,"HELPFUL",nil)
end

function RemainingDebuffFromMe(spell,unit)
    --  print("Checking RemainingDebuffFromMe for spell:", spell, "on unit:", unit)
    --              (spell,unit,filter,excludePlayer,debug,high_if_missing_flag)
    return CheckAura(spell,unit,"HARMFUL|PLAYER",false)
end

function RemainingBuffFromMe(spell,unit)
    --  print("Checking RemainingBuffFromMe for spell:", spell, "on unit:", unit)
    --              (spell,unit,filter,excludePlayer,debug,high_if_missing_flag)
    return CheckAura(spell,unit,"HELPFUL|PLAYER",false)
end

function RemainingDebuffFromOthers(spell,unit)
    --  print("Checking RemainingDebuffFromOthers for spell:", spell, "on unit:", unit)
    --              (spell,unit,filter,excludePlayer,debug,high_if_missing_flag)
    return CheckAura(spell,unit,"HARMFUL",true)
end

function RemainingBuffFromOthers(spell,unit)
    --  print("Checking RemainingBuffFromOthers for spell:", spell, "on unit:", unit)
    --              (spell,unit,filter,excludePlayer,debug,high_if_missing_flag)
    return CheckAura(spell,unit,"HELPFUL",true)
end

--used to track things like zombies and totems that otherwise suck for tracking.
--tell it how long the spell lasts, and it'll check events for last cast to figure out how long it's got left.
-- /run print(UntrackableUnitStatus("Apocalypse",15))
-- /run print(LastCastSpellAtAnything("Apocalypse"))
function UntrackableUnitStatus(spell,unit_duration)
    local last_cast = LastCastSpellAtAnything(spell)

    remaining_duration = 0

    if last_cast < unit_duration then
        remaining_duration = unit_duration - last_cast
    end

    return remaining_duration
end
