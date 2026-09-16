-- pvp talent dump, printed when you enter combat
local function ArePvpTalentsActive()
    local talents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
    for _, pvptalent in pairs(talents) do
        local spellID = select(6, GetPvpTalentInfoByID(pvptalent))
        if IsPlayerSpell(spellID) then
            return true
        end
    end
end 
local function OnEvent(self, event, ...)
    local status = ArePvpTalentsActive() and "active" or "not active"
     --print("PvP Talents are "..status)
end 
local f = CreateFrame("Frame")
f:RegisterEvent("SPELLS_CHANGED")
f:SetScript("OnEvent", OnEvent)
-- end pvp talent dump script

local _paladin  = {}
local _spell  = {}
local _cd     = {}
local _buff   = {}
local _debuff = {}

local _unitids = delphi.unitids
local _unit    = delphi.unit
local _instant = delphi.pythia.instant
local _global  = delphi.pythia.global



--Miscellaneous
_spell.racial = "Every Man for Himself"  -- Assuming Human
_spell.healthstone = "Healthstone"
_spell.forbearance = "Forbearance"

--Shadowlands Covenant
_spell.kyrian_divine_toll = "Divine Toll"
_spell.kyrian_summon_steward = "Summon Steward"
_spell.kyrian_phial = "Phial of Serenity"  -- /use item:177278

_spell.necrolord_vanquishers_hammer = "Vanquisher's Hammer"
_spell.necrolord_fleshcraft = "Fleshcraft"

_spell.venthyr_ashen_hallow = "Ashen Hallow"
_spell.venthyr_mindgames = "Mindgames(Venthyr)"  -- If applicable

_spell.night_fae_blessing_of_spring = "Blessing of Spring"
_spell.night_fae_blessing_of_summer = "Blessing of Summer"
_spell.night_fae_blessing_of_autumn = "Blessing of Autumn"
_spell.night_fae_blessing_of_winter = "Blessing of Winter"
_spell.night_fae_soulshape = "Soulshape"

--Paladin All
_spell.devotion_aura = "Devotion Aura"
_spell.divine_shield = "Divine Shield"
_spell.lay_on_hands = "Lay on Hands"
_spell.blessing_of_freedom = "Blessing of Freedom"
_spell.blessing_of_protection = "Blessing of Protection"
_spell.blessing_of_sacrifice = "Blessing of Sacrifice"
_spell.cleanse = "Cleanse"
_spell.flash_of_light = "Flash of Light"
_spell.holy_light = "Holy Light"
_spell.hammer_of_justice = "Hammer of Justice"
_spell.crusader_strike = "Crusader Strike"
_spell.judgment = "Judgment"
_spell.word_of_glory = "Word of Glory"
_spell.consecration = "Consecration"
_spell.hammer_of_wrath = "Hammer of Wrath"
_spell.avenging_wrath = "Avenging Wrath"
_spell.shield_of_the_righteous = "Shield of the Righteous"
_spell.divine_storm = "Divine Storm"

--Paladin Talents
--Row 1 Talents
_spell.final_verdict = "Final Verdict"
_spell.execution_sentence = "Execution Sentence"
_spell.crusade = "Crusade"
--Row 2 Talents
_spell.empowered_seals = "Empowered Seals"
_spell.greater_judgment = "Greater Judgment"
_spell.justicar_vengeance = "Justicar's Vengeance"
--Row 3 Talents
_spell.blinding_light = "Blinding Light"
_spell.fist_of_justice = "Fist of Justice"
_spell.repentence = "Repentance"
--Row 4 Talents
_spell.unbreakable_spirit = "Unbreakable Spirit"
_spell.cavalier = "Cavalier"
_spell.eye_for_an_eye = "Eye for an Eye"
--Row 5 Talents
_spell.seraphim = "Seraphim"
_spell.holy_avenger = "Holy Avenger"
_spell.divine_purpose = "Divine Purpose"
--Row 6 Talents
_spell.divine_intervention = "Divine Intervention"
_spell.final_stand = "Final Stand"
_spell.hand_of_the_protector = "Hand of the Protector"
--Row 7 Talents
_spell.holy_prism = "Holy Prism"
_spell.light_hammer = "Light's Hammer"
_spell.blessed_hammer = "Blessed Hammer"

_spell.beacon_of_faith = "Beacon of Faith"
_spell.beacon_of_light = "Beacon of Light"

--Paladin PvP Talents
_spell.luminescence = "Luminescence"
_spell.divine_favor = "Divine Favor"
_spell.hallowed_ground = "Hallowed Ground"
_spell.lights_grace = "Light's Grace"
_spell.law_and_order = "Law and Order"
_spell.sanctified_wrath = "Sanctified Wrath"

_spell.petattack        = "petattack"
_spell.changetarget     = "changetarget"


local holy_spec   = 1
local prot_spec   = 2
local ret_spec    = 3



local bind_once = 0
function _paladin.SetBinds()
    if bind_once > 0 then 
        return nil
    end
    bind_once = 1

    CreateIconAndButton("NUMPAD1",170+300,-150,"",2)
    CreateIconAndButton("NUMPAD2",210+300,-150,"",2)
    CreateIconAndButton("NUMPAD3",250+300,-150,"",2)
    
    CreateIconAndButton("NUMPAD4",170+300,-200,"",2)
    -- CreateIconAndButton("NUMPAD5",210+300,-200,"",2)
    CreateIconAndButton("NUMPAD6",250+300,-200,"",2)
    
    -- CreateIconAndButton("NUMPAD0",170+300,-300,"",3)     -- (0=?,1=?,...,N=?)
    -- CreateIconAndButton("NUMPADMINUS",210+300,-300,"",3) -- (0=?,1=?,...,N=?)
    -- CreateIconAndButton("NUMPADPLUS",250+300,-300,"",3)  -- (0=?,1=?,...,N=?)

        BindSpellToUnits(_spell.healthstone,                _unitids.player)
        BindSpellToUnits(_spell.devotion_aura,              _unitids.player)

        -- Paladin Covenant Abilities
        -- BindSpellToUnits(_spell.kyrian_divine_toll,          _unitids.standard_hostile)
        BindSpellToUnits(_spell.kyrian_summon_steward,       _unitids.player)
        BindSpellToUnits(_spell.kyrian_phial,                _unitids.player)
        -- BindSpellToUnits(_spell.necrolord_vanquishers_hammer,_unitids.standard_hostile)
        BindSpellToUnits(_spell.necrolord_fleshcraft,        _unitids.player)
        -- BindSpellToUnits(_spell.venthyr_ashen_hallow,        _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.night_fae_blessing_of_spring,_unitids.standard_friendly)
        -- BindSpellToUnits(_spell.night_fae_blessing_of_summer,_unitids.standard_friendly)
        -- BindSpellToUnits(_spell.night_fae_blessing_of_autumn,_unitids.standard_friendly)
        -- BindSpellToUnits(_spell.night_fae_blessing_of_winter,_unitids.standard_friendly)
        BindSpellToUnits(_spell.night_fae_soulshape,         _unitids.player)

        -- Core Paladin Abilities
        -- BindSpellToUnits(_spell.divine_shield,               _unitids.player)
        -- BindSpellToUnits(_spell.lay_on_hands,                _unitids.standard_friendly)
        -- BindSpellToUnits(_spell.blessing_of_freedom,         _unitids.standard_friendly)
        -- BindSpellToUnits(_spell.blessing_of_protection,      _unitids.standard_friendly)
        -- BindSpellToUnits(_spell.blessing_of_sacrifice,       _unitids.standard_friendly)
        -- BindSpellToUnits(_spell.cleanse,                     _unitids.standard_friendly)
        BindSpellToUnits(_spell.flash_of_light,              _unitids.standard_friendly)
        BindSpellToUnits(_spell.holy_light,                  _unitids.standard_friendly)
        -- BindSpellToUnits(_spell.hammer_of_justice,           _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.crusader_strike,             _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.judgment,                    _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.word_of_glory,               _unitids.standard_friendly)
        -- BindSpellToUnits(_spell.consecration,                _unitids.player) -- Affects area, not a specific unit
        -- BindSpellToUnits(_spell.hammer_of_wrath,             _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.avenging_wrath,              _unitids.player)
        -- BindSpellToUnits(_spell.shield_of_the_righteous,     _unitids.player)
        -- BindSpellToUnits(_spell.divine_storm,                _unitids.standard_hostile)

        -- -- Utility and PvP Talents
        -- BindSpellToUnits(_spell.divine_favor,                _unitids.player)
        -- BindSpellToUnits(_spell.light_s_grace,               _unitids.player)
        -- BindSpellToUnits(_spell.luminescence,                _unitids.player)
        -- BindSpellToUnits(_spell.sanctified_wrath,            _unitids.player)
        -- BindSpellToUnits(_spell.law_and_order,               _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.hallowed_ground,             _unitids.player) -- Affects area, not a specific unit
        -- BindSpellToUnits(_spell.blessed_hammer,              _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.final_stand,                 _unitids.player)
        -- BindSpellToUnits(_spell.hand_of_the_protector,       _unitids.standard_friendly)
        -- BindSpellToUnits(_spell.cavalier,                    _unitids.player)
        -- BindSpellToUnits(_spell.holy_prism,                  _unitids.standard_friendly) -- Can be cast on friendlies or hostiles, adjust if needed
        -- BindSpellToUnits(_spell.light_s_hammer,              _unitids.player) -- Affects area, not a specific unit

        --Shadowlands


--    BindSpellToUnits(_spell.shadow_word_pain,           _unitids.raid_hostile)
    --Shared Spells END

    BindMacroToUnits(_spell.petattack,                  _unitids.target,"/petattack [@","]")

    BindMacroToUnits(_spell.changetarget,               _unitids.standard_hostile,"/target [@","]")

    CreateButton("set_focus","Y","/focus")
    CreateButton("set_pet_target","F","/petattack")

    CreateNewLabel("class",350+300,100,function() 
        --local total_melee_attackers, player_melee_attackers, tank_melee_attackers = DK_NearbyMeleeEnemies()
        local combat, time_in_combat, time_ooc, last_fight_duration = CombatStatus()
    
        result = 
        (combat and ("**COMBAT**\n"..math.floor(time_in_combat+0.5)) or " NOT in combat").."\n\n"..
        "\n"..
        "Beacon1 : "..UniqueCountSpellInstances(_spell.beacon_of_light,1).."\n".. -- technically, 30 is the duration of the buff, but if we haven't scourge striked in 10sec, we may as well pretend any existing wounds are lost / unable to be reached
        "Beacon2  : "..UniqueCountSpellInstances(_spell.beacon_of_faith,1).."\n"..
        ""
        
        return 0,result
    end)


     --print("delphi.class.paladin.SetpaladinBinds()")
end

local beacon1_limit = 1 --ua_limit
local beacon2_limit = 1 --ua_limit

local last_time_spent_casting = {}

function RecentCasting(spell,time_since)
    if time_since == nil then
        time_since = 0.5
    end

    local recent_cast  = (last_time_spent_casting[spell] or 0) + time_since > _now
    if recent_cast then
        return true
    end
    return false
end

-- function paladinForm()
--     current_form = GetShapeshiftForm("player") or 0
--     if current_form == 0 then return 0
--     elseif current_form == 1 then return 1
--     else
--         --print("UNKNOWN FORM???")
--         return "UNKNOWN"
--     end
-- end
-- --/run local x = GetShapeshiftForm() print("you are in stance: ",x)


function SpellUnit_NoRecentCasting(spell,unit)
    return not RecentCasting(spell)
end


-- /run print(Botchuloz_40YardHostile("Mind Flay","target"))
function Botchuloz_RangeCheckHarm_40Yard(spell,unit)
    return SpellUnit_RangeCheck("Holy Shock",unit)
end

function Botchuloz_RangeCheckHarm_30Yard(spell,unit)
    return SpellUnit_RangeCheck("Judgment Magic",unit)
end


function Botchuloz_RangeCheckHelp_40Yard(spell,unit)
    return SpellUnit_RangeCheck("Flash of Light",unit)
end

function Botchuloz_HarmDelegate(spell,unit) 
    if UnitIsUnit(unit,"target") then
        return 999
    elseif UnitIsUnit(unit,"targettarget") then
        return 250
    elseif UnitIsUnit(unit,"focustarget") then
        return 50
    else
        return 1
    end
end

function Botchuloz_HelpDelegate(spell,unit) 
    if UnitIsUnit(unit,"target") then
        return 999
    elseif UnitIsUnit(unit,"targettarget") then
        return 750
    elseif UnitIsUnit(unit,"focustargettarget") then
        return 500
    elseif UnitIsUnit(unit,"focus") then
        return 250
    else
        return 1
    end
end


function Botchuloz_SpellUnit_Help_Rank_Shield(spell,unit)
    local unit_role  = UnitGroupRolesAssigned(unit) or ""
    local unit_health_percent = _unit[unit].health.percent

    if unit_role == "TANK" then
        return true
    elseif unit_role == "HEALER" and unit_health_percent < 0.70 then
        return true
    elseif UnitIsUnit(unit,"targettarget") then
        return true
    elseif UnitIsUnit(unit,"focustargettarget") then
        return true
    elseif UnitIsUnit(unit,"target") then
        return true
   elseif unit_health_percent < 0.50 then
        return true
    end
    return false
end


function Botchuloz_Prayer_of_Mending_Rank(spell,unit)
    local unit_role  = UnitGroupRolesAssigned(unit) or ""
    local unit_health_percent = _unit[unit].health.percent

    if unit_role == "TANK" then
        return true
    elseif unit_health_percent < 0.90 then
        return true
    end
    return false
end


function Botchuloz_SpellUnit_Help_Power_Infusion_Rank(spell,unit)
    local unit_role  = UnitGroupRolesAssigned(unit) or ""
    local unit_health_percent = _unit[unit].health.percent

    if unit_role == "DAMAGER" then
        return true
    elseif UnitIsUnit(unit,"player") then
        return true
    end
    return false
end




function Botchuloz_Circle_of_Healing_Detail(threshold_health,threshold_units)
    local deficit = {}
    for i,unit in next,_unitids.standard_friendly do
        if delphi.unit[unit].friendly then
            local unit_health_deficit   = delphi.unit[unit].health.deficit
            local unit_guid             = delphi.unit[unit].guid
            deficit[unit_guid]          = unit_health_deficit
        end
    end

    local counter = 0
    for unit_guid,unit_health_deficit in next,deficit do
        if unit_health_deficit >= threshold_health then
            counter = counter + 1
        end
    end
    return counter >= threshold_units
end

function GroupHealthDeficit()
    local deficit = {}
    for i,unit in next,_unitids.standard_friendly do
        if delphi.unit[unit].friendly then
            local unit_health_deficit   = delphi.unit[unit].health.deficit
            local unit_guid             = delphi.unit[unit].guid
            deficit[unit_guid]          = unit_health_deficit
        end
    end

    local total_deficit = 0
    for unit_guid,unit_health_deficit in next,deficit do
        total_deficit = total_deficit + unit_health_deficit
    end
    return total_deficit
end


function SpellUnit_ForbearanceExpired(spell,unit)
     return SpellUnit_MyDebuffExpired(_spell.forbearance,unit)
end

-- function DevouringPlagueInsanityCost()
--         if have_minds_eye_talent then 
--                 return 45
--         elseif have_distorted_reality_talent then
--                 return 55 
--         else 
--                 return 50
--         end 
-- end

    -- function pvp_zone_or_pvp_target()
    --     local name,type = GetInstanceInfo()
    --     if type == "arena" or type == "pvp" then
    --         return true
    --     elseif SpellUnit_UnitAliveAndHostile("","target") and UnitPlayerControlled("target") then
    --         return true
    --     end
    --     return false
    -- end


    function healthstone_count()
        --https://www.wowhead.com/item=5512/healthstone
        local healthstone = 5512
        if C_Container and C_Container.GetItemCount then
            return C_Container.GetItemCount(healthstone)
        else
            return GetItemCount(healthstone)
        end
    end
    
    function healthstone_cooldown()
        local startTime, duration, enable
        if C_Container and C_Container.GetItemCooldown then
            startTime, duration, enable = C_Container.GetItemCooldown(5512)
        else
            startTime, duration, enable = GetItemCooldown(5512)
        end
    
        if enable == 1 and duration == 0 then
            return 0 -- Ready to use
        else 
            return 1 -- On cooldown or not usable
        end
    end
    
    function phial_count()
        --https://www.wowhead.com/item=177278/phial-of-serenity
        local phial = 177278
        if C_Container and C_Container.GetItemCount then
            return C_Container.GetItemCount(phial)
        else
            return GetItemCount(phial)
        end
    end
    
    function phial_cooldown()
        local startTime, duration, enable
        if C_Container and C_Container.GetItemCooldown then
            startTime, duration, enable = C_Container.GetItemCooldown(177278)
        else
            startTime, duration, enable = GetItemCooldown(177278)
        end
    
        if enable == 1 and duration == 0 then
            return 0 -- Ready to use
        else 
            return 1 -- On cooldown or not usable
        end
    end
    



function PaladinMovementStatus()
    local moving,moving_for,stationary,stationary_for,speed = MovementStatus()
    if _unit.player.buff["Spatial Paradox"].remaining > 0.3 then
        stationary = true
        stationary_for = 20
        moving = false
        moving_for = 0
        speed = 0
    end
    return moving,moving_for,stationary,stationary_for,speed
end





local last_mounted = 0
function _paladin.CoreLogic()
    local moving,moving_for,stationary,stationary_for,speed = PaladinMovementStatus()
    local combat, time_in_combat, time_ooc, last_fight_duration = CombatStatus()

    local holy_power    = delphi.resource.holy_power
    local mana_percent  = delphi.resource.mana_percent
    local current_cast  = delphi.unit.player.cast_name
    last_time_spent_casting[current_cast] = _now -- note, this does include "" always, because when casting nothing
    
    if IsMounted() then
        last_mounted = _now
    end

    if RedLight() then
        _instant.Off()
    -- elseif combat and not SpellUnit_UnitAliveAndHostile("current_target","target") then
    elseif combat and delphi.unit.pet.friendly and not delphi.unit.pettarget.hostile then
        _instant.SetSpellUnit("petattack","target")
    else
        _instant.Off()
    end

    local player_health,player_health_perc,player_health_max     = UnitHealthInfo("player")

    local mc_off,mc_on                 = BiStateCheck("NUMPAD1","!mc","mc")
    local cd_on,cd_off                      = BiStateCheck("NUMPAD2","cd","!cd")
    local heal_on,dps_on                    = BiStateCheck("NUMPAD3","healer","dpser")
    local dps_off = heal_on
    local heal_off = dps_on

    local pvp_off,pvp_on                    = BiStateCheck("NUMPAD4","pve","pvp")
    if pvp_zone_or_pvp_target() then
        pvp_on  = true
        pvp_off = false
    end

    -- local cd_on,cd_off                      = BiStateCheck("NUMPAD5","cd","!cd")
    local regular_healer,attack_healer      = BiStateCheck("NUMPAD6","Heal","HealAttk")    
    
    -- local army_auto,army_force,army_off     = TriStateCheck("NUMPAD0","army+","army","!army")
    -- local army_auto,army_force,army_off     = TriStateCheck("NUMPADMINUS","army+","army","!army")
    -- local army_auto,army_force,army_off     = TriStateCheck("NUMPADPLUS","army+","army","!army")

        --     -- Row 1 Talents
        --     local have_lay_on_hands = IsPlayerSpell(633) -- https://www.wowhead.com/spell=633/lay-on-hands /run print(IsPlayerSpell(633))
        --     local have_blessing_of_freedom = IsPlayerSpell(1044) -- https://www.wowhead.com/spell=1044/blessing-of-freedom /run print(IsPlayerSpell(1044))
        --     local have_hammer_of_wrath = IsPlayerSpell(24275) -- https://www.wowhead.com/spell=24275/hammer-of-wrath /run print(IsPlayerSpell(24275))

        --     -- Row 2 Talents
        --     local have_improved_cleanse = IsPlayerSpell(4987) -- https://www.wowhead.com/spell=4987/improved-cleanse /run print(IsPlayerSpell(4987))
        --     local have_auras_of_the_resolute = IsPlayerSpell(465) -- https://www.wowhead.com/spell=465/auras-of-the-resolute /run print(IsPlayerSpell(465))
        --     local have_obduracy = IsPlayerSpell(317920) -- https://www.wowhead.com/spell=317920/obduracy /run print(IsPlayerSpell(317920))
        --     local have_crusader_aura = IsPlayerSpell(32223) -- https://www.wowhead.com/spell=32223/crusader-aura /run print(IsPlayerSpell(32223))
        --     local have_turn_evil = IsPlayerSpell(10326) -- https://www.wowhead.com/spell=10326/turn-evil /run print(IsPlayerSpell(10326))

        --     -- Row 3 Talents
        --     local have_fist_of_justice = IsPlayerSpell(198054) -- https://www.wowhead.com/spell=198054/fist-of-justice /run print(IsPlayerSpell(198054))
        --     local have_divine_steed = IsPlayerSpell(190784) -- https://www.wowhead.com/spell=190784/divine-steed /run print(IsPlayerSpell(190784))
        --     local have_greater_judgment = IsPlayerSpell(218178) -- https://www.wowhead.com/spell=218178/greater-judgment /run print(IsPlayerSpell(218178))

        --     -- Row 4 Talents
        --     local have_repentance = IsPlayerSpell(20066) -- https://www.wowhead.com/spell=20066/repentance /run print(IsPlayerSpell(20066))
        --     local have_blinding_light = IsPlayerSpell(115750) -- https://www.wowhead.com/spell=115750/blinding-light /run print(IsPlayerSpell(115750))
        --     local have_cavalier = IsPlayerSpell(230332) -- https://www.wowhead.com/spell=230332/cavalier /run print(IsPlayerSpell(230332))
        --     local have_seasoned_warhorse = IsPlayerSpell(317907) -- https://www.wowhead.com/spell=317907/seasoned-warhorse /run print(IsPlayerSpell(317907))
        --     local have_rebuke = IsPlayerSpell(96231) -- https://www.wowhead.com/spell=96231/rebuke /run print(IsPlayerSpell(96231))

        --     -- Row 5 Talents
        --     local have_holy_aegis = IsPlayerSpell(86659) -- https://www.wowhead.com/spell=86659/holy-aegis /run print(IsPlayerSpell(86659))
        --     local have_avenging_wrath = IsPlayerSpell(31884) -- https://www.wowhead.com/spell=31884/avenging-wrath /run print(IsPlayerSpell(31884))
        --     local have_justification = IsPlayerSpell(273526) -- https://www.wowhead.com/spell=273526/justification /run print(IsPlayerSpell(273526))
        --     local have_punishment = IsPlayerSpell(275778) -- https://www.wowhead.com/spell=275778/punishment /run print(IsPlayerSpell(275778))

        --     -- Row 6 Talents
        --     local have_golden_path = IsPlayerSpell(124974) -- https://www.wowhead.com/spell=124974/golden-path /run print(IsPlayerSpell(124974))
        --     local have_echoing_blessings = IsPlayerSpell(213654) -- https://www.wowhead.com/spell=213654/echoing-blessings /run print(IsPlayerSpell(213654))
        --     local have_blessing_of_sacrifice = IsPlayerSpell(6940) -- https://www.wowhead.com/spell=6940/blessing-of-sacrifice /run print(IsPlayerSpell(6940))
        --     local have_sanctified_plates = IsPlayerSpell(254821) -- https://www.wowhead.com/spell=254821/sanctified-plates /run print(IsPlayerSpell(254821))
        --     local have_blessing_of_protection = IsPlayerSpell(1022) -- https://www.wowhead.com/spell=1022/blessing-of-protection /run print(IsPlayerSpell(1022))
        --     local have_lightforged_blessing = IsPlayerSpell(280190) -- https://www.wowhead.com/spell=280190/lightforged-blessing /run print(IsPlayerSpell(280190))

        --     -- Row 7 Talents
        --     local have_seal_of_mercy = IsPlayerSpell(183778) -- https://www.wowhead.com/spell=183778/seal-of-mercy /run print(IsPlayerSpell(183778))
        --     local have_afterimage = IsPlayerSpell(281178) -- https://www.wowhead.com/spell=281178/afterimage /run print(IsPlayerSpell(281178))
        --     local have_sacrifice_of_the_just = IsPlayerSpell(320401) -- https://www.wowhead.com/spell=320401/sacrifice-of-the-just /run print(IsPlayerSpell(320401))
        --     local have_recompense = IsPlayerSpell(317920) -- https://www.wowhead.com/spell=317920/recompense /run print(IsPlayerSpell(317920))
        --     local have_unbreakable_spirit = IsPlayerSpell(114154) -- https://www.wowhead.com/spell=114154/unbreakable-spirit /run print(IsPlayerSpell(114154))
        --     local have_improved_blessing_of_protection = IsPlayerSpell(207018) -- https://www.wowhead.com/spell=207018/improved-blessing-of-protection /run print(IsPlayerSpell(207018))
        --     local have_touch_of_light = IsPlayerSpell(317920) -- https://www.wowhead.com/spell=317920/touch-of-light /run print(IsPlayerSpell(317920))

        --     -- Row 8 Talents
        --     local have_strength_of_conviction = IsPlayerSpell(208598) -- https://www.wowhead.com/spell=208598/strength-of-conviction /run print(IsPlayerSpell(208598))
        --     local have_judgment_of_light = IsPlayerSpell(183778) -- https://www.wowhead.com/spell=183778/judgment-of-light /run print(IsPlayerSpell(183778))
        --     local have_seal_of_might = IsPlayerSpell(317920) -- https://www.wowhead.com/spell=317920/seal-of-might /run print(IsPlayerSpell(317920))
        --     local have_divine_purpose = IsPlayerSpell(223817) -- https://www.wowhead.com/spell=223817/divine-purpose /run print(IsPlayerSpell(223817))
        --     local have_seal_of_alacrity = IsPlayerSpell(317920) -- https://www.wowhead.com/spell=317920/seal-of-alacrity /run print(IsPlayerSpell(317920))
        --     local have_incandescence = IsPlayerSpell(317920) -- https://www.wowhead.com/spell=317920/incandescence /run print(IsPlayerSpell(317920))
        --     local have_faiths_armor = IsPlayerSpell(317920) -- https://www.wowhead.com/spell=317920/faiths-armor /run print(IsPlayerSpell(317920))

        --     -- Row 9 Talents
        --     local have_of_dusk_and_dawn = IsPlayerSpell(385129) -- https://www.wowhead.com/spell=385129/of-dusk-and-dawn /run print(IsPlayerSpell(385129))
        --     local have_divine_toll = IsPlayerSpell(304971) -- https://www.wowhead.com/spell=304971/divine-toll /run print(IsPlayerSpell(304971))
        --     local have_seal_of_the_crusader = IsPlayerSpell(385428) -- https://www.wowhead.com/spell=385428/seal-of-the-crusader /run print(IsPlayerSpell(385428))

        --     -- Row 10 Talents
        --     local have_seal_of_order = IsPlayerSpell(317920) -- https://www.wowhead.com/spell=317920/seal-of-order /run print(IsPlayerSpell(317920))
        --     local have_fading_light = IsPlayerSpell(317920) -- https://www.wowhead.com/spell=317920/fading-light /run print(IsPlayerSpell(317920))
        --     local have_divine_resonance = IsPlayerSpell(384042) -- https://www.wowhead.com/spell=384042/divine-resonance /run print(IsPlayerSpell(384042))
        --     local have_quickened_invocation = IsPlayerSpell(317920) -- https://www.wowhead.com/spell=317920/quickened-invocation /run print(IsPlayerSpell(317920))
        --     local have_vanguards_momentum = IsPlayerSpell(383228) -- https://www.wowhead.com/spell=383228/vanguards-momentum /run print(IsPlayerSpell(383228))

        -- --Shadowlands
        --     -- local have_summon_pocopoc_talent = IsPlayerSpell(360078)                        -- https://www.wowhead.com/spell=360078/summon-pocopoc      /run print(IsPlayerSpell(360078))
            local have_kyrian_faciton = IsPlayerSpell(321076)                       -- https://www.wowhead.com/spell=321076/kyrian    /run print(IsPlayerSpell(321076))
            local have_necrolord_faciton = IsPlayerSpell(321078)                    -- https://www.wowhead.com/spell=321078/necrolord /run print(IsPlayerSpell(321078))
            local have_venthyr_faciton = IsPlayerSpell(321079)                      -- https://www.wowhead.com/spell=321079/venthyr  /run print(IsPlayerSpell(321079))
            local have_night_fae_faciton = IsPlayerSpell(321077)                    -- https://www.wowhead.com/spell=321077/night-fae     /run print(IsPlayerSpell(321077))
        -- --  /run print(IsPlayerSpell(375901))
        -- --  /run print(itemcd(177278))
        

    local in_party  = (IsInRaid() == false) and (IsInGroup() == true)
    local in_raid   = IsInRaid()  --/Print UnitExists("raid1")
    local in_group  = IsInGroup() --/run print(IsInGroup())

    

    local spam_string = ""
    _global.Off()

    if 1==0 then
        --do nothing
    
    elseif RedLight() then
        _global.Off()
        
    elseif delphi.unit.player.channelling and delphi.unit.player.cast_remaining > 0.1 then
        --print("CHANNELLING")
        _global.Off()
    -- elseif _unit.player.buff[_spell.fort].remaining == 0 and not combat then


                elseif CastSpellUnits(
                        _spell.kyrian_steward
                        ,_unitids.player
                        ,RemainingCooldown(_spell.kyrian_steward) < 0.5 and shadowlands() and have_kyrian_faciton and not combat and phial_count() < 3
                        ,{
                            SpellUnit_AliveAndFriendly
                        }
                    ) then --print("Steward")
            
                    
                elseif CastSpellUnits(
                    _spell.kyrian_phial
                    ,_unitids.player
                    ,RemainingCooldown(_spell.kyrian_phial) < 0.5 and shadowlands() and have_kyrian_faciton and combat and phial_count() > 0 and phial_cooldown() == 0
                    ,{
                        SpellUnit_AliveAndFriendly
                        ,SpellUnit_HealthBelow40
                    }
                ) then --print("Phial")

            
                elseif CastSpellUnits(
                    _spell.necrolord_fleshcraft
                    ,_unitids.player
                    ,RemainingCooldown(_spell.necrolord_fleshcraft) < 0.5 and shadowlands() and have_necrolord_faciton and stationary
                    ,{
                        SpellUnit_MyBuffExpired
                    }
                ) then --print("Fleshcraft")
                

            
                    elseif CastSpellUnits(
                        _spell.night_fae_soulshape
                        ,_unitids.player
                        ,RemainingCooldown(_spell.night_fae_soulshape) < 0.5 and shadowlands() and have_night_fae_faciton and not stationary and combat and player_health_perc < 0.7
                        ,{
                            SpellUnit_MyBuffExpired
                            ,SpellUnit_AliveAndFriendly
                        }
                    ) then --print("night_fae_soulshape")
                    
            
                    elseif CastSpellUnits(
                        _spell.night_fae_soulshape
                        ,_unitids.player
                        ,RemainingCooldown(_spell.night_fae_soulshape) < 0.5 and shadowlands() and have_night_fae_faciton and not combat and IsResting() == true
                        ,{
                            SpellUnit_MyBuffExpired
                            ,SpellUnit_AliveAndFriendly
                            ,SpellUnit_NoRecasting
                        }
                    ) then --print("night_fae_soulshape")
                    


                elseif CastSpellUnits(
                    _spell.healthstone
                    ,_unitids.player
                    ,RemainingCooldown(_spell.healthstone) < 0.5 and combat and healthstone_count() > 0 and healthstone_cooldown() == 0
                    ,{
                        SpellUnit_AliveAndFriendly
                        ,SpellUnit_HealthBelow30
                    }
                ) then --print("healthstone")

       

                elseif CastSpellUnits(
                    _spell.devotion_aura
                    ,_unitids.player
                    ,RemainingCooldown(_spell.devotion_aura) < 0.5 and not combat
                    ,{
                        SpellUnit_MyBuffExpired
                    }
                ) then --print("self:fort")

-- --

-- 88        88    ,ad8888ba,    88           8b        d8  
-- 88        88   d8"'    `"8b   88            Y8,    ,8P   
-- 88        88  d8'        `8b  88             Y8,  ,8P    
-- 88aaaaaaaa88  88          88  88              "8aa8"     
-- 88""""""""88  88          88  88               `88'      
-- 88        88  Y8,        ,8P  88                88       
-- 88        88   Y8a.    .a8P   88                88       
-- 88        88    `"Y8888Y"'    88888888888       88         
-- -- -- --  http://patorjk.com/software/taag/#p=display&h=0&v=0&f=Univers&t=HOLY                                                    

    elseif holy_spec == delphi.spec then 
        --Spec Spells START
        -- BindSpellToUnits(_spell.holy_nova,                  _unitids.player)

    
        --Spec Spells END
        spam_string = "holy_"   
        if pvp_off then 
            spam_string = spam_string .. "pve_"
            if GodlyIsDD() then --print("do some single target shit")
                spam_string = spam_string .. "dd_"
                if heal_on then --print("do some healing")
                    spam_string = spam_string .. "heal_"
                    if regular_healer then 
                        spam_string = spam_string .. "regular_"
                         --print(spam_string)

                         if 1 == 0 then

                                elseif CastSpellUnits(
                                    _spell.flash_of_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            --,SpellUnit_MediumHealth
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                        ) then --print("Flash ofLight line 736")

                                elseif CastSpellUnits(
                                    _spell.holy_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            --,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Holy light 747")


                                             
                 else _global.Off()
                 end



                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)
                                if 1 == 0 then
                                            

                                elseif CastSpellUnits(
                                    _spell.flash_of_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            --,SpellUnit_MediumHealth
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                        ) then --print("Flash ofLight")

                                elseif CastSpellUnits(
                                    _spell.holy_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            --,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Flash Heal OOC")

                  
                                    else _global.Off()
                                    end
                                        


                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                elseif dps_on then
                    spam_string = spam_string .. "dps_"
                     --print(spam_string)
                                            if 1 == 0 then
                                                                    
                                            elseif CastSpellUnits(
                                                _spell.flash_of_light
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_RangeCheck
                                                        --,SpellUnit_MediumHealth
                                                    }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                                    ) then --print("Flash ofLight")
            
                                            elseif CastSpellUnits(
                                                _spell.holy_light
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Flash Heal OOC")
                                                                                            
                    
                                                                
                                    else _global.Off()
                                    end



                else
                    spam_string = spam_string .. "wtf?"
                     --print(spam_string)
                end
            elseif GodlyIsAOE() then
                spam_string = spam_string .. "aoe_" 
                if heal_on then --print("do some aoe shit")
                    spam_string = spam_string .. "heal_"    
                    if regular_healer then 
                        spam_string = spam_string .. "regular_"
                         --print(spam_string)

                                    if 1 == 0 then
                                                        

                                    elseif CastSpellUnits(
                                        _spell.flash_of_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_RangeCheck
                                                --,SpellUnit_MediumHealth
                                            }
                                            ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Flash ofLight")
    
                                    elseif CastSpellUnits(
                                        _spell.holy_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Flash Heal OOC")
                
                                                        
                            else _global.Off()
                            end




                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)

                                    if 1 == 0 then
                                                

                                    elseif CastSpellUnits(
                                        _spell.flash_of_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_RangeCheck
                                                --,SpellUnit_MediumHealth
                                            }
                                            ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Flash ofLight")
    
                                    elseif CastSpellUnits(
                                        _spell.holy_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Flash Heal OOC")
                
                                                        
                            else _global.Off()
                            end                         


                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                elseif dps_on then
                    spam_string = spam_string .. "dps_"
                     --print(spam_string)

                                        if 1 == 0 then
                                                                                        

                                        elseif CastSpellUnits(
                                            _spell.flash_of_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    --,SpellUnit_MediumHealth
                                                }
                                                ,RankUnits_MaxHealthDeficitPercent
                                                ) then --print("Flash ofLight")
        
                                        elseif CastSpellUnits(
                                            _spell.holy_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Flash Heal OOC")
                        
                                                            
                                else _global.Off()
                                end




                else
                    spam_string = spam_string .. "wtf?"
                     --print(spam_string)
                end
            end
        elseif pvp_on then
            spam_string = spam_string .. "pvp_"
            if GodlyIsDD() then --print("do some single target shit")
                spam_string = spam_string .. "dd_"  
                if heal_on then --print("do some healing")
                    spam_string = spam_string .. "heal_"    
                    if regular_healer then 
                        spam_string = spam_string .. "regular"
                         --print(spam_string)

                                if 1 == 0 then
                                                        

                                elseif CastSpellUnits(
                                    _spell.flash_of_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            --,SpellUnit_MediumHealth
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                        ) then --print("Flash ofLight")

                                elseif CastSpellUnits(
                                    _spell.holy_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            --,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Flash Heal OOC")
                                                    
                        else _global.Off()
                        end



                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)

                                    if 1 == 0 then
                                                
                                    elseif CastSpellUnits(
                                        _spell.flash_of_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_RangeCheck
                                                --,SpellUnit_MediumHealth
                                            }
                                            ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Flash ofLight")
    
                                    elseif CastSpellUnits(
                                        _spell.holy_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Flash Heal OOC")
                                                            
                            else _global.Off()
                            end

                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                elseif dps_on then
                    spam_string = spam_string .. "dps_"
                     --print(spam_string)

                                    if 1 == 0 then
                                                                                            
                                    elseif CastSpellUnits(
                                        _spell.flash_of_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_RangeCheck
                                                --,SpellUnit_MediumHealth
                                            }
                                            ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Flash ofLight")
    
                                    elseif CastSpellUnits(
                                        _spell.holy_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Flash Heal OOC")
                                                            
                            else _global.Off()
                            end





                else
                    spam_string = spam_string .. "wtf?"
                     --print(spam_string)
                end
            elseif GodlyIsAOE() then
                spam_string = spam_string .. "aoe_"
                if heal_on then --print("do some aoe shit")
                    spam_string = spam_string .. "heal_"                    
                    if regular_healer then 
                        spam_string = spam_string .. "regular_"
                         --print(spam_string)

                                        if 1 == 0 then
                                                                        

                                        elseif CastSpellUnits(
                                            _spell.flash_of_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    --,SpellUnit_MediumHealth
                                                }
                                                ,RankUnits_MaxHealthDeficitPercent
                                                ) then --print("Flash ofLight")
        
                                        elseif CastSpellUnits(
                                            _spell.holy_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Flash Heal OOC")
                                                                    
                                else _global.Off()
                                end





                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)
                                if 1 == 0 then
                                                        

                                elseif CastSpellUnits(
                                    _spell.flash_of_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            --,SpellUnit_MediumHealth
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                        ) then --print("Flash ofLight")

                                elseif CastSpellUnits(
                                    _spell.holy_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            --,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Flash Heal OOC")
                                                    
                        else _global.Off()
                        end



                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                elseif dps_on then
                    spam_string = spam_string .. "dps_"
                     --print(spam_string)
                                        if 1 == 0 then
                                                                            

                                        elseif CastSpellUnits(
                                            _spell.flash_of_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    --,SpellUnit_MediumHealth
                                                }
                                                ,RankUnits_MaxHealthDeficitPercent
                                                ) then --print("Flash ofLight")
        
                                        elseif CastSpellUnits(
                                            _spell.holy_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Flash Heal OOC")
                                                                    
                                else _global.Off()
                                end




                else
                    spam_string = spam_string .. "wtf?"
                     --print(spam_string)
                end
            end
        else
            spam_string = spam_string .. "off_"
             --print(spam_string)            
            _global.Off()
        end
--
                                                                                                                                    
-- 88888888ba   88888888ba     ,ad8888ba,    888888888888  88888888888    ,ad8888ba,   888888888888  88    ,ad8888ba,    888b      88  
-- 88      "8b  88      "8b   d8"'    `"8b        88       88            d8"'    `"8b       88       88   d8"'    `"8b   8888b     88  
-- 88      ,8P  88      ,8P  d8'        `8b       88       88           d8'                 88       88  d8'        `8b  88 `8b    88  
-- 88aaaaaa8P'  88aaaaaa8P'  88          88       88       88aaaaa      88                  88       88  88          88  88  `8b   88  
-- 88""""""'    88""""88'    88          88       88       88"""""      88                  88       88  88          88  88   `8b  88  
-- 88           88    `8b    Y8,        ,8P       88       88           Y8,                 88       88  Y8,        ,8P  88    `8b 88  
-- 88           88     `8b    Y8a.    .a8P        88       88            Y8a.    .a8P       88       88   Y8a.    .a8P   88     `8888  
-- 88           88      `8b    `"Y8888Y"'         88       88888888888    `"Y8888Y"'        88       88    `"Y8888Y"'    88      `888  
--http://patorjk.com/software/taag/#p=display&h=0&v=0&f=Univers&t=HOLY                                                                                                                                    
                                                                                                                                    
--
    elseif prot_spec       == delphi.spec then
        --Spec Spells START
        -- BindSpellToUnits(_spell.divine_hymn,                    _unitids.player)
        -- BindSpellToUnits(_spell.symbol_of_hope,                 _unitids.player)
        -- BindSpellToUnits(_spell.holy_nova,                      _unitids.player)




        --Spec Spells END
        
        spam_string = "prot_"
        if pvp_off then 
            spam_string = spam_string .. "pve_"
            if GodlyIsDD() then --print("do some single target shit")
                spam_string = spam_string .. "dd_"
                if heal_on then --print("do some healing")
                    spam_string = spam_string .. "heal_"
                    if regular_healer then 
                        spam_string = spam_string .. "regular_"
                         --print(spam_string)
                            if 1 == 0 then

                            elseif CastSpellUnits(
                                _spell.flash_of_light
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_RangeCheck
                                        --,SpellUnit_MediumHealth
                                    }
                                    ,RankUnits_MaxHealthDeficitPercent
                                    ) then --print("Flash ofLight")

                            elseif CastSpellUnits(
                                _spell.holy_light
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_HealthBelow95
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Flash Heal OOC")


                            else _global.Off()
                            end   

                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)

                                            if 1 == 0 then

                                            elseif CastSpellUnits(
                                                _spell.flash_of_light
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_RangeCheck
                                                        --,SpellUnit_MediumHealth
                                                    }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                                    ) then --print("Flash ofLight")
            
                                            elseif CastSpellUnits(
                                                _spell.holy_light
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Flash Heal OOC")
                                                                                    


                                        else _global.Off()
                                        end   


                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                elseif dps_on then
                    spam_string = spam_string .. "dps_"
                     --print(spam_string)

                                                if 1 == 0 then

                                                elseif CastSpellUnits(
                                                    _spell.flash_of_light
                                                        ,_unitids.standard_friendly
                                                        ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            ,SpellUnit_RangeCheck
                                                            --,SpellUnit_MediumHealth
                                                        }
                                                        ,RankUnits_MaxHealthDeficitPercent
                                                        ) then --print("Flash ofLight")
                
                                                elseif CastSpellUnits(
                                                    _spell.holy_light
                                                        ,_unitids.standard_friendly
                                                        ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            --,SpellUnit_HealthBelow95
                                                            ,SpellUnit_RangeCheck
                                                        }
                                                    ) then --print("Flash Heal OOC")
                


                                            else _global.Off()
                                            end   




                else
                    spam_string = spam_string .. "wtf?"
                     --print(spam_string)
                end
            elseif GodlyIsAOE() then
                spam_string = spam_string .. "aoe_" 
                if heal_on then --print("do some aoe shit")
                    spam_string = spam_string .. "heal_"    
                    if regular_healer then 
                        spam_string = spam_string .. "regular_"
                         --print(spam_string)

                         if 1 == 0 then


                                elseif CastSpellUnits(
                                    _spell.flash_of_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            --,SpellUnit_MediumHealth
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                        ) then --print("Flash ofLight")

                                elseif CastSpellUnits(
                                    _spell.holy_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            --,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Flash Heal OOC")


                         else _global.Off()
                         end   




                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)



                                        if 1 == 0 then

                                            elseif CastSpellUnits(
                                                _spell.flash_of_light
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_RangeCheck
                                                        --,SpellUnit_MediumHealth
                                                    }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                                    ) then --print("Flash ofLight")
            
                                            elseif CastSpellUnits(
                                                _spell.holy_light
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Flash Heal OOC")
        
                                    else _global.Off()
                                    end   





                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                elseif dps_on then
                    spam_string = spam_string .. "dps_"
                     --print(spam_string)



                                        if 1 == 0 then

                                        elseif CastSpellUnits(
                                            _spell.flash_of_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    --,SpellUnit_MediumHealth
                                                }
                                                ,RankUnits_MaxHealthDeficitPercent
                                                ) then --print("Flash ofLight")
        
                                        elseif CastSpellUnits(
                                            _spell.holy_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Flash Heal OOC")
        


                                    else _global.Off()
                                    end   






                else
                    spam_string = spam_string .. "wtf?"
                     --print(spam_string)
                end
            end
        elseif pvp_on then
            spam_string = spam_string .. "pvp_"
            if GodlyIsDD() then --print("do some single target shit")
                spam_string = spam_string .. "dd_"  
                if heal_on then --print("do some healing")
                    spam_string = spam_string .. "heal_"    
                    if regular_healer then 
                        spam_string = spam_string .. "regular"
                         --print(spam_string)

                                            if 1 == 0 then

                                            elseif CastSpellUnits(
                                                _spell.flash_of_light
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_RangeCheck
                                                        --,SpellUnit_MediumHealth
                                                    }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                                    ) then --print("Flash ofLight")
            
                                            elseif CastSpellUnits(
                                                _spell.holy_light
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Flash Heal OOC")
                        
    


                                else _global.Off()
                                end   





                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)


                                                                            if 1 == 0 then

                                                                            elseif CastSpellUnits(
                                                                                _spell.flash_of_light
                                                                                    ,_unitids.standard_friendly
                                                                                    ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        ,SpellUnit_RangeCheck
                                                                                        --,SpellUnit_MediumHealth
                                                                                    }
                                                                                    ,RankUnits_MaxHealthDeficitPercent
                                                                                    ) then --print("Flash ofLight")
                                            
                                                                            elseif CastSpellUnits(
                                                                                _spell.holy_light
                                                                                    ,_unitids.standard_friendly
                                                                                    ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        --,SpellUnit_HealthBelow95
                                                                                        ,SpellUnit_RangeCheck
                                                                                    }
                                                                                ) then --print("Flash Heal OOC")
                                            


                                                                        else _global.Off()
                                                                        end   



                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                elseif dps_on then
                    spam_string = spam_string .. "dps_"
                     --print(spam_string)


                                    if 1 == 0 then

                                    elseif CastSpellUnits(
                                        _spell.flash_of_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_RangeCheck
                                                --,SpellUnit_MediumHealth
                                            }
                                            ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Flash ofLight")
    
                                    elseif CastSpellUnits(
                                        _spell.holy_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Flash Heal OOC")
    

                                else _global.Off()
                                end   


                else
                    spam_string = spam_string .. "wtf?"
                     --print(spam_string)
                end
            elseif GodlyIsAOE() then
                spam_string = spam_string .. "aoe_"
                if heal_on then --print("do some aoe shit")
                    spam_string = spam_string .. "heal_"                    
                    if regular_healer then 
                        spam_string = spam_string .. "regular_"
                         --print(spam_string)


                         if 1 == 0 then

                         elseif CastSpellUnits(
                            _spell.flash_of_light
                                ,_unitids.standard_friendly
                                ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_RangeCheck
                                    --,SpellUnit_MediumHealth
                                }
                                ,RankUnits_MaxHealthDeficitPercent
                                ) then --print("Flash ofLight")

                        elseif CastSpellUnits(
                            _spell.holy_light
                                ,_unitids.standard_friendly
                                ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    --,SpellUnit_HealthBelow95
                                    ,SpellUnit_RangeCheck
                                }
                            ) then --print("Flash Heal OOC")



             else _global.Off()
             end   



                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)

                                        if 1 == 0 then

                                        elseif CastSpellUnits(
                                            _spell.flash_of_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    --,SpellUnit_MediumHealth
                                                }
                                                ,RankUnits_MaxHealthDeficitPercent
                                                ) then --print("Flash ofLight")
        
                                        elseif CastSpellUnits(
                                            _spell.holy_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Flash Heal OOC")
        

                                    else _global.Off()
                                    end   




                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                elseif dps_on then
                    spam_string = spam_string .. "dps_"
                     --print(spam_string)



                                if 1 == 0 then

                                elseif CastSpellUnits(
                                    _spell.flash_of_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            --,SpellUnit_MediumHealth
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                        ) then --print("Flash ofLight")

                                elseif CastSpellUnits(
                                    _spell.holy_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            --,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Flash Heal OOC")

           
                                        else _global.Off()
                                        end   
                        
                        



                else
                    spam_string = spam_string .. "wtf?"
                     --print(spam_string)
                end
            end
        else
            spam_string = spam_string .. "off_"
             --print(spam_string)            
            _global.Off()
        end
--
                                                                                                                                    
-- 88888888ba   88888888888  888888888888  88888888ba   88  88888888ba   88        88  888888888888  88    ,ad8888ba,    888b      88  
-- 88      "8b  88                88       88      "8b  88  88      "8b  88        88       88       88   d8"'    `"8b   8888b     88  
-- 88      ,8P  88                88       88      ,8P  88  88      ,8P  88        88       88       88  d8'        `8b  88 `8b    88  
-- 88aaaaaa8P'  88aaaaa           88       88aaaaaa8P'  88  88aaaaaa8P'  88        88       88       88  88          88  88  `8b   88  
-- 88""""88'    88"""""           88       88""""88'    88  88""""""8b,  88        88       88       88  88          88  88   `8b  88  
-- 88    `8b    88                88       88    `8b    88  88      `8b  88        88       88       88  Y8,        ,8P  88    `8b 88  
-- 88     `8b   88                88       88     `8b   88  88      a8P  Y8a.    .a8P       88       88   Y8a.    .a8P   88     `8888  
-- 88      `8b  88888888888       88       88      `8b  88  88888888P"    `"Y8888Y"'        88       88    `"Y8888Y"'    88      `888  
--http://patorjk.com/software/taag/#p=display&h=0&v=0&f=Univers&t=HOLY                                                                                                                               
                                                                                                                                    
--                                                                                                        
    elseif ret_spec     == delphi.spec then    
        --Spec Spells START
        BindSpellToUnits(_spell.dispersion,                 _unitids.player)
 
        --Spec Spells END
        
        spam_string = "ret_"
        if 1 == 0 then
        -----    
        elseif CastSpellUnits(
            _spell.shadowform
            ,_unitids.player
            ,RemainingCooldown(_spell.shadowform) < 0.5 and _unit.player.buff[_spell.shadowform].remaining == 0 and _unit.player.buff["Voidform"].remaining == 0
        ) then --print("Shadowform")
        -----
        else
            if pvp_off then 
                spam_string = spam_string .. "pve_"
                if GodlyIsDD() then --print("do some single target shit")
                    spam_string = spam_string .. "dd_"
                    if heal_on then --print("do some healing")
                        spam_string = spam_string .. "heal_"
                        if regular_healer then 
                            spam_string = spam_string .. "regular_"
                             --print(spam_string)
                               if 1 == 0 then

                               elseif CastSpellUnits(
                                _spell.flash_of_light
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_RangeCheck
                                        --,SpellUnit_MediumHealth
                                    }
                                    ,RankUnits_MaxHealthDeficitPercent
                                    ) then --print("Flash ofLight")

                            elseif CastSpellUnits(
                                _spell.holy_light
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_HealthBelow95
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Flash Heal OOC")
            
                
                
            
                                else _global.Off()
                                end            
        

                        elseif attack_healer then
                            spam_string = spam_string .. "attack_"
                             --print(spam_string)
                        else
                            spam_string = spam_string .. "wtf?"
                             --print(spam_string)
                        end
                    elseif dps_on then
                        spam_string = spam_string .. "dps_"
                         --print(spam_string)
                        if 1 == 0 then

                        elseif CastSpellUnits(
                            _spell.flash_of_light
                                ,_unitids.standard_friendly
                                ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_RangeCheck
                                    --,SpellUnit_MediumHealth
                                }
                                ,RankUnits_MaxHealthDeficitPercent
                                ) then --print("Flash ofLight")

                        elseif CastSpellUnits(
                            _spell.holy_light
                                ,_unitids.standard_friendly
                                ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    --,SpellUnit_HealthBelow95
                                    ,SpellUnit_RangeCheck
                                }
                            ) then --print("Flash Heal OOC")
 
                        else _global.Off()
                        end            



                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                elseif GodlyIsAOE() then
                    spam_string = spam_string .. "aoe_" 
                    if heal_on then --print("do some aoe shit")
                        spam_string = spam_string .. "heal_"    
                        if regular_healer then 
                            spam_string = spam_string .. "regular_"
                             --print(spam_string)

                                    if 1 == 0 then

                                    elseif CastSpellUnits(
                                        _spell.flash_of_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_RangeCheck
                                                --,SpellUnit_MediumHealth
                                            }
                                            ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Flash ofLight")
    
                                    elseif CastSpellUnits(
                                        _spell.holy_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Flash Heal OOC")
     

                                else _global.Off()
                                end            


                        elseif attack_healer then
                            spam_string = spam_string .. "attack_"
                             --print(spam_string)
                        else
                            spam_string = spam_string .. "wtf?"
                             --print(spam_string)
                        end
                    elseif dps_on then
                        spam_string = spam_string .. "dps_"
                         --print(spam_string)

                                -----
                                if 1 == 0 then     
                                                       
                                    elseif CastSpellUnits(
                                        _spell.flash_of_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_RangeCheck
                                                --,SpellUnit_MediumHealth
                                            }
                                            ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Flash ofLight")

                                    elseif CastSpellUnits(
                                        _spell.holy_light
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Flash Heal OOC")


                                else _global.Off()
                                end            




-----                            


                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                end
 --
 --          _______      _______  
 --         |  __ \ \    / /  __ \ 
 --         | |__) \ \  / /| |__) |
 --         |  ___/ \ \/ / |  ___/ 
 --         | |      \  /  | |     
 --         |_|       \/   |_|                                          
 --                   
            elseif pvp_on then
                spam_string = spam_string .. "pvp_"
                if GodlyIsDD() then --print("do some single target shit")
                    spam_string = spam_string .. "dd_"  
                    if heal_on then --print("do some healing")
                        spam_string = spam_string .. "heal_"    
                        if regular_healer then spam_string = spam_string .. "regular"        --print(spam_string)
                               
                            if 1 == 0 then

                                elseif CastSpellUnits(
                                    _spell.flash_of_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            --,SpellUnit_MediumHealth
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                        ) then --print("Flash ofLight")

                                elseif CastSpellUnits(
                                    _spell.holy_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            --,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Flash Heal OOC")
        

                                else _global.Off()
                                end            
        
                        elseif attack_healer then spam_string = spam_string .. "attack_"     --print(spam_string)
                        else spam_string = spam_string .. "wtf?"                             --print(spam_string)
                        end
                    elseif dps_on then
                        spam_string = spam_string .. "dps_"                                  --print(spam_string)
                        if 1 == 0 then


                            elseif CastSpellUnits(
                                _spell.flash_of_light
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_RangeCheck
                                        --,SpellUnit_MediumHealth
                                    }
                                    ,RankUnits_MaxHealthDeficitPercent
                                    ) then --print("Flash ofLight")

                            elseif CastSpellUnits(
                                _spell.holy_light
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_HealthBelow95
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Flash Heal OOC")
                            
                                

                        else _global.Off()
                        end            




                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                elseif GodlyIsAOE() then
                    spam_string = spam_string .. "aoe_"
                    if heal_on then --print("do some aoe shit")
                        spam_string = spam_string .. "heal_"                    
                        if regular_healer then 
                            spam_string = spam_string .. "regular_"
                             --print(spam_string)
                                    if 1 == 0 then

                                        elseif CastSpellUnits(
                                            _spell.flash_of_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    --,SpellUnit_MediumHealth
                                                }
                                                ,RankUnits_MaxHealthDeficitPercent
                                                ) then --print("Flash ofLight")
        
                                        elseif CastSpellUnits(
                                            _spell.holy_light
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Flash Heal OOC")
                    

                                else _global.Off()
                                end            




                        elseif attack_healer then
                            spam_string = spam_string .. "attack_"
                             --print(spam_string)
                        else
                            spam_string = spam_string .. "wtf?"
                             --print(spam_string)
                        end
                    elseif dps_on then
                        spam_string = spam_string .. "dps_"
                         --print(spam_string)
                            ---
                            if 1 == 0 then


                                elseif CastSpellUnits(
                                    _spell.flash_of_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_of_light) < 0.5  and stationary and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            --,SpellUnit_MediumHealth
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                        ) then --print("Flash ofLight")

                                elseif CastSpellUnits(
                                    _spell.holy_light
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.holy_light) < 0.5 and stationary and not combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            --,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Flash Heal OOC")


                            else _global.Off()
                            end            




                            ---
                    else
                        spam_string = spam_string .. "wtf?"
                         --print(spam_string)
                    end
                end
            else
                spam_string = spam_string .. "off_"
                 --print(spam_string)            
                _global.Off()
            end     
        end   
    end
end    


-------------------------------------------------------------------------------------------------------------------------




--pack it up and store it in global space
_paladin.spell = _spell
delphi.class.Paladin = _paladin

 --print("Class_paladin.lua")




-- print("START Lee's talent code")

-- for i=1,3 do
--     for j=1,7 do
--         local talentID, talentName, , , , spellId, , ,, haveTalent, haveFakeTalent = GetTalentInfo(j, i,1)

-- print("END Lee's talent code")
