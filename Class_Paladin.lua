local _paladin  = {}
local _spell    = {}


local _unitids = delphi.unitids
local _unit    = delphi.unit
local _instant = delphi.pythia.instant
local _global  = delphi.pythia.global


--==========================================================================
-- WoW: Forever Paladin spell list, Level 1-60
-- Source: talentsforever.com/paladin (beta client, Level 60, no gear)
--==========================================================================


--Holy
_spell.holy_light          = "Holy Light"
_spell.seal_of_righteousness = "Seal of Righteousness"
_spell.purify               = "Purify"
_spell.lay_on_hands         = "Lay on Hands"
_spell.redemption           = "Redemption"
_spell.blessing_of_wisdom   = "Blessing of Wisdom"
_spell.exorcism             = "Exorcism"
_spell.flash_of_light       = "Flash of Light"
_spell.sense_undead         = "Sense Undead"
_spell.turn_undead          = "Turn Undead"
_spell.consecration         = "Consecration" --Reworked, Holy in WoW Forever
_spell.seal_of_light        = "Seal of Light"
_spell.seal_of_wisdom       = "Seal of Wisdom"
_spell.blessing_of_light    = "Blessing of Light"
_spell.cleanse              = "Cleanse"
_spell.hammer_of_wrath      = "Hammer of Wrath"
_spell.holy_wrath           = "Holy Wrath"
_spell.greater_blessing_of_light  = "Greater Blessing of Light"
_spell.greater_blessing_of_wisdom = "Greater Blessing of Wisdom"


--Holy - talents
_spell.holy_shock           = "Holy Shock"        --TALENT
_spell.lights_vigil         = "Light's Vigil"     --TALENT, New
_spell.divine_favor         = "Divine Favor"      --TALENT
_spell.voice_of_truth       = "Voice of Truth"    --TALENT, New


--Protection
_spell.devotion_aura        = "Devotion Aura"
_spell.divine_protection    = "Divine Protection" --Reworked
_spell.hammer_of_justice    = "Hammer of Justice"
_spell.blessing_of_protection = "Blessing of Protection" --Reworked
_spell.seal_of_fury         = "Seal of Fury" --New
_spell.righteous_fury       = "Righteous Fury"
_spell.blessing_of_freedom  = "Blessing of Freedom"
_spell.concentration_aura   = "Concentration Aura"
_spell.seal_of_justice      = "Seal of Justice"
_spell.blessing_of_salvation = "Blessing of Salvation" --Reworked
_spell.shadow_resistance_aura = "Shadow Resistance Aura" --Reworked
_spell.divine_intervention  = "Divine Intervention"
_spell.frost_resistance_aura = "Frost Resistance Aura" --Reworked
_spell.divine_shield        = "Divine Shield" --Reworked
_spell.fire_resistance_aura = "Fire Resistance Aura" --Reworked
_spell.blessing_of_sacrifice = "Blessing of Sacrifice"
_spell.greater_blessing_of_kings = "Greater Blessing of Kings" --Reworked
_spell.greater_blessing_of_salvation = "Greater Blessing of Salvation" --Reworked


--Protection - talents
_spell.holy_shield          = "Holy Shield" --TALENT, Reworked
_spell.swift_judgement      = "Swift Judgement" --TALENT, New
_spell.templars_bulwark     = "Templar's Bulwark" --TALENT, New


--Retribution
_spell.blessing_of_might    = "Blessing of Might" --Reworked
_spell.judgement            = "Judgement" --Reworked
_spell.holy_strike          = "Holy Strike" --New
_spell.seal_of_the_crusader = "Seal of the Crusader"
_spell.retribution_aura     = "Retribution Aura"
_spell.blessing_of_kings    = "Blessing of Kings" --Reworked
_spell.seal_of_command      = "Seal of Command"
_spell.greater_blessing_of_might = "Greater Blessing of Might" --Reworked


--Retribution - talents
_spell.repentance           = "Repentance" --TALENT


local holy_spec = 1
local prot_spec = 2
local ret_spec  = 3


--==========================================================================
-- Spec detection - NOT CURRENTLY CALLED. CoreLogic() uses the NUMPAD3
-- heal/dps toggle instead of spec dispatch for now.
--==========================================================================
local function SpellKnown(spellName)
    if C_Spell and C_Spell.GetSpellInfo then
        return C_Spell.GetSpellInfo(spellName) ~= nil
    else
        return false
    end
end


local function GetPaladinSpec()
    if 1 == 0 then


    elseif SpellKnown(_spell.holy_shock) then
        return holy_spec


    elseif SpellKnown(_spell.holy_shield) or SpellKnown(_spell.templars_bulwark) then
        return prot_spec


    elseif SpellKnown(_spell.seal_of_command) or SpellKnown(_spell.repentance) then
        return ret_spec


    else
        return 0
    end
end


--==========================================================================
-- KNOWN ISSUE (unresolved): SpellUnit_AnyTrackingActive(), which used
-- C_Minimap.GetNumTrackingTypes()/GetTrackingInfo() to detect whether ANY
-- minimap tracking type was active, was found in testing to return true
-- unconditionally on WoWF - some entry in that list reports "active" even
-- when it isn't a real player-selected tracking type. Root cause not yet
-- identified; needs an in-game dump of
-- "for i=1,C_Minimap.GetNumTrackingTypes() do local info=C_Minimap.GetTrackingInfo(i) print(i,info.name,info.active) end"
-- to find the false positive before this can be trusted again. Left in
-- place for reference/future fix, but no longer called - see
-- SpellUnit_ShouldSkipTrackingCast() below, which uses direct buff checks
-- (confirmed via Wowhead that both Find Minerals and Sense Undead grant a
-- real, permanent-duration buff matching the spell name) instead.
--==========================================================================
function SpellUnit_AnyTrackingActive()
    local numTypes = 0
    if C_Minimap and C_Minimap.GetNumTrackingTypes then
        numTypes = C_Minimap.GetNumTrackingTypes()
    elseif GetNumTrackingTypes then
        numTypes = GetNumTrackingTypes()
    end


    for i = 1, numTypes do
        local active = false
        if C_Minimap and C_Minimap.GetTrackingInfo then
            local info = C_Minimap.GetTrackingInfo(i)
            active = info and info.active
        elseif GetTrackingInfo then
            local _, _, isActive = GetTrackingInfo(i)
            active = isActive
        end
        if active then
            return true
        end
    end
    return false
end


-- Known minimap-tracking buffs that compete for WoW's single-tracking-slot
-- ("Only one form of tracking can be active at a time"). Populated lazily
-- since delphi.profession.* isn't known until after
-- DetectRacialAndProfessionAbilities() has run.
local function KnownTrackingBuffs()
    local buffs = { [_spell.sense_undead] = true }
    if delphi.profession.findminerals then
        buffs[delphi.profession.findminerals] = true
    end
    if delphi.profession.findherbs then
        buffs[delphi.profession.findherbs] = true
    end
    return buffs
end


-- Returns true if casting `spell` on `unit` should be skipped: either the
-- spell's own buff is already active (avoids respamming a permanent-duration
-- tracking buff every tick), or a different known tracking buff is already
-- active and should not be clobbered (e.g. don't override a manually-cast
-- Sense Undead with an auto-cast Find Minerals).
function SpellUnit_ShouldSkipTrackingCast(spell, unit)
    local known = KnownTrackingBuffs()
    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
        if not aura then
            break
        end
        if aura.name == spell then
            return true
        end
        if known[aura.name] then
            return true
        end
    end
    return false
end


local bind_once = 0
function _paladin.SetBinds()
    if bind_once > 0 then
        return nil
    end
    bind_once = 1


    BindSpellToUnit("start_attack","","","/startattack",true)
    CreateIconAndButton("NUMPAD3",250+300,-150,"",2) -- healer or dpser


    --Seals - player only
    BindSpellToUnits(_spell.seal_of_righteousness, _unitids.player)
    BindSpellToUnits(_spell.seal_of_command,       _unitids.player)
    BindSpellToUnits(_spell.seal_of_the_crusader,  _unitids.player)
    BindSpellToUnits(_spell.seal_of_fury,          _unitids.player)


    --Auras and self-blessings - player only
    BindSpellToUnits(_spell.devotion_aura,         _unitids.player)
    BindSpellToUnits(_spell.retribution_aura,      _unitids.player)
    BindSpellToUnits(_spell.concentration_aura,    _unitids.player)
    BindSpellToUnits(_spell.blessing_of_might,     _unitids.player)
    BindSpellToUnits(_spell.blessing_of_kings,     _unitids.player)
    BindSpellToUnits(_spell.blessing_of_wisdom,    _unitids.player)
    BindSpellToUnits(_spell.righteous_fury,        _unitids.player)


    --Offense - standard hostile fallback chain
    BindSpellToUnits(_spell.judgement,             _unitids.standard_hostile)
    BindSpellToUnits(_spell.holy_strike,           _unitids.standard_hostile)
    BindSpellToUnits(_spell.hammer_of_justice,     _unitids.standard_hostile)
    BindSpellToUnits(_spell.exorcism,              _unitids.standard_hostile)
    BindSpellToUnits(_spell.hammer_of_wrath,       _unitids.standard_hostile)


    --Heals and friendly buffs - standard friendly fallback chain
    BindSpellToUnits(_spell.flash_of_light,        _unitids.standard_friendly)
    BindSpellToUnits(_spell.holy_light,            _unitids.standard_friendly)
    BindSpellToUnits(_spell.lay_on_hands,          _unitids.standard_friendly)
    BindSpellToUnits(_spell.cleanse,               _unitids.standard_friendly)
    BindSpellToUnits(_spell.blessing_of_protection,_unitids.standard_friendly)
    BindSpellToUnits(_spell.blessing_of_freedom,   _unitids.standard_friendly)
    BindSpellToUnits(_spell.blessing_of_sacrifice, _unitids.standard_friendly)
    BindSpellToUnits(_spell.redemption,            _unitids.standard_friendly)


    --Area/self effects - player only
    BindSpellToUnits(_spell.consecration,          _unitids.player)
    BindSpellToUnits(_spell.holy_wrath,            _unitids.player)
    BindSpellToUnits(_spell.divine_shield,         _unitids.player)
    BindSpellToUnits(_spell.divine_protection,     _unitids.player)


    --Racials - player only (Human). Sourced from Global_Abilities_Racials.lua,
    --nil on any other race, so these are no-ops if not applicable.
    if delphi.racial.willtosurvive then
        BindSpellToUnits(delphi.racial.willtosurvive, _unitids.player)
    end
    if delphi.racial.perception then
        BindSpellToUnits(delphi.racial.perception, _unitids.player)
    end


    --Professions - player only. Sourced from Global_Abilities_Racials.lua,
    --nil if the profession isn't learned, so this is a no-op if not applicable.
    if delphi.profession.findminerals then
        BindSpellToUnits(delphi.profession.findminerals, _unitids.player)
    end
end


--=================================================================
-- CoreLogic - CONFIRMED calling convention from your real
-- SpellUnit_CastLoops.lua:
--   CastSpellUnits(spell, units, logic, delegates_logic, delegates_rank)
-- delegates_logic = a TABLE of boolean (spell,unit)->bool functions,
--   ALL must return true (CheckLogicDelegates ANDs them).
-- delegates_rank  = a SINGLE (spell,unit)->number function, or omit/nil
--   for "first match wins" instead of "best-scoring match wins"
--   (CheckRankDelegates explicitly rejects a table here).
--=================================================================
function _paladin.CoreLogic()
    local heal_on,dps_on = BiStateCheck("NUMPAD3","healer","dpser")
    local combat = CombatStatus()


    if 1 == 0 then


    elseif RedLight() then
        _global.Off()


    elseif delphi.racial.perception and CastSpellUnits(
        delphi.racial.perception
        ,_unitids.player
        ,RemainingCooldown(delphi.racial.perception) < 0.5
        --PLACEHOLDER: fires off cooldown until SpellUnit_RecentStealthCastNearby()
        --lands in Core_Events.lua (stealth-cast detection hook, not yet wired in).
        ,{
            SpellUnit_AliveAndFriendly
        }
    ) then
        --print("Perception")


    elseif delphi.profession.findminerals and CastSpellUnits(
        delphi.profession.findminerals
        ,_unitids.player
        ,not combat and not SpellUnit_ShouldSkipTrackingCast(delphi.profession.findminerals, "player")
        ,{
            SpellUnit_AliveAndFriendly
        }
    ) then
        --print("Find Minerals")


    elseif GodlyIsDD() then


        if 1 == 0 then


        elseif heal_on then


            if 1 == 0 then


            elseif CastSpellUnits(
                _spell.flash_of_light
                ,_unitids.standard_friendly
                ,RemainingCooldown(_spell.flash_of_light) < 0.5
                ,{
                    SpellUnit_AliveAndFriendly
                    ,SpellUnit_RangeCheck
                    ,SpellUnit_HealthBelow95
                }
                ,RankUnits_MaxHealthDeficit
            ) then
                --print("Flash of Light")


            else
                _global.Off()
            end


        elseif dps_on then


            if 1 == 0 then


            elseif CastSpellUnits(
                _spell.seal_of_the_crusader
                ,_unitids.player
                ,true
                ,{
                    SpellUnit_AliveAndFriendly
                    ,SpellUnit_MyBuffExpired
                }
            ) then
                --print("Seal of the Crusader")


            elseif CastSpellUnits(
                _spell.judgement
                ,_unitids.standard_hostile
                ,RemainingCooldown(_spell.judgement) < 0.5
                ,{
                    SpellUnit_UnitAliveAndHostile
                    ,SpellUnit_RangeCheck
                    ,SpellUnit_ValidHarm
                }
            ) then
                --print("Judgement")


            elseif CastSpellUnits(
                _spell.holy_strike
                ,_unitids.standard_hostile
                ,RemainingCooldown(_spell.holy_strike) < 0.5
                ,{
                    SpellUnit_UnitAliveAndHostile
                    ,SpellUnit_RangeCheck
                    ,SpellUnit_ValidHarm
                }
            ) then
                --print("Holy Strike")


            else
                _global.Off()
            end


        else
            _global.Off()
        end


    elseif GodlyIsAOE() then


        if 1 == 0 then


        elseif heal_on then
            --PLACEHOLDER: same as the dd heal check above.


            if 1 == 0 then


            elseif CastSpellUnits(
                _spell.flash_of_light
                ,_unitids.standard_friendly
                ,RemainingCooldown(_spell.flash_of_light) < 0.5
                ,{
                    SpellUnit_AliveAndFriendly
                    ,SpellUnit_RangeCheck
                    ,SpellUnit_HealthBelow95
                }
                ,RankUnits_MaxHealthDeficit
            ) then
                --print("Flash of Light (aoe placeholder)")


            else
                _global.Off()
            end


        elseif dps_on then
            --PLACEHOLDER: same as the dd damage chain above.


            if 1 == 0 then


            elseif CastSpellUnits(
                _spell.seal_of_the_crusader
                ,_unitids.player
                ,true
                ,{
                    SpellUnit_AliveAndFriendly
                    ,SpellUnit_MyBuffExpired
                }
            ) then
                --print("Seal of the Crusader (aoe placeholder)")


            elseif CastSpellUnits(
                _spell.judgement
                ,_unitids.standard_hostile
                ,RemainingCooldown(_spell.judgement) < 0.5
                ,{
                    SpellUnit_UnitAliveAndHostile
                    ,SpellUnit_RangeCheck
                    ,SpellUnit_ValidHarm
                }
            ) then
                --print("Judgement (aoe placeholder)")


            elseif CastSpellUnits(
                _spell.holy_strike
                ,_unitids.standard_hostile
                ,RemainingCooldown(_spell.holy_strike) < 0.5
                ,{
                    SpellUnit_UnitAliveAndHostile
                    ,SpellUnit_RangeCheck
                    ,SpellUnit_ValidHarm
                }
            ) then
                --print("Holy Strike (aoe placeholder)")


            else
                _global.Off()
            end


        else
            _global.Off()
        end


    else
        _global.Off()
    end
end


--pack it up and store it in global space
_paladin.spell = _spell
delphi.class.Paladin = _paladin
