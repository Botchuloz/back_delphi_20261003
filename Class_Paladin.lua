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

local HEAL_ACTION = "DelphiPaladinHeal"
local NIGHT_WATCHMANS_TORCH_ACTION = "DelphiPaladinNightWatchmansTorch"
local NIGHT_WATCHMANS_TORCH_BUFF = "Night Watchman's Torch"
local NIGHT_WATCHMANS_TORCH_ITEM_ID = 280612
local paladin_interact_binding_owner

local function EnablePaladinInteractKey()
    local interact_flags = Enum and Enum.SoftTargetEnableFlags
    if not interact_flags or interact_flags.Any == nil
        or type(GetCVar) ~= "function" or type(SetCVar) ~= "function" then
        print("Paladin interact key unavailable: WoW's Interact Key setting API is missing.")
        return false
    end

    local read_ok, current_value = pcall(GetCVar, "softTargetInteract")
    if read_ok and tonumber(current_value) == interact_flags.Any then
        return true
    end

    local set_ok = pcall(SetCVar, "softTargetInteract", interact_flags.Any)
    if not set_ok then
        print("Paladin interact key unavailable: could not enable WoW's Interact Key setting.")
        return false
    end

    local verify_ok, enabled_value = pcall(GetCVar, "softTargetInteract")
    if not verify_ok or tonumber(enabled_value) ~= interact_flags.Any then
        print("Paladin interact key unavailable: WoW did not enable the Interact Key setting.")
        return false
    end
    return true
end

local ROLE_ROTATION_MACROS = {
    dps = {name = "DPSSequence"},
    main_tank = {name = "MainTank"},
    off_tank = {name = "OffTank"},
}

local DEBUFF_SEAL_VARIANTS = {
    {spell = _spell.seal_of_the_crusader, name = "Crusader"},
    {spell = _spell.seal_of_fury, name = "Fury"},
    {spell = _spell.seal_of_justice, name = "Justice"},
    {spell = _spell.seal_of_light, name = "Light"},
    {spell = _spell.seal_of_wisdom, name = "Wisdom"},
    {spell = false, name = "NoJudgement"},
}

local SEAL_VARIANTS = {
    {spell = _spell.seal_of_righteousness, name = "Righteousness"},
    {spell = _spell.seal_of_command, name = "Command"},
    {spell = _spell.seal_of_the_crusader, name = "Crusader"},
    {spell = _spell.seal_of_fury, name = "Fury"},
    {spell = _spell.seal_of_justice, name = "Justice"},
    {spell = _spell.seal_of_light, name = "Light"},
    {spell = _spell.seal_of_wisdom, name = "Wisdom"},
    {spell = false, name = "NoSeal"},
}

local role_rotation_actions = {}
local no_justice_judgement_actions = {}
local last_exorcism_cast
local last_paladin_seal_cast = {}
local last_paladin_judgement_target_generation
local paladin_target_generation = 0

local function TargetIsKnownNonHumanoidForJustice()
    local ok, _, creature_type_id = pcall(UnitCreatureType, "target")
    if not ok or creature_type_id == nil
        or (issecretvalue and issecretvalue(creature_type_id)) then
        return false
    end

    return creature_type_id ~= 7
end

local function ShouldSkipJusticeJudgement(debuffseal)
    return debuffseal == _spell.seal_of_justice
        and TargetIsKnownNonHumanoidForJustice()
end

local function RoleRotationActionName(role, debuffseal, seal, skip_justice_judgement)
    local role_config = ROLE_ROTATION_MACROS[role]
    if not role_config then
        return nil
    end

    local debuff_name
    for _, variant in ipairs(DEBUFF_SEAL_VARIANTS) do
        if variant.spell == debuffseal then
            debuff_name = variant.name
            break
        end
    end

    local seal_name
    for _, variant in ipairs(SEAL_VARIANTS) do
        if variant.spell == seal then
            seal_name = variant.name
            break
        end
    end

    if not debuff_name or not seal_name then
        return nil
    end

    local action = "DelphiPaladin" .. role_config.name
        .. "_Judgement" .. debuff_name .. "_Seal" .. seal_name
    if skip_justice_judgement then
        action = action .. "_NoJusticeJudgement"
    end
    return action
end

local function CreateRoleRotationMacro(role, debuffseal, seal, skip_justice_judgement)
    local lines = {"/startattack"}

    if debuffseal then
        if seal == debuffseal then
            lines[#lines + 1] = "/castsequence [@target,harm] reset=combat "
                .. debuffseal .. ",null"
            if not skip_justice_judgement then
                lines[#lines + 1] = "/castsequence [@target,harm] reset=target "
                    .. "judgement,null"
            end
        else
            local sequence = debuffseal
            if not skip_justice_judgement then
                sequence = sequence .. ",judgement"
            end
            if seal and seal ~= debuffseal then
                sequence = sequence .. "," .. seal
            end
            lines[#lines + 1] = "/castsequence [@target,harm] reset=target "
                .. sequence .. ",null"
        end
    elseif seal then
        lines[#lines + 1] = "/castsequence [@target,harm] reset=combat "
            .. seal .. ",null"
    end

    if role == "main_tank" then
        lines[#lines + 1] = "/castsequence [@target,harm] reset=combat Holy Strike"
        lines[#lines + 1] = "/castsequence [combat] consecration"
    else
        lines[#lines + 1] = "/castsequence [@target,harm] Holy Strike"
        if debuffseal and seal and seal ~= debuffseal
            and not skip_justice_judgement then
            lines[#lines + 1] = "/castsequence [@target,harm] judgement"
        end
        if role == "off_tank" then
            lines[#lines + 1] = "/castsequence [combat] consecration"
        end
    end

    return table.concat(lines, "\n")
end

local function BindRoleRotationMacros()
    for role in pairs(ROLE_ROTATION_MACROS) do
        role_rotation_actions[role] = {}
        for _, debuff_variant in ipairs(DEBUFF_SEAL_VARIANTS) do
            role_rotation_actions[role][debuff_variant.spell] = {}
            for _, seal_variant in ipairs(SEAL_VARIANTS) do
                local action = RoleRotationActionName(
                    role,
                    debuff_variant.spell,
                    seal_variant.spell
                )
                local macro = CreateRoleRotationMacro(
                    role,
                    debuff_variant.spell,
                    seal_variant.spell
                )
                role_rotation_actions[role][debuff_variant.spell][seal_variant.spell] = action
                BindSpellToUnit(action, "target", macro, "", true)

                if debuff_variant.spell == _spell.seal_of_justice then
                    local fallback_action = RoleRotationActionName(
                        role,
                        debuff_variant.spell,
                        seal_variant.spell,
                        true
                    )
                    local fallback_macro = CreateRoleRotationMacro(
                        role,
                        debuff_variant.spell,
                        seal_variant.spell,
                        true
                    )
                    no_justice_judgement_actions[role] =
                        no_justice_judgement_actions[role] or {}
                    no_justice_judgement_actions[role][seal_variant.spell] =
                        fallback_action
                    BindSpellToUnit(fallback_action, "target", fallback_macro, "", true)
                end
            end
        end
    end
end

local HEAL_MACRO = [[
/use [@target,help][@targettarget,help][@focustargettarget,help][@focus,help] Flash of Light
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

local function PaladinSpellKnownForBind(spellName)
    if not spellName then return false end
    if C_SpellBook and C_SpellBook.FindSpellBookSlotForSpell then
        local ok, slot = pcall(C_SpellBook.FindSpellBookSlotForSpell, spellName)
        if ok and type(slot) == "number" and slot > 0 then return true end
    end

    if not (C_Spell and C_Spell.GetSpellInfo) then return false end
    local ok, info = pcall(C_Spell.GetSpellInfo, spellName)
    if not ok or type(info) ~= "table" or type(info.spellID) ~= "number" then
        return false
    end

    local checks = {}
    if type(IsPlayerSpell) == "function" then checks[#checks + 1] = IsPlayerSpell end
    if type(IsSpellKnown) == "function" then checks[#checks + 1] = IsSpellKnown end
    if C_SpellBook and type(C_SpellBook.IsSpellKnown) == "function" then
        checks[#checks + 1] = C_SpellBook.IsSpellKnown
    end
    for _, check in ipairs(checks) do
        local check_ok, known = pcall(check, info.spellID)
        if check_ok and known == true then return true end
    end
    return false
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

local BLESSING_SPELLS = {
    {normal = _spell.blessing_of_might, greater = _spell.greater_blessing_of_might},
    {normal = _spell.blessing_of_wisdom, greater = _spell.greater_blessing_of_wisdom},
    {normal = _spell.blessing_of_kings, greater = _spell.greater_blessing_of_kings},
    {normal = _spell.blessing_of_salvation, greater = _spell.greater_blessing_of_salvation},
    {normal = _spell.blessing_of_light, greater = _spell.greater_blessing_of_light},
}

local RAID_BLESSING_ORDER = {
    WARRIOR = {1, 3, 4, 5},
    ROGUE   = {1, 3, 4, 5},
    PRIEST  = {2, 3, 4, 5},
    DRUID   = {3, 2, 4, 5},
    PALADIN = {2, 3, 1, 4, 5},
    HUNTER  = {1, 3, 4, 2, 5},
    MAGE    = {3, 2, 4, 5},
    WARLOCK = {3, 2, 4, 5},
    SHAMAN  = {2, 3, 4, 1, 5},
}

local DUNGEON_BLESSING_ORDER = {
    WARRIOR_TANK   = {3, 1, 5},
    WARRIOR_DPS    = {1, 3, 4},
    ROGUE          = {1, 3, 4},
    PRIEST         = {2, 3, 4},
    DRUID_BEAR     = {3, 1, 5},
    DRUID_CAT      = {1, 3, 4},
    DRUID_BALANCE  = {2, 3, 4},
    DRUID_RESTO    = {2, 3, 4},
    PALADIN_HOLY   = {2, 3, 1, 4, 5},
    PALADIN_PROT   = {2, 3, 1, 4, 5},
    PALADIN_RET    = {2, 3, 1, 4, 5},
    HUNTER         = {1, 3, 2},
    MAGE           = {2, 3, 4},
    WARLOCK        = {3, 2, 4},
    SHAMAN_CASTER  = {2, 3, 4},
    SHAMAN_MELEE   = {1, 3, 2},
}

local PARTY_SPEC_SKILL = {
    WARRIOR = {[26] = "arms", [256] = "fury", [257] = "protection"},
    PALADIN = {[594] = "holy", [267] = "protection", [184] = "retribution"},
    DRUID = {[574] = "balance", [134] = "feral", [573] = "restoration"},
    SHAMAN = {[375] = "elemental", [373] = "enhancement", [374] = "restoration"},
}
local PARTY_SPEC_NAMES = {
    arms = "arms", waffen = "arms", fury = "fury", furor = "fury",
    protection = "protection", schutz = "protection",
    holy = "holy", heilig = "holy", retribution = "retribution", vergeltung = "retribution",
    balance = "balance", gleichgewicht = "balance", feral = "feral",
    ["feral combat"] = "feral", ["wilder kampf"] = "feral",
    restoration = "restoration", wiederherstellung = "restoration",
    elemental = "elemental", elementalcombat = "elemental", elementarkampf = "elemental",
    ["elemental combat"] = "elemental", elementar = "elemental",
    enhancement = "enhancement", ["verstärkung"] = "enhancement",
}
local PARTY_TREE_SPEC = {
    WARRIOR = {arms = "DPS", fury = "DPS", protection = "TANK"},
    PALADIN = {holy = "HOLY", protection = "PROT", retribution = "RET"},
    DRUID = {balance = "BALANCE", restoration = "RESTO"},
    SHAMAN = {elemental = "CASTER", enhancement = "MELEE", restoration = "CASTER"},
}
local PARTY_DEFAULT_SPEC = {
    WARRIOR = "DPS", DRUID = "RESTO", PALADIN = "HOLY", SHAMAN = "CASTER",
}
local PARTY_MIN_TALENT_POINTS = 5
local party_spec_cache = {}
local party_spec_retry = {}
local party_inspect_pending
local party_inspect_after = 0
local EnoughManaForSpell

local function PartySafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b = pcall(fn, ...)
    if ok then return a, b end
end

local function PartyPlainValue(value, kind)
    if type(issecretvalue) == "function" then
        local ok, secret = pcall(issecretvalue, value)
        if not ok or secret then return false end
    end
    return type(value) == kind
end

local function PartyTreeSpec(class, group)
    local by_skill = PARTY_SPEC_SKILL[class]
    if by_skill and by_skill[group.skillLineID] then
        return by_skill[group.skillLineID]
    end
    if PartyPlainValue(group.displayName, "string") then
        local name = string.lower(group.displayName)
        return PARTY_SPEC_NAMES[name] or PARTY_SPEC_NAMES[name:gsub("%s", "")]
    end
end

local function PartyReadTalentGroups(config_id, class)
    if not C_Traits or not config_id then return nil end
    local config = PartySafeCall(C_Traits.GetConfigInfo, config_id)
    if not config or type(config.treeIDs) ~= "table" or #config.treeIDs == 0 then return nil end
    if config_id ~= -1 and PartySafeCall(C_Traits.ConfigHasStagedChanges, config_id) then return nil end

    local groups, by_id = {}, {}
    for _, tree_id in ipairs(config.treeIDs) do
        local displays = PartySafeCall(C_Traits.GetGroupDisplayInfoByTreeID, tree_id) or {}
        for _, display in ipairs(displays) do
            if display.groupID and not by_id[display.groupID] then
                local group = {
                    groupID = display.groupID,
                    skillLineID = display.skillLineID,
                    displayName = display.displayName,
                    points = 0,
                }
                group.spec = PartyTreeSpec(class, group)
                by_id[group.groupID] = group
                groups[#groups + 1] = group
            end
        end
        for _, node_id in ipairs(PartySafeCall(C_Traits.GetTreeNodes, tree_id) or {}) do
            local node = PartySafeCall(C_Traits.GetNodeInfo, config_id, node_id)
            local ranks = node and node.ranksPurchased
            if PartyPlainValue(ranks, "number") and ranks > 0 then
                for _, group_id in ipairs(node.groupIDs or {}) do
                    local group = by_id[group_id]
                    if group then
                        group.points = group.points + ranks
                        break
                    end
                end
            end
        end
    end

    if #groups == 0 then return nil end
    local ids = {}
    for _, group in ipairs(groups) do ids[#ids + 1] = group.groupID end
    for _, counter in ipairs(PartySafeCall(C_Traits.GetGroupCurrencyInfo, config_id, ids) or {}) do
        local group = by_id[counter.traitNodeGroupID]
        local currency = counter.currencyInfos and counter.currencyInfos[1]
        if group and currency and PartyPlainValue(currency.spent, "number") then
            group.points = currency.spent
        end
    end
    return groups
end

local function PartyBucketFromGroups(class, groups, role)
    local best, tied
    for _, group in ipairs(groups or {}) do
        if group.points > 0 then
            if not best or group.points > best.points then
                best, tied = group, false
            elseif group.points == best.points then
                tied = true
            end
        end
    end
    if not best or tied or best.points < PARTY_MIN_TALENT_POINTS or not best.spec then return nil end

    local spec = PARTY_TREE_SPEC[class] and PARTY_TREE_SPEC[class][best.spec]
    if not spec and class == "DRUID" and best.spec == "feral" then
        spec = role == "TANK" and "BEAR" or "CAT"
    end
    return spec
end

local function PartyUnitRole(unit)
    local role = PartySafeCall(UnitGroupRolesAssigned, unit)
    if PartyPlainValue(role, "string") and role ~= "NONE" then return role end
end

local function PartyFallbackSpec(unit, class)
    local role = PartyUnitRole(unit)
    if class == "WARRIOR" then
        return role == "TANK" and "TANK" or "DPS"
    elseif class == "DRUID" then
        if role == "TANK" then return "BEAR" end
        if role == "DAMAGER" then return "CAT" end
        return "RESTO"
    elseif class == "PALADIN" then
        if role == "TANK" then return "PROT" end
        if role == "DAMAGER" then return "RET" end
        return "HOLY"
    elseif class == "SHAMAN" then
        return role == "DAMAGER" and "MELEE" or "CASTER"
    end
    return PARTY_DEFAULT_SPEC[class]
end

local function PartyBucketForUnit(unit, class)
    local FB = _G.ForeverBlessings
    if FB and type(FB.members) == "table" and type(FB.BUCKETS) == "table" then
        for _, member in ipairs(FB.members) do
            if type(member) == "table" and member.unit == unit
                and member.bucket and FB.BUCKETS[member.bucket] then
                local bucket = FB.BUCKETS[member.bucket]
                if bucket.class == class then return bucket.spec end
            end
        end
    end

    local guid = PartySafeCall(UnitGUID, unit)
    local cached = guid and party_spec_cache[guid]
    if cached and cached.class == class and cached.spec then return cached.spec end
    return PartyFallbackSpec(unit, class)
end

local function PartyTargetSpec(unit, class)
    local spec = PartyBucketForUnit(unit, class)
    if class == "WARRIOR" or class == "DRUID" or class == "PALADIN" or class == "SHAMAN" then
        return spec or PARTY_DEFAULT_SPEC[class]
    end
    return nil
end

local function PartyResolveTalentSpec(config_id, class, unit)
    local groups = PartyReadTalentGroups(config_id, class)
    if not groups then return nil end
    return PartyBucketFromGroups(class, groups, PartyUnitRole(unit))
end

local function PartyInspectReady(guid)
    local pending = party_inspect_pending
    if not pending or not PartyPlainValue(guid, "string") or pending.guid ~= guid then return end
    party_inspect_pending = nil
    local inspect_config = Constants and Constants.TraitConsts
        and Constants.TraitConsts.INSPECT_TRAIT_CONFIG_ID or -1
    local ok, spec = pcall(PartyResolveTalentSpec, inspect_config, pending.class, pending.unit)
    if ok and spec then
        party_spec_cache[guid] = {class = pending.class, spec = spec, time = GetTime()}
    else
        party_spec_retry[guid] = GetTime() + 10
    end
end

local function PartyInspectTick()
    if _G.ForeverBlessings or InCombatLockdown() or GetTime() < party_inspect_after then return end
    if party_inspect_pending then
        if GetTime() - party_inspect_pending.started < 6 then return end
        party_spec_retry[party_inspect_pending.guid] = GetTime() + 10
        party_inspect_pending = nil
    end
    if (InspectFrame and InspectFrame:IsShown())
        or (PlayerSpellsFrame and PartySafeCall(PlayerSpellsFrame.IsInspecting, PlayerSpellsFrame))
        or type(NotifyInspect) ~= "function" then return end

    for _, unit in ipairs(_unitids.party) do
        if UnitExists(unit) then
            local _, class = UnitClass(unit)
            if PARTY_TREE_SPEC[class] then
                local guid = PartySafeCall(UnitGUID, unit)
                local cached = guid and party_spec_cache[guid]
                if guid and (not cached or GetTime() - cached.time > 60)
                    and GetTime() >= (party_spec_retry[guid] or 0)
                    and PartySafeCall(UnitIsConnected, unit)
                    and PartySafeCall(CanInspect, unit) then
                    party_inspect_pending = {
                        unit = unit, guid = guid, class = class, started = GetTime(),
                    }
                    party_inspect_after = GetTime() + 2
                    local ok = pcall(NotifyInspect, unit)
                    if not ok then
                        party_spec_retry[guid] = GetTime() + 10
                        party_inspect_pending = nil
                    end
                    return
                end
            end
        end
    end
end

local party_spec_frame = CreateFrame("Frame")
party_spec_frame:RegisterEvent("INSPECT_READY")
party_spec_frame:RegisterEvent("PLAYER_LOGIN")
party_spec_frame:SetScript("OnEvent", function(_, event, ...)
    if event == "INSPECT_READY" then
        PartyInspectReady(...)
    elseif event == "PLAYER_LOGIN" then
        C_Timer.NewTicker(1, PartyInspectTick)
    end
end)

local function PartySpellKnown(spell_name)
    if not spell_name then return false end
    if C_SpellBook and C_SpellBook.FindSpellBookSlotForSpell then
        local ok, slot = pcall(C_SpellBook.FindSpellBookSlotForSpell, spell_name)
        if ok and PartyPlainValue(slot, "number") then return true end
    end
    local info
    if C_Spell and C_Spell.GetSpellInfo then
        local ok, result = pcall(C_Spell.GetSpellInfo, spell_name)
        if ok and type(result) == "table" then info = result end
    end
    if info and PartyPlainValue(info.spellID, "number") then
        local checks = {}
        if type(_G.IsPlayerSpell) == "function" then checks[#checks + 1] = _G.IsPlayerSpell end
        if type(_G.IsSpellKnown) == "function" then checks[#checks + 1] = _G.IsSpellKnown end
        if C_SpellBook and type(C_SpellBook.IsSpellKnown) == "function" then
            checks[#checks + 1] = C_SpellBook.IsSpellKnown
        end
        for _, check in ipairs(checks) do
            local ok, known = pcall(check, info.spellID)
            if ok and PartyPlainValue(known, "boolean") and known then return true end
        end
    end
    return false
end

local function PartyBlessingName(index, use_greater)
    local blessing = BLESSING_SPELLS[index]
    if not blessing then return nil end
    if use_greater and PartySpellKnown(blessing.greater) then return blessing.greater end
    if PartySpellKnown(blessing.normal) then return blessing.normal end
    return nil
end

local PALADIN_BLESSING_PRIORITY = {2, 3, 1, 4, 5}

local function AutomaticBlessing()
    local assigned = ForeverBlessings_Blessing()
    if assigned and PartySpellKnown(assigned) then return assigned end

    for _, index in ipairs(PALADIN_BLESSING_PRIORITY) do
        local spell_name = PartyBlessingName(index, false)
        if spell_name then return spell_name end
    end
end

local function BlessingIndex(spell_name)
    for index, variants in ipairs(BLESSING_SPELLS) do
        if spell_name == variants.normal or spell_name == variants.greater then
            return index
        end
    end
end

local function SelfBlessingChoice(preferred)
    if not preferred or preferred == false or not PartySpellKnown(preferred) then
        return preferred
    end
    if InCombatLockdown() then return preferred end

    local preferred_index = BlessingIndex(preferred)
    if not preferred_index then return preferred end

    local preferred_spells = BLESSING_SPELLS[preferred_index]
    if RemainingBuffFromMe(preferred_spells.normal, "player") > 0
        or RemainingBuffFromMe(preferred_spells.greater, "player") > 0 then
        return preferred
    end

    local preferred_active = RemainingBuff(preferred_spells.normal, "player") > 0
        or RemainingBuff(preferred_spells.greater, "player") > 0
    if not preferred_active then
        return preferred
    end

    -- The selected blessing is supplied by someone else. Once this Paladin
    -- has supplied any blessing from the fallback priority, keep it instead
    -- of walking to the next missing blessing on every recommendation tick.
    for _, index in ipairs(PALADIN_BLESSING_PRIORITY) do
        local variants = BLESSING_SPELLS[index]
        if RemainingBuffFromMe(variants.normal, "player") > 0
            or RemainingBuffFromMe(variants.greater, "player") > 0 then
            return nil
        end
    end

    for _, index in ipairs(PALADIN_BLESSING_PRIORITY) do
        local variants = BLESSING_SPELLS[index]
        local spell_name = PartyBlessingName(index, false)
        if spell_name and RemainingBuff(variants.normal, "player") == 0
            and RemainingBuff(variants.greater, "player") == 0 then
            return spell_name
        end
    end
end

local function PartyAssignedBlessing(unit, class, spec)
    local FB = _G.ForeverBlessings
    if type(FB) ~= "table" or type(FB.rows) ~= "table"
        or type(FB.me) ~= "string" or type(FB.Mode) ~= "function"
        or type(FB.Values) ~= "function" then return nil end
    local row = FB.rows[FB.me]
    if not row then return nil end

    local ok, assigned, use_greater, mode = pcall(function()
        local mode = FB:Mode()
        local column
        if mode == "raid" then
            for i, class_name in ipairs(FB.CLASSES or {}) do
                if class_name == class then column = i break end
            end
        else
            for _, member in ipairs(FB.members or {}) do
                if member.unit == unit and member.bucket then
                    column = member.bucket
                    break
                end
            end
            if not column and type(FB.BUCKETS) == "table" then
                for i, bucket in ipairs(FB.BUCKETS) do
                    if bucket.class == class and bucket.spec == spec then
                        column = i
                        break
                    end
                end
            end
        end
        if not column then return nil, mode == "raid", mode end
        local values = FB:Values(row, mode)
        local index = values and values[column]
        if PartyPlainValue(index, "number") and index > 0 then
            return index, mode == "raid", mode
        end
        return nil, mode == "raid", mode
    end)
    if ok then return assigned, use_greater, mode end
end

local function PartyBlessingExpired(index, unit)
    local variants = BLESSING_SPELLS[index]
    if not variants then return false end
    return RemainingBuff(variants.normal, unit) == 0
        and RemainingBuff(variants.greater, unit) == 0
end

local function PartyBlessingTargetInRange(spell, unit)
    local connected = PartySafeCall(UnitIsConnected, unit)
    if PartyPlainValue(connected, "boolean") and not connected then return false end
    local visible = PartySafeCall(UnitIsVisible, unit)
    if PartyPlainValue(visible, "boolean") and not visible then return false end

    local in_range = C_Spell and PartySafeCall(C_Spell.IsSpellInRange, spell, unit)
    if PartyPlainValue(in_range, "boolean") then return in_range end
    local checked_range, checked = PartySafeCall(UnitInRange, unit)
    if PartyPlainValue(checked_range, "boolean")
        and PartyPlainValue(checked, "boolean") and checked then
        return checked_range
    end
    return true
end

local party_cast_unit = {}

local function OfferPartyBlessing()
    if InCombatLockdown() or not IsInGroup() then return false end

    for _, unit in ipairs(_unitids.party) do
        if UnitExists(unit) then
            local _, class = UnitClass(unit)
            if class and class ~= "" then
                local spec = PartyTargetSpec(unit, class)
                local key = spec and (class .. "_" .. spec) or class
                local assigned, assigned_greater, mode = PartyAssignedBlessing(unit, class, spec)
                local raid_mode = mode == "raid" or (not mode and IsInRaid())
                local orders = raid_mode and RAID_BLESSING_ORDER or DUNGEON_BLESSING_ORDER
                local order = assigned and {assigned}
                    or orders[key]
                    or orders[class]
                local selected
                local use_greater = assigned and assigned_greater or (not assigned and raid_mode)
                for _, index in ipairs(order or {}) do
                    if PartyBlessingName(index, use_greater) then
                        selected = index
                        break
                    end
                end
                local spell_name = selected and PartyBlessingName(selected, use_greater)
                if spell_name and PartyBlessingExpired(selected, unit) then
                    party_cast_unit[1] = unit
                    if CastSpellUnits(
                        spell_name,
                        party_cast_unit,
                        RemainingCooldown(spell_name) < 0.5
                            and EnoughManaForSpell(spell_name)
                            and not InCombatLockdown(),
                        {SpellUnit_AliveAndFriendly, PartyBlessingTargetInRange}
                    ) then
                        return true
                    end
                end
            end
        end
    end
    return false
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

    -- Dedicated manual Paladin controls; these intentionally override the
    -- client's default F/Q actions and are not Delphi rotation candidates.
    CreateButton(
        "DelphiPaladinHammerOfJusticeManual",
        "F",
        "/cast [@target,harm] " .. _spell.hammer_of_justice
    )

    local cleanse_spell
    if PaladinSpellKnownForBind(_spell.cleanse) then
        cleanse_spell = _spell.cleanse
    elseif PaladinSpellKnownForBind(_spell.purify) then
        cleanse_spell = _spell.purify
    else
        print("Paladin Q bind not created: neither Cleanse nor Purify is known.")
    end
    if cleanse_spell then
        CreateButton(
            "DelphiPaladinCleanseManual",
            "Q",
            "/cast [@target,help][] " .. cleanse_spell
        )
    end

    paladin_interact_binding_owner = CreateFrame("Frame")
    if type(SetOverrideBinding) == "function" then
        local ok = pcall(
            SetOverrideBinding,
            paladin_interact_binding_owner,
            true,
            "=",
            "INTERACTTARGET"
        )
        if not ok then
            print("Paladin interact key not bound: unable to override '='.")
        end
    else
        print("Paladin interact key not bound: SetOverrideBinding is unavailable.")
    end
    EnablePaladinInteractKey()

    BindSpellToUnit("start_attack","","","/startattack",true)
    -- Role and Healing are selected in the Delphi toggle UI.
    BindSpellToUnit(
        NIGHT_WATCHMANS_TORCH_ACTION,
        "",
        "/use item:" .. NIGHT_WATCHMANS_TORCH_ITEM_ID,
        "",
        true
    )

    --Seals - player only
    BindSpellToUnits(_spell.seal_of_righteousness, _unitids.player)
    BindSpellToUnits(_spell.seal_of_command,       _unitids.player)
    BindSpellToUnits(_spell.seal_of_the_crusader,  _unitids.player)
    BindSpellToUnits(_spell.seal_of_fury,          _unitids.player)
    BindSpellToUnit(HEAL_ACTION, "target", HEAL_MACRO, "", 1)

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

    -- Party blessing recommendations need a spell/unit bind for each party slot.
    local party_blessings = {
        _spell.blessing_of_might,
        _spell.blessing_of_wisdom,
        _spell.blessing_of_kings,
        _spell.blessing_of_salvation,
        _spell.blessing_of_light,
        _spell.greater_blessing_of_might,
        _spell.greater_blessing_of_wisdom,
        _spell.greater_blessing_of_kings,
        _spell.greater_blessing_of_salvation,
        _spell.greater_blessing_of_light,
    }
    for _, blessing in ipairs(party_blessings) do
        BindSpellToUnits(blessing, _unitids.party)
    end

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

    BindRoleRotationMacros()
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
EnoughManaForSpell = function(spell)
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
local AURA_PRIORITY = {
    _spell.retribution_aura,
    _spell.devotion_aura,
    _spell.concentration_aura,
    _spell.shadow_resistance_aura,
    _spell.frost_resistance_aura,
    _spell.fire_resistance_aura,
}
local aura_fallback_preference
local aura_fallback_choice

local function AuraActiveFromMe(aura)
    return RemainingBuffFromMe(aura, "player") ~= 0
end

local function AutomaticAura()
    for _, aura in ipairs(AURA_PRIORITY) do
        if PartySpellKnown(aura) then return aura end
    end
end

local function SelfAuraChoice(preferred)
    if not preferred or preferred == false or not PartySpellKnown(preferred) then
        aura_fallback_preference = nil
        aura_fallback_choice = nil
        return preferred
    end
    if aura_fallback_preference ~= preferred then
        aura_fallback_preference = preferred
        aura_fallback_choice = nil
    end

    if InCombatLockdown() then return preferred end

    if AuraActiveFromMe(preferred) then
        aura_fallback_choice = nil
        return preferred
    end

    local preferred_remaining = RemainingBuff(preferred, "player")
    if preferred_remaining == 0 then
        aura_fallback_choice = nil
        return preferred
    end

    if aura_fallback_choice then
        if AuraActiveFromMe(aura_fallback_choice) then
            return nil
        end
        return aura_fallback_choice
    end

    -- If another Paladin supplies the preferred Aura to this player, retain
    -- a self-cast alternative rather than switching as aura updates settle.
    for _, aura in ipairs(AURA_PRIORITY) do
        if aura ~= preferred and AuraActiveFromMe(aura) then
            aura_fallback_choice = aura
            return nil
        end
    end

    for _, aura in ipairs(AURA_PRIORITY) do
        if aura ~= preferred and PartySpellKnown(aura)
            and RemainingBuff(aura, "player") == 0 then
            aura_fallback_choice = aura
            return aura
        end
    end
    return nil
end

local function RoleOverrides(role, context)
    local auto_aura = AutomaticAura()
    local auto_blessing = AutomaticBlessing()
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
    local blessing = ResolveOverride(
        delphi.override.blessing, auto_blessing, ForeverBlessings_Blessing)
    return SelfAuraChoice(ResolveOverride(
        delphi.override.aura, auto_aura, ForeverBlessings_Aura)),
        ResolveOverride(delphi.override.seal, auto_seal),
        SelfBlessingChoice(blessing),
        ResolveOverride(delphi.override.debuffseal, auto_debuffseal)
end

local missing_rotation_actions = {}
local function OfferRoleRotation(role, debuffseal, seal)
    local dps_seal_cast = seal and seal ~= false
        and last_paladin_seal_cast[seal]
    local last_dps_seal_cast = dps_seal_cast and dps_seal_cast.time
    local target_judgement_required = debuffseal and debuffseal ~= false
        and debuffseal == seal
        and not ShouldSkipJusticeJudgement(debuffseal)
    local target_judgement_pending = target_judgement_required
        and last_paladin_judgement_target_generation ~= paladin_target_generation
    local debuff_seal_setup_pending = debuffseal and debuffseal ~= false
        and debuffseal ~= seal
        and last_paladin_seal_cast[debuffseal]
        and last_paladin_seal_cast[debuffseal].target_generation == paladin_target_generation
        and (not dps_seal_cast
            or dps_seal_cast.target_generation ~= paladin_target_generation
            or last_paladin_seal_cast[debuffseal].time > last_dps_seal_cast)
    local target_rotation_ready = not debuffseal or debuffseal == false
        or debuffseal == seal
            and (not target_judgement_required
                or last_paladin_judgement_target_generation == paladin_target_generation)
        or dps_seal_cast
            and dps_seal_cast.target_generation == paladin_target_generation
    if last_dps_seal_cast
        and target_rotation_ready
        and GetTime() - last_dps_seal_cast >= 27
        and not debuff_seal_setup_pending
        and not target_judgement_pending then
        _global.SetSpellUnit(seal, "player")
        return true
    end

    local by_debuffseal = role_rotation_actions[role]
    local by_seal = by_debuffseal and by_debuffseal[debuffseal]
    local action = by_seal and by_seal[seal]
    if ShouldSkipJusticeJudgement(debuffseal) then
        action = no_justice_judgement_actions[role]
            and no_justice_judgement_actions[role][seal]
    end
    if not action or not delphi.bind.spellunit_to_keycombo[action .. "target"] then
        local key = tostring(role) .. ":" .. tostring(debuffseal) .. ":" .. tostring(seal)
        if not missing_rotation_actions[key] then
            print("No bound Paladin rotation macro for " .. key)
            missing_rotation_actions[key] = true
        end
        return false
    end

    _global.SetSpellUnit(action, "target")
    return true
end

local function MacroInRange(spell, unit)
    local ok, in_range = pcall(SpellUnit_RangeCheck, spell, unit)
    return ok and in_range == true
end

local function RoleRotationInRange(debuffseal)
    return not debuffseal
        or ShouldSkipJusticeJudgement(debuffseal)
        or MacroInRange(_spell.judgement, "target")
end

local function IsUndeadOrDemon(unit)
    local ok, _, creature_type_id = pcall(UnitCreatureType, unit)
    if not ok or creature_type_id == nil
        or (issecretvalue and issecretvalue(creature_type_id)) then
        return false
    end

    return creature_type_id == 3 or creature_type_id == 6
end

local function IsHolyWrathTargetUndeadOrDemon()
    return UnitAliveAndHostile("target") and IsUndeadOrDemon("target")
end

local function IsExorcismTargetInRange(spell, unit)
    return IsUndeadOrDemon(unit) and MacroInRange(spell, unit)
end

local function ExorcismCooldownReady()
    return not last_exorcism_cast or GetTime() - last_exorcism_cast >= 15
end

local function SpellCooldownReady(spell)
    local ok, cooldown = pcall(C_Spell.GetSpellCooldown, spell)
    if not ok or type(cooldown) ~= "table" then
        return false
    end

    local start_time = cooldown.startTime
    local duration = cooldown.duration
    if start_time == nil or duration == nil
        or issecretvalue(start_time)
        or issecretvalue(duration) then
        return false
    end

    return start_time == 0 or start_time + duration - _now < 0.5
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
perception_cast_frame:RegisterEvent("UNIT_SPELLCAST_SENT")
perception_cast_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
perception_cast_frame:SetScript("OnEvent", function(_, event, unit, _, arg3, arg4)
    if event == "PLAYER_TARGET_CHANGED" then
        paladin_target_generation = paladin_target_generation + 1
        return
    end

    if unit ~= "player" then
        return
    end

    local spell_id = event == "UNIT_SPELLCAST_SENT" and arg4 or arg3
    if spell_id and issecretvalue and issecretvalue(spell_id) then
        return
    end

    local ok, spell_info = pcall(C_Spell.GetSpellInfo, spell_id)
    local spell_name = ok and spell_info and spell_info.name
    if spell_name == _spell.exorcism then
        last_exorcism_cast = GetTime()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        if spell_name == _spell.judgement then
            last_paladin_judgement_target_generation = paladin_target_generation
        end
        for _, variant in ipairs(SEAL_VARIANTS) do
            if variant.spell and spell_name == variant.spell then
                last_paladin_seal_cast[variant.spell] = {
                    time = GetTime(),
                    target_generation = paladin_target_generation,
                }
                break
            end
        end
        if spell_id == 20600 then
            perception_requested = false
        end
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
    local combat, time_in_combat = CombatStatus()
    local _, _, stationary = MovementStatus()
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
    elseif not combat and stationary
        and SpellUnit_BuffExpired(NIGHT_WATCHMANS_TORCH_BUFF, "player")
        and NightWatchmansTorchReady() then
        _global.SetSpellUnit(NIGHT_WATCHMANS_TORCH_ACTION)
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

            elseif HEAL_ACTION and stationary then
                _global.SetSpellUnit(HEAL_ACTION, "target")
                acted = true
            end
        end
        if not acted then
            if 1 == 0 then

            elseif role ~= "off" and combat and stationary and time_in_combat > 10
                and CastSpellUnits(
                    _spell.holy_wrath
                    ,_unitids.player
                    ,SpellCooldownReady(_spell.holy_wrath)
                        and EnoughManaForSpell(_spell.holy_wrath)
                    ,{ SpellUnit_AliveAndFriendly, IsHolyWrathTargetUndeadOrDemon }
                ) then
                acted = true

            elseif role ~= "off" and combat and time_in_combat >= 3
                and ExorcismCooldownReady()
                and CastSpellUnits(
                    _spell.exorcism
                    ,_unitids.target
                    ,RemainingCooldown(_spell.exorcism) < 0.5
                        and EnoughManaForSpell(_spell.exorcism)
                    ,{ SpellUnit_UnitAliveAndHostile, IsExorcismTargetInRange }
                ) then
                acted = true

            elseif role == "main_tank" then
                -- PVE / DD / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif UnitAliveAndHostile("target")
                    and RoleRotationInRange(debuffseal)
                    and OfferRoleRotation(role, debuffseal, seal) then
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true    

                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- role-specific macros handle the resolved Seal combination.

            elseif role == "off_tank" then
                -- PVE / DD / Off Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif UnitAliveAndHostile("target")
                    and RoleRotationInRange(debuffseal)
                    and OfferRoleRotation(role, debuffseal, seal) then
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true    


                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- role-specific macros handle the resolved Seal combination.

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
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true


                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true

                elseif UnitAliveAndHostile("target")
                    and RoleRotationInRange(debuffseal)
                    and OfferRoleRotation(role, debuffseal, seal) then
                    acted = true
                end  -- closes the PVP / DD / DPS action chain

                -- -- Legacy standalone Judgement candidate; selected debuffseal's matching
                -- -- target effect is handled by the selected role macro.
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
                -- -- role-specific macros handle the resolved Seal combination.

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
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true


                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- role-specific macros handle the resolved Seal combination.
            end
        end
        if not acted then OfferRareScannerMacro(combat) end
    elseif context == "pve" and GodlyIsAOE() then
        local acted = false
        if healing_on then
            -- PVE / AOE / Healing: heals first, not healer buff defaults.
            if 1 == 0 then

            elseif HEAL_ACTION and stationary then
                _global.SetSpellUnit(HEAL_ACTION, "target")
                acted = true
            end
        end
        if not acted then
            if 1 == 0 then

            elseif role ~= "off" and combat and stationary and time_in_combat > 10
                and CastSpellUnits(
                    _spell.holy_wrath
                    ,_unitids.player
                    ,SpellCooldownReady(_spell.holy_wrath)
                        and EnoughManaForSpell(_spell.holy_wrath)
                    ,{ SpellUnit_AliveAndFriendly, IsHolyWrathTargetUndeadOrDemon }
                ) then
                acted = true

            elseif role ~= "off" and combat and time_in_combat >= 3
                and ExorcismCooldownReady()
                and CastSpellUnits(
                    _spell.exorcism
                    ,_unitids.target
                    ,RemainingCooldown(_spell.exorcism) < 0.5
                        and EnoughManaForSpell(_spell.exorcism)
                    ,{ SpellUnit_UnitAliveAndHostile, IsExorcismTargetInRange }
                ) then
                acted = true

            elseif role == "main_tank" then
                -- PVE / AOE / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif UnitAliveAndHostile("target")
                    and RoleRotationInRange(debuffseal)
                    and OfferRoleRotation(role, debuffseal, seal) then
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true    


                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- role-specific macros handle the resolved Seal combination.

            elseif role == "off_tank" then
                -- PVE / AOE / Off Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif UnitAliveAndHostile("target")
                    and RoleRotationInRange(debuffseal)
                    and OfferRoleRotation(role, debuffseal, seal) then
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true    
                  

                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- role-specific macros handle the resolved Seal combination.

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
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true


                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true

                elseif UnitAliveAndHostile("target")
                    and RoleRotationInRange(debuffseal)
                    and OfferRoleRotation(role, debuffseal, seal) then
                    acted = true
                end  -- closes the PVP / DD / DPS action chain

                -- -- Legacy standalone Judgement candidate; selected debuffseal's matching
                -- -- target effect is handled by the selected role macro.
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
                -- -- role-specific macros handle the resolved Seal combination.

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
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true


                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- role-specific macros handle the resolved Seal combination.
            end
        end
        if not acted then OfferRareScannerMacro(combat) end
    elseif context == "pvp" and GodlyIsDD() then
        local acted = false
        if healing_on then
            -- PVP / DD / Healing: heals first, not healer buff defaults.
            if 1 == 0 then
                
            elseif HEAL_ACTION and stationary then
                _global.SetSpellUnit(HEAL_ACTION, "target")
                acted = true
            end
        end
        if not acted then
            if 1 == 0 then

            elseif role ~= "off" and combat and stationary and time_in_combat > 10
                and CastSpellUnits(
                    _spell.holy_wrath
                    ,_unitids.player
                    ,SpellCooldownReady(_spell.holy_wrath)
                        and EnoughManaForSpell(_spell.holy_wrath)
                    ,{ SpellUnit_AliveAndFriendly, IsHolyWrathTargetUndeadOrDemon }
                ) then
                acted = true

            elseif role ~= "off" and combat and time_in_combat >= 3
                and ExorcismCooldownReady()
                and CastSpellUnits(
                    _spell.exorcism
                    ,_unitids.target
                    ,RemainingCooldown(_spell.exorcism) < 0.5
                        and EnoughManaForSpell(_spell.exorcism)
                    ,{ SpellUnit_UnitAliveAndHostile, IsExorcismTargetInRange }
                ) then
                acted = true

            elseif role == "main_tank" then
                -- PVP / DD / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif UnitAliveAndHostile("target")
                    and RoleRotationInRange(debuffseal)
                    and OfferRoleRotation(role, debuffseal, seal) then
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true    


                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- role-specific macros handle the resolved Seal combination.

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
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true

                -- elseif seal and combat and CastSpellUnits(
                --     seal
                --     ,_unitids.player
                --     ,RemainingCooldown(seal) < 0.5
                --         and EnoughManaForSpell(seal)
                --     ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                -- ) then
                --     acted = true

                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true

                elseif UnitAliveAndHostile("target")
                    and RoleRotationInRange(debuffseal)
                    and OfferRoleRotation(role, debuffseal, seal) then
                    acted = true
                end  -- closes the PVP / DD / DPS action chain

                -- The role macro now supplies the Judgement and Holy Strike sequence.
                -- -- Legacy standalone Judgement candidate; selected debuffseal's matching
                -- -- target effect is handled by the selected role macro.
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
                -- role-specific macros handle the resolved Seal combination.

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
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true


                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- role-specific macros handle the resolved Seal combination.
            end
        end
        if not acted then OfferRareScannerMacro(combat) end
    elseif context == "pvp" and GodlyIsAOE() then
        local acted = false
        if healing_on then
            -- PVP / AOE / Healing: heals first, not healer buff defaults.
            if 1 == 0 then
            elseif HEAL_ACTION and stationary then
                _global.SetSpellUnit(HEAL_ACTION, "target")
                acted = true
            end
        end
        if not acted then
            if 1 == 0 then

            elseif role ~= "off" and combat and stationary and time_in_combat > 10
                and CastSpellUnits(
                    _spell.holy_wrath
                    ,_unitids.player
                    ,SpellCooldownReady(_spell.holy_wrath)
                        and EnoughManaForSpell(_spell.holy_wrath)
                    ,{ SpellUnit_AliveAndFriendly, IsHolyWrathTargetUndeadOrDemon }
                ) then
                acted = true

            elseif role ~= "off" and combat and time_in_combat >= 3
                and ExorcismCooldownReady()
                and CastSpellUnits(
                    _spell.exorcism
                    ,_unitids.target
                    ,RemainingCooldown(_spell.exorcism) < 0.5
                        and EnoughManaForSpell(_spell.exorcism)
                    ,{ SpellUnit_UnitAliveAndHostile, IsExorcismTargetInRange }
                ) then
                acted = true

            elseif role == "main_tank" then
                -- PVP / AOE / Main Tank
                local aura, seal, blessing, debuffseal = RoleOverrides(role, context)
                if 1 == 0 then

                elseif UnitAliveAndHostile("target")
                    and RoleRotationInRange(debuffseal)
                    and OfferRoleRotation(role, debuffseal, seal) then
                    acted = true

                elseif aura and CastSpellUnits(
                    aura
                    ,_unitids.player
                    ,RemainingCooldown(aura) < 0.5
                        and EnoughManaForSpell(aura)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true

                elseif _spell.righteous_fury and CastSpellUnits(
                    _spell.righteous_fury
                    ,_unitids.player
                    ,RemainingCooldown(_spell.righteous_fury) < 0.5
                        and EnoughManaForSpell(_spell.righteous_fury)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true    


                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- role-specific macros handle the resolved Seal combination.

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
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true


                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true


                elseif UnitAliveAndHostile("target")
                    and RoleRotationInRange(debuffseal)
                    and OfferRoleRotation(role, debuffseal, seal) then
                    acted = true
                end  -- closes the PVP / DD / DPS action chain

                -- -- Legacy standalone Judgement candidate; selected debuffseal's matching
                -- -- target effect is handled by the selected role macro.
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
                -- -- role-specific macros handle the resolved Seal combination.

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
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true


                elseif OfferPartyBlessing() then
                    acted = true

                elseif blessing and CastSpellUnits(
                    blessing
                    ,_unitids.player
                    ,RemainingCooldown(blessing) < 0.5
                        and EnoughManaForSpell(blessing)
                        and not combat
                    ,{ SpellUnit_AliveAndFriendly, SpellUnit_BuffExpired }
                ) then
                    acted = true
                end
                -- debuffseal is resolved for this role; the Judgement-of-X
                -- role-specific macros handle the resolved Seal combination.
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
