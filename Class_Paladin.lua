local _paladin  = {}
local _spell    = {}


local _unitids = delphi.unitids
local _unit    = delphi.unit
local _instant = delphi.pythia.instant
local _global  = delphi.pythia.global


--==========================================================================
-- Manual override state, for testing the Auto/Manual/Disabled toggle
-- concept before any UI exists. Set these with /run commands in-game:
--   /run delphi.override.seal = 0                      -- Auto (role/branch default)
--   /run delphi.override.seal = "Seal of Command"       -- Manual (cast this instead)
--   /run delphi.override.seal = false                   -- Disabled (cast nothing here)
--   /run delphi.override.aura = "__FB__"                -- Inherit from ForeverBlessings
-- Same pattern applies to delphi.override.aura, delphi.override.blessing,
-- and delphi.override.debuffseal. "__FB__" (inherit from ForeverBlessings)
-- is only meaningful for aura/blessing - see ForeverBlessings integration
-- block below.
--==========================================================================
delphi.override = delphi.override or {}
if delphi.override.seal == nil then delphi.override.seal = 0 end
if delphi.override.aura == nil then delphi.override.aura = 0 end
if delphi.override.blessing == nil then delphi.override.blessing = 0 end
if delphi.override.debuffseal == nil then delphi.override.debuffseal = 0 end


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
-- Spec detection - NOT CURRENTLY CALLED. CoreLogic uses the independent
-- role and healing selections instead of spec dispatch.
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
-- ForeverBlessings integration (optional) - reads YOUR OWN aura/blessing
-- assignment out of the ForeverBlessings addon (github.com/myrdev/ForeverBlessings)
-- when it's loaded, so delphi.override.aura / .blessing can be set to
-- "__FB__" to inherit from it instead of a hardcoded spell.
--
-- ForeverBlessings exposes itself as the global `ForeverBlessings` table
-- (its Core.lua does `_G.ForeverBlessings = FB`). Your own row always lives
-- at FB.rows[FB.me] regardless of which addon assigned it - notably, when
-- FB's PallyPower bridge is on (FB.db.ppBridge, toggled with /fb pp) and
-- you're in raid mode, a PallyPower-using raid leader's ASSIGN message gets
-- written into that same row by FB itself (see FBOnBridgeMessage in FB's
-- Bridge.lua). So reading FB.rows[FB.me] here picks up PallyPower-assigned
-- plans for free - no separate PallyPower reader needed.
--
-- Both helpers fail soft (return nil) if ForeverBlessings isn't loaded, you
-- have no assignment set, or anything about its internal shape doesn't
-- match what's documented here - ResolveOverride() then falls back to
-- auto_default. This integration should never be able to error CoreLogic().
--==========================================================================
local FB_INHERIT = "__FB__"

local function ForeverBlessings_Aura()
    local FB = _G.ForeverBlessings
    if not FB or not FB.rows or not FB.me then
        return nil
    end
    local row = FB.rows[FB.me]
    if not row or not row.aura or row.aura == 0 then
        return nil
    end
    local ok, name = pcall(function() return FB:AuraInfo(row.aura) end)
    if ok then
        return name
    end
    return nil
end

-- Your own column in FB's blessing grid: your class index in raid mode
-- (FB.CLASSES), your bucket in dungeon mode (FB.members[you].bucket).
local function ForeverBlessings_OwnColumn(FB, mode)
    if mode == "raid" then
        for i, class in ipairs(FB.CLASSES or {}) do
            if class == "PALADIN" then
                return i
            end
        end
    else
        for _, m in ipairs(FB.members or {}) do
            if m.name == FB.me then
                return m.bucket
            end
        end
    end
    return nil
end

local function ForeverBlessings_Blessing()
    local FB = _G.ForeverBlessings
    if not FB or not FB.rows or not FB.me then
        return nil
    end
    local row = FB.rows[FB.me]
    if not row then
        return nil
    end

    local ok, name = pcall(function()
        local mode = FB:Mode()
        local col = ForeverBlessings_OwnColumn(FB, mode)
        if not col then
            return nil
        end
        local values = FB:Values(row, mode)
        local idx = values and values[col] or 0
        if not idx or idx == 0 then
            return nil
        end
        return FB:CastName(idx, mode)
    end)

    if ok then
        return name
    end
    return nil
end


--==========================================================================
-- Override resolver - three states, plus an optional ForeverBlessings
-- inherit path:
--   0 (or nil)     -> Auto: use whatever default the caller passes in
--   false          -> Disabled: caller must skip casting this slot entirely
--   "__FB__"       -> Inherit: use fb_resolver() if given and it returns a
--                     value, else fall back to auto_default
--   anything else  -> Manual: use this exact value
--==========================================================================
function ResolveOverride(manual_value, auto_default, fb_resolver)
    if manual_value == false then
        return false
    elseif manual_value == FB_INHERIT then
        return (fb_resolver and fb_resolver()) or auto_default
    elseif manual_value and manual_value ~= 0 then
        return manual_value
    else
        return auto_default
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
    -- Role and Healing are selected in the Delphi toggle UI.


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


    -- Additional manual and ForeverBlessings choices must be bound.
    BindSpellToUnits(_spell.seal_of_justice, _unitids.player)
    BindSpellToUnits(_spell.seal_of_light, _unitids.player)
    BindSpellToUnits(_spell.seal_of_wisdom, _unitids.player)
    BindSpellToUnits(_spell.shadow_resistance_aura, _unitids.player)
    BindSpellToUnits(_spell.frost_resistance_aura, _unitids.player)
    BindSpellToUnits(_spell.fire_resistance_aura, _unitids.player)
    BindSpellToUnits(_spell.blessing_of_salvation, _unitids.player)
    BindSpellToUnits(_spell.blessing_of_light, _unitids.player)
    BindSpellToUnits(_spell.blessing_of_sacrifice, _unitids.player)
    BindSpellToUnits(_spell.greater_blessing_of_might, _unitids.player)
    BindSpellToUnits(_spell.greater_blessing_of_wisdom, _unitids.player)
    BindSpellToUnits(_spell.greater_blessing_of_kings, _unitids.player)
    BindSpellToUnits(_spell.greater_blessing_of_salvation, _unitids.player)
    BindSpellToUnits(_spell.greater_blessing_of_light, _unitids.player)

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
-- Resource checks use the WoWF-tested cost table shape.
-- nil may mean zero cost or unknown: only permit nil for a resolvable spell.
local function EnoughManaForSpell(spell)
    if not C_Spell or not C_Spell.IsSpellUsable then
        return false
    end

    local ok, usable, insufficient_power =
        pcall(C_Spell.IsSpellUsable, spell)

    if not ok then
        return false
    end

    if issecretvalue
        and (issecretvalue(usable)
             or issecretvalue(insufficient_power)) then
        return false
    end

    return usable == true and insufficient_power ~= true
end

-- The selected role owns these defaults even when Healing is On.
-- Role Off uses healer defaults when Healing is On.
local function RoleOverrides(role, context)
    local auto_aura = _spell.retribution_aura
    local auto_blessing = _spell.blessing_of_wisdom
    local auto_seal, auto_debuffseal
    if 1 == 0 then
    elseif role == "main_tank" then
        auto_seal = context == "pvp" and _spell.seal_of_justice or _spell.seal_of_fury
        auto_debuffseal = _spell.seal_of_the_crusader
    elseif role == "off_tank" and context == "pve" then
        auto_seal = _spell.seal_of_righteousness
        auto_debuffseal = _spell.seal_of_the_crusader
    elseif role == "dps_dd" or role == "dps_aoe" then
        auto_seal = _spell.seal_of_command
        auto_debuffseal = _spell.seal_of_the_crusader
    elseif role == "off" then
        auto_seal = _spell.seal_of_wisdom
        auto_debuffseal = _spell.seal_of_wisdom
    else
        return false, false, false, false
    end
    return ResolveOverride(delphi.override.aura, auto_aura, ForeverBlessings_Aura),
        ResolveOverride(delphi.override.seal, auto_seal),
        ResolveOverride(delphi.override.blessing, auto_blessing, ForeverBlessings_Blessing),
        ResolveOverride(delphi.override.debuffseal, auto_debuffseal)
end

function _paladin.CoreLogic()
    local context = delphi.override.context or "pve"
    local role = delphi.override.role or "dps_dd"
    local healing_on = delphi.override.healing ~= false
    local combat = CombatStatus()

    if 1 == 0 then
    elseif RedLight() then
        _global.Off()
    elseif role == "off" and not healing_on then
        _global.Off()
    elseif delphi.racial.perception and CastSpellUnits(
        delphi.racial.perception
        ,_unitids.player
        ,RemainingCooldown(delphi.racial.perception) < 0.5
            and EnoughManaForSpell(delphi.racial.perception)
        ,{ SpellUnit_AliveAndFriendly }
    ) then
        -- Existing Perception placeholder; stealth detection not wired.
    elseif delphi.profession.findminerals and CastSpellUnits(
        delphi.profession.findminerals
        ,_unitids.player
        ,RemainingCooldown(delphi.profession.findminerals) < 0.5
            and EnoughManaForSpell(delphi.profession.findminerals)
            and not combat
            and not SpellUnit_ShouldSkipTrackingCast(delphi.profession.findminerals, "player")
        ,{ SpellUnit_AliveAndFriendly }
    ) then
        -- Find Minerals.
    elseif context == "pve" and GodlyIsDD() then
        local acted = false
        if healing_on then
            -- PVE / DD / Healing: heals first, not healer buff defaults.
            if 1 == 0 then

            elseif _spell.flash_of_light and CastSpellUnits(
                _spell.flash_of_light
                ,_unitids.standard_friendly
                ,RemainingCooldown(_spell.flash_of_light) < 0.5
                    and EnoughManaForSpell(_spell.flash_of_light)
                ,{ SpellUnit_AliveAndFriendly, SpellUnit_RangeCheck, SpellUnit_HealthBelow95 }
                ,RankUnits_MaxHealthDeficit
            ) then
                acted = true
            end
        end
        if not acted then
            if 1 == 0 then

            elseif role == "main_tank" then
                -- PVE / DD / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "off_tank" then
                -- PVE / DD / Off Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "dps_dd" or role == "dps_aoe" then
                -- PVE / DD / DPS
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- Plain Judgement retained; selected debuffseal's matching
                -- target-effect maintenance remains deferred.
                elseif _spell.judgement and CastSpellUnits(
                    _spell.judgement
                    ,_unitids.standard_hostile
                    ,RemainingCooldown(_spell.judgement) < 0.5
                        and EnoughManaForSpell(_spell.judgement)
                    ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                ) then
                    acted = true

                elseif _spell.holy_strike and CastSpellUnits(
                    _spell.holy_strike
                    ,_unitids.standard_hostile
                    ,RemainingCooldown(_spell.holy_strike) < 0.5
                        and EnoughManaForSpell(_spell.holy_strike)
                    ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "off" then
                -- PVE / DD / Healing-only
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.
            end
        end
        if not acted then _global.Off() end
    elseif context == "pve" and GodlyIsAOE() then
        local acted = false
        if healing_on then
            -- PVE / AOE / Healing: heals first, not healer buff defaults.
            if 1 == 0 then
                -- Placeholder: independent healing spell chain goes here.
            end
        end
        if not acted then
            if 1 == 0 then

            elseif role == "main_tank" then
                -- PVE / AOE / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "off_tank" then
                -- PVE / AOE / Off Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "dps_dd" or role == "dps_aoe" then
                -- PVE / AOE / DPS
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- Plain Judgement retained; selected debuffseal's matching
                -- target-effect maintenance remains deferred.
                elseif _spell.judgement and CastSpellUnits(
                    _spell.judgement
                    ,_unitids.standard_hostile
                    ,RemainingCooldown(_spell.judgement) < 0.5
                        and EnoughManaForSpell(_spell.judgement)
                    ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                ) then
                    acted = true

                elseif _spell.holy_strike and CastSpellUnits(
                    _spell.holy_strike
                    ,_unitids.standard_hostile
                    ,RemainingCooldown(_spell.holy_strike) < 0.5
                        and EnoughManaForSpell(_spell.holy_strike)
                    ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "off" then
                -- PVE / AOE / Healing-only
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.
            end
        end
        if not acted then _global.Off() end
    elseif context == "pvp" and GodlyIsDD() then
        local acted = false
        if healing_on then
            -- PVP / DD / Healing: heals first, not healer buff defaults.
            if 1 == 0 then
                -- Placeholder: independent healing spell chain goes here.
            end
        end
        if not acted then
            if 1 == 0 then

            elseif role == "main_tank" then
                -- PVP / DD / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "dps_dd" or role == "dps_aoe" then
                -- PVP / DD / DPS
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- Plain Judgement retained; selected debuffseal's matching
                -- target-effect maintenance remains deferred.
                elseif _spell.judgement and CastSpellUnits(
                    _spell.judgement
                    ,_unitids.standard_hostile
                    ,RemainingCooldown(_spell.judgement) < 0.5
                        and EnoughManaForSpell(_spell.judgement)
                    ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                ) then
                    acted = true

                elseif _spell.holy_strike and CastSpellUnits(
                    _spell.holy_strike
                    ,_unitids.standard_hostile
                    ,RemainingCooldown(_spell.holy_strike) < 0.5
                        and EnoughManaForSpell(_spell.holy_strike)
                    ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "off" then
                -- PVP / DD / Healing-only
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.
            end
        end
        if not acted then _global.Off() end
    elseif context == "pvp" and GodlyIsAOE() then
        local acted = false
        if healing_on then
            -- PVP / AOE / Healing: heals first, not healer buff defaults.
            if 1 == 0 then
                -- Placeholder: independent healing spell chain goes here.
            end
        end
        if not acted then
            if 1 == 0 then

            elseif role == "main_tank" then
                -- PVP / AOE / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "dps_dd" or role == "dps_aoe" then
                -- PVP / AOE / DPS
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- Plain Judgement retained; selected debuffseal's matching
                -- target-effect maintenance remains deferred.
                elseif _spell.judgement and CastSpellUnits(
                    _spell.judgement
                    ,_unitids.standard_hostile
                    ,RemainingCooldown(_spell.judgement) < 0.5
                        and EnoughManaForSpell(_spell.judgement)
                    ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                ) then
                    acted = true

                elseif _spell.holy_strike and CastSpellUnits(
                    _spell.holy_strike
                    ,_unitids.standard_hostile
                    ,RemainingCooldown(_spell.holy_strike) < 0.5
                        and EnoughManaForSpell(_spell.holy_strike)
                    ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "off" then
                -- PVP / AOE / Healing-only
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif seal and CastSpellUnits(
                    seal
                    ,_unitids.player
                    ,RemainingCooldown(seal) < 0.5
                        and EnoughManaForSpell(seal)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.
            end
        end
        if not acted then _global.Off() end
    else
        _global.Off()
    end
end

-- Pack it up and store it in global space.
_paladin.spell = _spell
delphi.class.Paladin = _paladin
