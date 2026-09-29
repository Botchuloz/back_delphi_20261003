delphi.racial = {}
delphi.profession = {}

local print = DelphiPrint
local function SpellKnownByID(spellID)
    if C_SpellBook and C_SpellBook.IsSpellKnown then
        return C_SpellBook.IsSpellKnown(spellID)
    elseif IsPlayerSpell then
        return IsPlayerSpell(spellID)
    end
    return false
end

local racial_candidates = {
    Human = {
        { key = "willtosurvive", name = "Will to Survive", id = 59752 },
        { key = "perception",    name = "Perception",       id = 20600 },
    },
    -- other races added here as Delphi needs them
}

local profession_candidates = {
    { key = "findminerals", name = "Find Minerals", id = 2580 },
    { key = "findherbs",    name = "Find Herbs",     id = 2383 },
}

-- Re-runnable: detection can run too early (before spellbook/profession data
-- is fully cached) if only called once at file-load time, so this is exposed
-- as a named global function and also re-run on PLAYER_ENTERING_WORLD
-- (see Core_Events.lua).
function DetectRacialAndProfessionAbilities()
    local _, player_race = UnitRace("player")

    for _, candidate in ipairs(racial_candidates[player_race] or {}) do
        if SpellKnownByID(candidate.id) then
            delphi.racial[candidate.key] = candidate.name
        end
    end

    for _, candidate in ipairs(profession_candidates) do
        if SpellKnownByID(candidate.id) then
            delphi.profession[candidate.key] = candidate.name
        end
    end
end

DetectRacialAndProfessionAbilities()
