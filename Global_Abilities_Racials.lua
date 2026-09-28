delphi.racial = {}
delphi.profession = {}

local _, player_race = UnitRace("player")

local racial_candidates = {
    Human = {
        { key = "willtosurvive", name = "Will to Survive", id = 59752 },
        { key = "perception",    name = "Perception",       id = 20600 },
    },
    -- other races added here as Delphi needs them
}

for _, candidate in ipairs(racial_candidates[player_race] or {}) do
    if IsPlayerSpell(candidate.id) then
        delphi.racial[candidate.key] = candidate.name
    end
end

local profession_candidates = {
    { key = "findminerals", name = "Find Minerals", id = 2580 },
    { key = "findherbs",    name = "Find Herbs",     id = 2383 },
}

for _, candidate in ipairs(profession_candidates) do
    if IsPlayerSpell(candidate.id) then
        delphi.profession[candidate.key] = candidate.name
    end
end
