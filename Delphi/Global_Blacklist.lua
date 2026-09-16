local greenlist = {}
local active_spell = {}
local blacklist = {}

local latency_est = 0.5

-- -- --[[test variables / mocked fns]]
-- -- _now = 12345
-- -- delphi.player = {}
-- -- delphi.player.casting = {}
-- -- delphi.player.casting.spell_name = "Regrowth"
-- -- delphi.player.casting.dest_name = "player"
-- -- function UnitName(unit)
-- --     if unit == "player" then return "Xatu" else return "Unknown" end
-- -- end

-- -- function UnitGUID(unit)
-- --     if unit == "player" then return "0x1234" else return "0x9876" end
-- -- end


--fired when the pythia colour is set to a spell/unit combo
function GreenlistSpellUnit(spell, unit)
    -- Fetch spell info or handle Extra Action Button
    local spell_name, cast_millis, est_cast_seconds, spell_id

    if spell == "ExtraActionButton1" then
        -- Custom handling for Extra Action Button
        spell_name = "ExtraActionButton1"
        cast_millis = 0
        est_cast_seconds = 0
        spell_id = ExtraActionButton1.action
    else
        -- Standard handling for spells
        local spell_info = C_Spell.GetSpellInfo(spell)
        spell_name = spell_info.name
        cast_millis = spell_info.castTime
        spell_id = spell_info.spellID
        est_cast_seconds = (cast_millis or 0) / 1000
    end

    local unit_name = UnitNameServer(unit) or ""
    --print("THIS UNIT IS CALLED ", unit_name)

    _greenlist_entry = {
        source      = "keypress_event",
        unit        = unit,
        spell       = spell,
        unit_name   = unit_name,
        unit_guid   = UnitGUID(unit) or "",
        time_start  = _now,
        time_end    = _now + est_cast_seconds + latency_est
    }

    greenlist[_now] = _greenlist_entry

    PruneTransactionTable(greenlist, 5)

    --PrintTransactionTable(greenlist, "Greenlist")
    --print("GREENLIST PRUNING SHOULD BE TIMER BASED, NOT EVENT BASED - WASTE OF PROCESSING POWER!")
end


function StringifyArray(t)
    local result = ""
    for k,v in next,t do
        result = result .. k .. ":" .. v .. ", "
    end
    return result
end

function PrintTransactionTable(t,opt_header)
    if opt_header then
        print(">>>>",opt_header)
    end

    for event_time,event_data in next,t do
        print("@",event_time,":::",StringifyArray(event_data))
    end
end

--ditch anything over 5 seconds old in the greenlist, because no spells that need to be blacklisted/recast protected take that long? 
function PruneTransactionTable(t,window_seconds)
    for k,v in next,t do
        if _now > k+window_seconds then
            t[k] = nil
        end
    end
end

--this is fired by UNIT_SPELLCAST_SENT, note it has *unitname* not spellname
function GreenlistActivation(spell_id, spell_name, unit_name)
    --print("ACTIVATE : keypress occurred - ",spell_name,unit_name)

    local latest_matching_event_time = 0
    local latest_matching_event_data = {}
    for event_time, event_data in next, greenlist do
        if event_time > latest_matching_event_time and spell == event_data["spell"] and event_data["unit_name"] == unit_name then
            latest_matching_event_time = event_time
            latest_matching_event_data = event_data
        end
    end

    if latest_matching_event_time > 0 then
        -- We found a matching pythia-press, so blacklist that unit by GUID
        active_spell = latest_matching_event_data
    else
        -- We couldn't find a matching pythia-press, so we have to best-guess block by unit_name instead of unit_guid

        local spell_info = C_Spell.GetSpellInfo(spell_id) -- "casttime" can differ more accurate than using spell_name, so let's improve
        local spell_name = spell_info.name
        local cast_millis = spell_info.castTime
        local spell_id = spell_info.spellID
        local est_cast_seconds = (cast_millis or 0) / 1000

        active_spell = {
            source      = "cast_event",
            unit        = unit,
            spell       = spell_name,
            spell_id    = spell_id,
            unit_name   = unit_name,
            unit_guid   = "",
            time_start  = _now,
            time_end    = _now + est_cast_seconds + latency_est
        }
    end

    --print("ACTIVATE : by",spell_name,"@",unit_name," event_time:",_now,"event_data:",StringifyArray(active_spell))
end


--fired when error event occurs
--delphi.player.casting = {}
function BlacklistMostRecentSpellUnit(reason)
    print("BLACKLIST : Error occurred, look at most recent cast of ", delphi.player.casting.spell_name, "at", delphi.player.casting.dest_name)

    if active_spell["spell"] == "ExtraActionButton1" then
        -- Extra Action Button-specific blacklist entry
        print("BLACKLIST : Extra Action Button triggered error:", reason)
    end

    blacklist[_now] = active_spell

    --[[ 
        - this is fired by UI_ERROR_MESSAGE : "Target not in line of sight" 
        - it doesn't know anything else about the cast
        - but we can access the unit-name via the previous UNIT_SPELLCAST_SENT event (not the guid, just name)
        - should be adequate after combining with the last second 
          of delphi.pythia.global/instant.SetSpellUnit(spell,unit) 
          to get a list of recent guid/names to search
    ]]

    PruneTransactionTable(blacklist, 10)
    --print("BLACKLIST PRUNING SHOULD BE TIMER BASED, NOT EVENT BASED - WASTE OF PROCESSING POWER!")
end









function SpellUnit_NotBlacklistedRecently(spell, unit)
    local unit_name = UnitNameServer(unit) or ""
    local unit_guid = UnitGUID(unit) or ""
    local window_seconds = 5

    for event_time, event_data in next, blacklist do
        if event_data["source"] == "cast_event" or spell == "ExtraActionButton1" then
            if event_time + window_seconds > _now and spell == event_data["spell"] then
                --print("Blacklist by cast_event data / unit_name")
                return false
            end
        else
            if event_time + window_seconds > _now and spell == event_data["spell"] and unit_guid == event_data["unit_guid"] then
                --print("Blacklist by keypress_event data / guid")
                return false
            end
        end
    end

    return true
end


function UnitNameServer(unit)
    local unit_name, unit_server = UnitName(unit)
    if unit_server then
        unit_name = unit_name .. "-" .. unit_server
    end
    return unit_name
end

function SpellUnit_NoRecasting(spell,unit)
    --print("RecastCheck :: ",spell,unit)
    local unit_name = UnitNameServer(unit) or ""
    local unit_guid = UnitGUID(unit) or ""
    local casting_spell,cast_remaining,cast_remaining_perc,cast_interruptable = CastInfo("player")
    if casting_spell ~= spell then
        return true
    end

    if active_spell["source"] == "cast_event" then
        --print("cast_event check : spell:",spell,"vs",active_spell["spell"],", unit_name:",unit_name,"vs",active_spell["unit_name"])
        if spell == active_spell["spell"] and unit_name == active_spell["unit_name"] then
            --print("Recast blocked by cast_event data / unit_name")
            return false
        end
    elseif active_spell["source"] == "keypress_event" then
        --print("keypress_event check : spell:",spell,"vs",active_spell["spell"],", guid:",unit_guid,"vs",active_spell["unit_guid"])
        if spell == active_spell["spell"] and unit_guid == active_spell["unit_guid"] then
            --print("Recast blocked by keypress_event data / guid")
            return false
        end
    else
        --print("UNKNOWN EVENT TYPE : ",active_spell["source"],"ALLOWING BUT WTF YOU DOING??")
    end

    return true
end

-- GreenlistSpellUnit("Regrowth","player")
-- GreenlistActivation("Regrowth","Xatu")
-- BlacklistMostRecentSpellUnit("Line of sight Blablabla")

-- print(SpellUnit_NoRecasting("Regrowth","player"))
-- print(SpellUnit_NoRecasting("Rejuvenation","player"))


-- print(SpellUnit_NotBlacklistedRecently("Regrowth","player"))
-- print(SpellUnit_NotBlacklistedRecently("Rejuvenation","player"))







-- local greenlist = {}

-- --fired when the pythia colour is set to a spell/unit combo
-- function GreenlistSpellUnit(spell,unit)
--     print("Greenlist_Preparation : adding",spell,"&",unit,"to greenlist, in case target errors occur soon")

--     -- _greenlist_entry = {}

--     -- greenlist[_now] = {"unit":unit}

--     print("THIS IS WHAT YOU WERE WORKING ON, KEEP GOING - get the blacklist done :)")
-- end

-- --this is fired by UNIT_SPELLCAST_SENT, note it has *unitname* not spellname
-- function GreenlistActivation(spellname,unitname)
--     print("Greenlist_Activation : keypress occurred - ",spellname,unitname)
-- end

-- --fired when error event occurs
-- function BlacklistMostRecentSpellUnit(reason)
--     print("Blacklist_Activation : Error occurred, look at most recent cast of ",delphi.player.casting.spell_name,"at",delphi.player.casting.dest_name)
--     --[[ 
--         - this is fired by UI_ERROR_MESSAGE : "Target not in line of sight" 
--         - it doesn't know anything else about the cast
--         - but we can access the unit-name via the previous UNIT_SPELLCAST_SENT event (not the guid, just name)
--         - should be adequate after combining with the last second 
--           of delphi.pythia.global/instant.SetSpellUnit(spell,unit) 
--           to get a list of recent guid/names to search

--     ]]

-- end
