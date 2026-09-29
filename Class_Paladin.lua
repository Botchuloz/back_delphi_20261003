local print = DelphiPrint
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

local DPS_SEQUENCE_ACTION = "DelphiDPSSequence"
local HEAL_ACTION = "DelphiHealMacro"
local MAIN_TANK_ACTION = "DelphiMainTankMacro"
local OFF_TANK_ACTION = "DelphiOffTankMacro"

local DPS_SEQUENCE_MACRO = [[
/startattack
/castsequence [@target,harm] reset=target Seal of the Crusader,judgement,Seal of Command,null
/castsequence [@target,harm] Holy Strike
/castsequence [@target,harm] judgement
]]

local HEAL_MACRO = [[
/use [@target,help][@targettarget,help][@focustargettarget,help][@focus,help] Flash of Light
]]

local MAIN_TANK_MACRO = [[
/startattack
/castsequence [@target,harm] reset=target Seal of Fury,judgement,null
/castsequence [@target,harm] reset=combat Holy Strike
/castsequence [combat] consecration
]]

local OFF_TANK_MACRO = [[
/startattack
/castsequence [@target,harm] reset=target Seal of the Crusader,judgement,Seal of Fury,null
/castsequence [@target,harm] Holy Strike
/castsequence [@target,harm] judgement
/castsequence [combat] consecration
]]

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
-- Automatic minimap tracking: preserve a manual Find Herbs, Find Minerals, or
-- Sense Undead selection. An older "any active tracking" check gave false
-- positives on WoWF, and checking player auras did not detect Find Herbs.
-- The player verified that GetTrackingInfo() reports the three named entries
-- with an active flag; only those names count here. If the state cannot be
-- read, do not cast another tracking spell over a manual choice.
local TRACKING_NAMES = {
    ["Find Minerals"] = true,
    ["Find Herbs"] = true,
    ["Sense Undead"] = true,
}

local function TrackingSelectedOrUnknown()
    if not (C_Minimap and C_Minimap.GetNumTrackingTypes
        and C_Minimap.GetTrackingInfo) then
        return true
    end
    local ok, selected = pcall(function()
        local count = C_Minimap.GetNumTrackingTypes()
        if type(count) ~= "number" then return true end
        for i = 1, count do
            local info = C_Minimap.GetTrackingInfo(i)
            if type(info) ~= "table" then return true end
            if TRACKING_NAMES[info.name] and info.active then
                return true
            end
        end
        return false
    end)
    return not ok or selected
end

-- Query the spellbook at cast time, not the cached profession table: a
-- newly learned profession may not have been detected at addon load time.
local function KnownTrackingSpellID(spellID)
    if not (C_SpellBook and C_SpellBook.IsSpellKnown) then return nil end
    local ok, known = pcall(function()
        return C_SpellBook.IsSpellKnown(spellID) == true
    end)
    if not ok then return nil end
    return known
end

-- Choose one preferred default. A temporarily unusable Minerals cast must
-- not cause Herbs to be selected instead. Name lookup for Sense Undead
-- avoids assuming its spell ID in WoWF; spellInfo.spellID is documented.
local function PreferredTrackingSpell()
    local minerals = KnownTrackingSpellID(2580)
    if minerals == nil then return nil end
    if minerals then return "Find Minerals" end

    local herbs = KnownTrackingSpellID(2383)
    if herbs == nil then return nil end
    if herbs then return "Find Herbs" end

    if not (C_Spell and C_Spell.GetSpellInfo) then return nil end
    local ok, info = pcall(C_Spell.GetSpellInfo, _spell.sense_undead)
    if not ok or type(info) ~= "table" or type(info.spellID) ~= "number" then
        return nil
    end
    if KnownTrackingSpellID(info.spellID) then
        return _spell.sense_undead
    end
    return nil
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
    BindSpellToUnit(    DPS_SEQUENCE_ACTION,    "target",    DPS_SEQUENCE_MACRO,    "",    1)
    BindSpellToUnit(HEAL_ACTION, "target", HEAL_MACRO, "", 1)
    BindSpellToUnit(MAIN_TANK_ACTION, "target", MAIN_TANK_MACRO, "", 1)
    BindSpellToUnit(OFF_TANK_ACTION, "target", OFF_TANK_MACRO, "", 1)

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


    -- Tracking spells are bound once, including spells learned after startup.
    -- CoreLogic checks which one is actually known before trying to cast it.
    BindSpellToUnits("Find Minerals", _unitids.player)
    BindSpellToUnits("Find Herbs", _unitids.player)
    BindSpellToUnits(_spell.sense_undead, _unitids.player)
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
-- Spell usability is checked without comparing secret mana values.
-- If the API fails or returns a secret result, do not attempt the cast.
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
    elseif role == "dps" then
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

local function MacroInRange(spell, unit)
    local ok, in_range = pcall(SpellUnit_RangeCheck, spell, unit)
    return ok and in_range == true
end

local function OfferRareScannerMacro(combat)
    local binding = delphi.bind.rs_macro_binding
    if combat or RedLight() or not (binding and binding.key) then
        _global.Off()
        return
    end

    _global.SetSpellUnit("RS_MACRO")
end

local perception_requested = false
local last_perception_signal

local perception_cast_frame = CreateFrame("Frame")
perception_cast_frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
perception_cast_frame:SetScript("OnEvent", function(_, _, unit, _, spellID)
    if unit == "player"
        and not (issecretvalue and issecretvalue(spellID))
        and spellID == 20600 then
        perception_requested = false
    end
end)

local function OnSpyGodModeDetected(_, _, isStealth)
    if not isStealth then
        return
    end

    local now = GetTime()
    if last_perception_signal and now - last_perception_signal < 2 then
        return
    end

    -- SpyGodMode can report both spell start and success for one stealth cast.
    last_perception_signal = now
    perception_requested = true
end

local function AttachSpyGodMode()
    local spy = _G.SpyGodMode
    if type(spy) ~= "table" or type(spy.On) ~= "function" then
        return false
    end

    spy:On("SGM_DETECTED", OnSpyGodModeDetected)
    return true
end

if not AttachSpyGodMode() then
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", function(self)
        if AttachSpyGodMode() then
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)
end

-- Seal maintenance is combat-only: enabling Godly out of combat must not
-- trigger a Seal. Existing cooldown, secret-safe usability and buff gates
-- remain in every Seal cast branch.
function _paladin.CoreLogic()
    local context = delphi.override.context or "pve"
    local role = delphi.override.role or "dps"
    local healing_on = delphi.override.healing ~= false
    local combat = CombatStatus()
    local tracking_spell = not combat and PreferredTrackingSpell() or nil

    if 1 == 0 then
    elseif RedLight() then
        _global.Off()
    elseif perception_requested and delphi.racial.perception
        and CastSpellUnits(
            delphi.racial.perception
            ,_unitids.player
            ,RemainingCooldown(delphi.racial.perception) < 0.5
                and EnoughManaForSpell(delphi.racial.perception)
            ,{ SpellUnit_AliveAndFriendly }
        ) then
        -- Keep recommending until the player successfully casts Perception.
    elseif role == "off" and not healing_on then
        OfferRareScannerMacro(combat)
    elseif tracking_spell and not TrackingSelectedOrUnknown() and CastSpellUnits(
        tracking_spell
        ,_unitids.player
        ,RemainingCooldown(tracking_spell) < 0.5
            and EnoughManaForSpell(tracking_spell)
            and not combat
        ,{ SpellUnit_AliveAndFriendly }
    ) then
        -- No relevant tracking selected: cast the first known default.
    elseif context == "pve" and GodlyIsDD() then
        local acted = false
        if healing_on then
            -- PVE / DD / Healing: heals first, not healer buff defaults.
            if 1 == 0 then

            elseif HEAL_ACTION then
                _global.SetSpellUnit(HEAL_ACTION, "target")
                acted = true
            end
        end
        if not acted then
            if 1 == 0 then

            elseif role == "main_tank" then
                -- PVE / DD / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif UnitAliveAndHostile("target")
                    and MacroInRange(_spell.judgement, "target") then
                    _global.SetSpellUnit(MAIN_TANK_ACTION, "target")
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true    

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
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

                elseif UnitAliveAndHostile("target")
                    and MacroInRange(_spell.judgement, "target") then
                    _global.SetSpellUnit(OFF_TANK_ACTION, "target")
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true    

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "dps" then
                -- PVE / DD / DPS
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif UnitAliveAndHostile("target")
                    and MacroInRange(_spell.judgement, "target") then
                    _global.SetSpellUnit("DelphiDPSSequence", "target")
                    acted = true
                end  -- closes the PVP / DD / DPS action chain

                -- -- Plain Judgement retained; selected debuffseal's matching
                -- -- target-effect maintenance remains deferred.
                -- elseif _spell.judgement and CastSpellUnits(
                --     _spell.judgement
                --     ,_unitids.standard_hostile
                --     ,RemainingCooldown(_spell.judgement) < 0.5
                --         and EnoughManaForSpell(_spell.judgement)
                --     ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                -- ) then
                --     acted = true

                -- elseif _spell.holy_strike and CastSpellUnits(
                --     _spell.holy_strike
                --     ,_unitids.standard_hostile
                --     ,RemainingCooldown(_spell.holy_strike) < 0.5
                --         and EnoughManaForSpell(_spell.holy_strike)
                --     ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                -- ) then
                --     acted = true
                -- end
                -- -- debuffseal is resolved for this role; the Judgement-of-X
                -- -- target-debuff logic is intentionally not implemented here.

            elseif role == "off" then
                -- PVE / DD / Healing-only
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.
            end
        end
        if not acted then OfferRareScannerMacro(combat) end
    elseif context == "pve" and GodlyIsAOE() then
        local acted = false
        if healing_on then
            -- PVE / AOE / Healing: heals first, not healer buff defaults.
            if 1 == 0 then

            elseif HEAL_ACTION then
                _global.SetSpellUnit(HEAL_ACTION, "target")
                acted = true
            end
        end
        if not acted then
            if 1 == 0 then

            elseif role == "main_tank" then
                -- PVE / AOE / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif UnitAliveAndHostile("target")
                    and MacroInRange(_spell.judgement, "target") then
                    _global.SetSpellUnit(MAIN_TANK_ACTION, "target")
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true    

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
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

                elseif UnitAliveAndHostile("target")
                    and MacroInRange(_spell.judgement, "target") then
                    _global.SetSpellUnit(OFF_TANK_ACTION, "target")
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true    
                  
                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "dps" then
                -- PVE / AOE / DPS
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif UnitAliveAndHostile("target")
                    and MacroInRange(_spell.judgement, "target") then
                    _global.SetSpellUnit("DelphiDPSSequence", "target")
                    acted = true
                end  -- closes the PVP / DD / DPS action chain

                -- -- Plain Judgement retained; selected debuffseal's matching
                -- -- target-effect maintenance remains deferred.
                -- elseif _spell.judgement and CastSpellUnits(
                --     _spell.judgement
                --     ,_unitids.standard_hostile
                --     ,RemainingCooldown(_spell.judgement) < 0.5
                --         and EnoughManaForSpell(_spell.judgement)
                --     ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                -- ) then
                --     acted = true

                -- elseif _spell.holy_strike and CastSpellUnits(
                --     _spell.holy_strike
                --     ,_unitids.standard_hostile
                --     ,RemainingCooldown(_spell.holy_strike) < 0.5
                --         and EnoughManaForSpell(_spell.holy_strike)
                --     ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                -- ) then
                --     acted = true
                -- end
                -- -- debuffseal is resolved for this role; the Judgement-of-X
                -- -- target-debuff logic is intentionally not implemented here.

            elseif role == "off" then
                -- PVE / AOE / Healing-only
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.
            end
        end
        if not acted then OfferRareScannerMacro(combat) end
    elseif context == "pvp" and GodlyIsDD() then
        local acted = false
        if healing_on then
            -- PVP / DD / Healing: heals first, not healer buff defaults.
            if 1 == 0 then
                
            elseif HEAL_ACTION then
                _global.SetSpellUnit(HEAL_ACTION, "target")
                acted = true            end
        end
        if not acted then
            if 1 == 0 then

            elseif role == "main_tank" then
                -- PVP / DD / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif UnitAliveAndHostile("target")
                    and MacroInRange(_spell.judgement, "target") then
                    _global.SetSpellUnit(MAIN_TANK_ACTION, "target")
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true    

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "dps" then
                -- PVP / DD / DPS
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- elseif seal and combat and CastSpellUnits(
                --     seal
                --     ,_unitids.player
                --     ,RemainingCooldown(seal) < 0.5
                --         and EnoughManaForSpell(seal)
                --     ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                -- ) then
                --     acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif UnitAliveAndHostile("target")
                    and MacroInRange(_spell.judgement, "target") then
                    _global.SetSpellUnit("DelphiDPSSequence", "target")
                    acted = true
                end  -- closes the PVP / DD / DPS action chain

                -- Plain Judgement and Holy Strike remain commented out below.
                -- -- Plain Judgement retained; selected debuffseal's matching
                -- -- target-effect maintenance remains deferred.
                -- elseif _spell.judgement and CastSpellUnits(
                --     _spell.judgement
                --     ,_unitids.standard_hostile
                --     ,RemainingCooldown(_spell.judgement) < 0.5
                --         and EnoughManaForSpell(_spell.judgement)
                --     ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                -- ) then
                --     acted = true

                -- elseif _spell.holy_strike and CastSpellUnits(
                --     _spell.holy_strike
                --     ,_unitids.standard_hostile
                --     ,RemainingCooldown(_spell.holy_strike) < 0.5
                --         and EnoughManaForSpell(_spell.holy_strike)
                --     ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                -- ) then
                --     acted = true
                -- end
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.
            end
        end
        if not acted then OfferRareScannerMacro(combat) end
    elseif context == "pvp" and GodlyIsAOE() then
        local acted = false
        if healing_on then
            -- PVP / AOE / Healing: heals first, not healer buff defaults.
            if 1 == 0 then
            elseif HEAL_ACTION then
                _global.SetSpellUnit(HEAL_ACTION, "target")
                acted = true
            end
        end
        if not acted then
            if 1 == 0 then

            elseif role == "main_tank" then
                -- PVP / AOE / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif UnitAliveAndHostile("target")
                    and MacroInRange(_spell.judgement, "target") then
                    _global.SetSpellUnit(MAIN_TANK_ACTION, "target")
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true    

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.

            elseif role == "dps" then
                -- PVP / AOE / DPS
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true


                elseif UnitAliveAndHostile("target")
                    and MacroInRange(_spell.judgement, "target") then
                    _global.SetSpellUnit("DelphiDPSSequence", "target")
                    acted = true
                end  -- closes the PVP / DD / DPS action chain

                -- -- Plain Judgement retained; selected debuffseal's matching
                -- -- target-effect maintenance remains deferred.
                -- elseif _spell.judgement and CastSpellUnits(
                --     _spell.judgement
                --     ,_unitids.standard_hostile
                --     ,RemainingCooldown(_spell.judgement) < 0.5
                --         and EnoughManaForSpell(_spell.judgement)
                --     ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                -- ) then
                --     acted = true

                -- elseif _spell.holy_strike and CastSpellUnits(
                --     _spell.holy_strike
                --     ,_unitids.standard_hostile
                --     ,RemainingCooldown(_spell.holy_strike) < 0.5
                --         and EnoughManaForSpell(_spell.holy_strike)
                --     ,{ SpellUnit_UnitAliveAndHostile, SpellUnit_RangeCheck, SpellUnit_ValidHarm }
                -- ) then
                --     acted = true
                -- end
                -- -- debuffseal is resolved for this role; the Judgement-of-X
                -- -- target-debuff logic is intentionally not implemented here.

            elseif role == "off" then
                -- PVP / AOE / Healing-only
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true

                -- Disabled for now; left in place for easy re-enabling.
                elseif false and seal and combat and CastSpellUnits(
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
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_MyBuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- target-debuff logic is intentionally not implemented here.
            end
        end
        if not acted then OfferRareScannerMacro(combat) end
    else
        _global.Off()
    end
end

-- Pack it up and store it in global space.
_paladin.spell = _spell
delphi.class.Paladin = _paladin
