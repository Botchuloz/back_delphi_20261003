local _register        = {}
local _lasterror       = {}
local _lastcast        = {}
local _track_aura      = delphi.track_aura
local print = DelphiPrint
delphi.whisper_follow = delphi.whisper_follow or {}
local whisper_follow = delphi.whisper_follow

local function ArmWhisperFollow()
    if not whisper_follow.sender or InCombatLockdown() then
        return
    end

    local button = delphi.bind.button.whisper_follow
    if not button then
        print("Whisper follow button is unavailable.")
        return
    end

    button:SetAttribute("macrotext", "/stopmacro [combat]\n/targetexact " .. whisper_follow.sender .. "\n/follow")
end




table_meleeAttacks_byDestAndSource = {}
table_meleeAttacks_bySourceAndDest = {}
table_meleeAttacks_bySource        = {}

table_combatTime = {}

table_movementTime = {}

-- Track the status of the Extra Action Button
function TrackExtraActionButton()
    if HasExtraActionBar() and ExtraActionButton1:IsShown() then
        local start, duration = GetActionCooldown(ExtraActionButton1.action)
        if duration == 0 then
            --print("Extra Action Button is ready to use.")
        else
            --print("Extra Action Button is on cooldown.")
        end
    else
        --print("Extra Action Button is not available.")
    end
end


function CombatStartSetup()
    table_combatTime["fighting_started"] = _now
end


function CombatEndCleanup()
    -- track combat start/end
    table_combatTime["fighting_ended"] = _now
    local current_fight_start = table_combatTime["fighting_started"] or _now
    table_combatTime[current_fight_start] = _now
    --print("current fight started at ",current_fight_start," and ended at ",_now)

    for k,v in pairs(table_combatTime) do
        if v < _now - 10*60 then
            table_combatTime[k] = nil
        end
    end

    -- wipe the table of who hit which targets with melee abilities
    table_meleeAttacks_byDestAndSource = {}
    table_meleeAttacks_bySourceAndDest = {}
    table_meleeAttacks_bySource        = {}
end

--local moving,moving_for,stationary,stationary_for,speed = MovementStatus()
function MovementStatus()
    local speed       = (GetUnitSpeed("player") / 7) or 0
    local stationary  = speed == 0
    local moving      = not stationary
    local status      = stationary and "stationary" or "moving"

    local stationary_for = 0
    local moving_for     = 0

    --if I just reloaded ui or something, pretend I was always doing whatever I'm doing now.
    if not table_movementTime["movementstatus"] then
        table_movementTime["movementstatus"]   = status
        if moving then
            table_movementTime["started_stationary"] = 0
            table_movementTime["started_moving"]     = _now
        else
            table_movementTime["started_moving"]     = 0
            table_movementTime["started_stationary"] = _now
        end
    end

    --if I was moving, or we don't know what happened 
    if table_movementTime["movementstatus"] == "moving" then
        --and I stopped moving
        if stationary then
            --handle stopping moving
            table_movementTime["started_stationary"] = _now
            --print("stopped moving")
        else
            moving_for = _now - table_movementTime["started_moving"]
        end
    --if I was stationary
    else
        --and I started moving
        if moving then
            --handle starting moving
            table_movementTime["started_moving"] = _now
            --print("started moving")
        else
            stationary_for = _now - table_movementTime["started_stationary"]
        end
    end

    table_movementTime["movementstatus"] = status
    table_movementTime["speed"]          = speed

    return moving,moving_for,stationary,stationary_for,speed
end

--local combat, time_in_combat, time_ooc, last_fight_duration = CombatStatus()
function CombatStatus()
    local combat = UnitAffectingCombat("player")
    local last_combat_start_event = table_combatTime["fighting_started"] or 0
    local last_combat_end_event   = table_combatTime["fighting_ended"] or 0

    local time_in_combat      = _now - last_combat_start_event -- iff in combat
    local time_out_of_combat  = _now - last_combat_end_event   -- iff out of combat
    local last_fight_duration = last_combat_end_event - last_combat_start_event -- time between last two events
    if combat then
        return true, time_in_combat,                   0, last_fight_duration
    else
        return false,              0, time_out_of_combat, last_fight_duration
    end
end


function _register:PLAYER_REGEN_DISABLED(event, ...)
    -- Player entered combat
    CombatStartSetup()
    -- Check Extra Action Button status
    TrackExtraActionButton()
end

function _register:PLAYER_REGEN_ENABLED(event, ...)
    -- Player exited combat
    CombatEndCleanup()
    -- Check Extra Action Button status
    TrackExtraActionButton()
    ArmWhisperFollow()
end


function _register:CHAT_MSG_WHISPER(event, message, sender)
    if type(message) ~= "string" or string.lower(message:match("^%s*(.-)%s*$")) ~= "follow" then
        return
    end

    if type(sender) ~= "string" or sender == "" or sender:find("[%c]") then
        print("Ignored a follow whisper with an invalid sender.")
        return
    end

    if not delphi.bind.spellunit_to_keycombo.whisper_follow then
        print("Follow request from " .. sender .. " received, but Delphi has no free key to bind it.")
        return
    end

    whisper_follow.sender = sender
    ArmWhisperFollow()

    whisper_follow.pending = true
end


-- Re-run racial/profession spell detection once the player is fully loaded
-- into the world. Global_Abilities_Racials.lua runs its detection once at
-- file-load time (very early in the addon's load order), which can be
-- before profession/racial spellbook data is fully cached; this ensures it
-- gets a second, reliable pass.
function _register:PLAYER_ENTERING_WORLD(event, ...)
    if DetectRacialAndProfessionAbilities then
        DetectRacialAndProfessionAbilities()
    end
end


function _register:ADDON_LOADED(event, addon_name)
    if addon_name == "Delphi" then
        delphi.LoadPaladinOverrides()
    end
end


function _register:PLAYER_LOGOUT(event, ...)
    delphi.SavePaladinOverrides()
end


function LastErrorMessageOccurred(error_string)
    return _now - (_lasterror[error_string] or (_now-999))
end


function _register:UI_ERROR_MESSAGE(event,...)
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = ...

    --arg1 seems to be a broader error category int
    _lasterror[arg2] = _now -- arg2 = the text. 
    --print("ERR:",arg2)

    if arg2 == "Target not in line of sight" then
        BlacklistMostRecentSpellUnit(arg2)
    end
end

delphi.player.casting = {}
function _register:UNIT_SPELLCAST_SENT(event,...)
    local source_unitid, dest_unit_name, cast_guid, spell_id = ...
    local spellInfo = C_Spell.GetSpellInfo(spell_id)

    if spellInfo then
        local spell_name = spellInfo.name or ""
        --print("casting ", spell_name, " at ", dest_unit_name)
        GreenlistActivation(spell_id, spell_name, dest_unit_name)

        delphi.player.casting.start = _now
        delphi.player.casting.dest_name = dest_unit_name
        delphi.player.casting.spell_name = spell_name
    else
        print("Spell ID ", spell_id, " not found.")
    end
end

function LastCastSpellAtAnything(spell)
    last_cast = _lastcast[spell] or (_now-999)
    return _now - last_cast
end

function MeleeAttackers(units,seconds)
    if type(units) == "string" then
        units = {units}
    end

    local foes = {}

    for i,unit in next,units do
        local unit_guid = UnitGUID(unit) or ""
        local current_attackers = select_row(table_meleeAttacks_byDestAndSource,unit_guid)
        for source_guid,last_attack in pairs(current_attackers) do
            if last_attack + seconds > _now then
                foes[source_guid] = last_attack
            end
        end

        if table_meleeAttacks_bySource[unit_guid] then
            local event_time = table_meleeAttacks_bySource[unit_guid].event_time or 0
            local dest_guid  = table_meleeAttacks_bySource[unit_guid].dest_guid or 0
            local dest_units_last_melee  = foes[dest_guid] or 0
            if dest_units_last_melee and event_time > dest_units_last_melee then
                foes[dest_guid] = dest_units_last_melee
            end
        end
    end
    return count_table(foes),foes
end

-- function MeleeAttackerCount(unit,seconds)
--     local count = 0
--     local unit_guid = UnitGUID(unit) or ""
--     local current_attackers = select_row(table_meleeAttacks_byDestAndSource,unit_guid)
--     for source_guid,last_attack in pairs(current_attackers) do
--         if last_attack + seconds > _now then
--             count = count + 1
--         end
--     end
--     return count
-- end

function _register:COMBAT_LOG_EVENT_UNFILTERED(event,...)
    local event_time, event_type, hide_caster,
    source_guid, source_name, source_flags, source_raidflags,
    dest_guid, dest_name, dest_flags, dest_raidflags,
    --note args from here vary depending on the event type, but they are stable for most spell_* events
    spellid_or_misstype_or_hitamount,spell_name,spell_school,aura_type,amount,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24 = CombatLogGetCurrentEventInfo()

    local spell_id  = spellid_or_misstype_or_hitamount -- for spell_* events
    local miss_type = spellid_or_misstype_or_hitamount -- for swing_missed events (note, swing_* events skip "spellid,spellname,spellschool" args, so they start from 12 instead of 15)
    local hit_amount = spellid_or_misstype_or_hitamount -- for swing_damage events

    local player_guid = UnitGUID("player") 
    local pet_guid = UnitGUID("pet")

    --player and pet events
    if source_guid == player_guid or source_guid == pet_guid then
        if event_type == "SPELL_CAST_SUCCESS" then
            _lastcast[spell_name] = _now
            --print("CLEU : player_spell : "..spell_name)
        end

        -- delphi.track_aura.<spell>.<dest_guid>.<event_name> = event_time
        if _track_aura[spell_name] and dest_guid ~= player_guid and dest_guid ~= pet_guid then --[[exclude player and pet, because spells like death and decay include a buff on me and damage to enemies, which makes them say "total targets = me + enemies instead of just enemies"]]
            --print("CLEU Tracked : ",spell_name," & ",event_type," & ",dest_guid)
            if event_type == "SPELL_AURA_APPLIED" or event_type == "SPELL_AURA_APPLIED_DOSE" then -- eventType == "SPELL_CAST_SUCCESS" or 
                if not _track_aura[spell_name][dest_guid] then
                    _track_aura[spell_name][dest_guid] = {}
                end
                _track_aura[spell_name][dest_guid].applied = _now --print("CLEU: ",spell_name,"applied to",dest_guid)
            elseif event_type == "SPELL_PERIODIC_DAMAGE" or event_type == "SPELL_AURA_REMOVED_DOSE" or event_type == "SPELL_DAMAGE" then
                if not _track_aura[spell_name][dest_guid] then
                    _track_aura[spell_name][dest_guid] = {}
                    _track_aura[spell_name][dest_guid].applied = _now
                end
                _track_aura[spell_name][dest_guid].ticked = _now --print("CLEU: ",spell_name,"applied to",dest_guid)
            elseif event_type == "SPELL_AURA_REMOVED" then
                _track_aura[spell_name][dest_guid] = nil --print("CLEU: ",spell_name,"removed from",dest_guid)
            end
        end
    end

    if event_type == "SWING_DAMAGE" then
        --print("CLEU SWING : ",source_guid)
        update_table(table_meleeAttacks_byDestAndSource,dest_guid,source_guid,_now)
        --update_table(table_meleeAttacks_bySourceAndDest,source_guid,dest_guid,_now)
        table_meleeAttacks_bySource[source_guid] = {dest_guid = dest_guid,event_time = _now}

        if dest_guid==player_guid and source_guid~=player_guid then
            --player_hit_by_melee = _now
            --print("CLEU : enemy_melee_player")
        elseif dest_guid~=player_guid and source_guid==player_guid then
            --_player_last_hit_something = _now
            --print("CLEU : player_melee_enemy")
        end
    end
end

-- Hook into Extra Action Button clicks
hooksecurefunc(ExtraActionButton1, "Click", function()
    print("Extra Action Button was clicked.")
end)

delphi.event.lasterror    = _lasterror
delphi.event.register     = _register
delphi.event.lastcast     = _lastcast
--print("Core_Events.lua")

BindSpellToUnit("whisper_follow", "", "", "", true)
local whisper_follow_button = delphi.bind.button.whisper_follow
if whisper_follow_button then
    whisper_follow_button:SetScript("PostClick", function(button)
        if not InCombatLockdown() then
            whisper_follow.sender = nil
            whisper_follow.pending = false
            button:SetAttribute("macrotext", "")
        end
    end)
end