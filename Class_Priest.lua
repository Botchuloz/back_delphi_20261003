local print = DelphiPrint
--/run print(GetActiveSpecGroup()) -- while in shadow(3) this returned a 1, nfi
--/run print(GetSpecialization()) -- 3 = shadow
--/run print(GetSpecializationRole(3)) -- returns "DAMAGER" / ? "HEALER" / ? "TANKER"
--/run print(GetTalentInfo()) -- dud
--/run print(GetTalentInfo(1,1)) -- dud
--/run print(GetActiveSpecGroup()) -- dud, looks like dual-spec function, always returns 1 (used to return 1/2 in previous specs)
--/run print(GetNumSpecializations()) -- 3 for most classes, 4 for druid
-- /run print(IsPlayerSpell(213610)) -- holy ward (pvp talent, active, works)
-- /run print(IsPlayerSpell(200199)) -- censure (pve talent, passive) -- > https://www.wowhead.com/spell=200199/censure
--/run print(C_SpecializationInfo.GetPvpTalentSlotInfo(1)) -- returns a table of info
-- pvp talent info : https://www.wowinterface.com/forums/showthread.php?t=58639

--/run print(GetTalentInfo(1,1,3))

-- /run print(delphi.unit.player.buff["Power Word: Shield"].remaining_or_high)
-- /run print(delphi.unit.player.buff["Power Word: Shield"].remaining)
-- /run print(delphi.unit.player.buff["Power Word: Shield"].remaining_any)
-- /run print(delphi.unit.player.buff["Power Word: Shield"].remaining_other)

-- /run print(delphi.unit.target.debuff["Shadow Word: Pain"].remaining)
-- /run print(delphi.unit.target.debuff["Purge the Wicked"].remaining)

--/run print(delphi.unit["focus"].debuff["Shadow Word: Pain"].remaining)

-- function my_delegate(spell,unit)
--     if delphi.unit[unit].debuff[spell].remaining > 5 then
--         return 10
--     else
--         return -1
--     end
-- end


--/print FreeBindCount()


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

local _priest  = {}
local _spell  = {}
local _cd     = {}
local _buff   = {}
local _debuff = {}

local _unitids = delphi.unitids
local _unit    = delphi.unit
local _instant = delphi.pythia.instant
local _global  = delphi.pythia.global



--Miscellaneous
    _spell.racial = "Will to Survive"
    _spell.weakened_soul = "Weakened Soul"
    _spell.healthstone = "Healthstone"

--Shadowlands Covenant
    _spell.kyrian_boon = "Boon of the Ascended"
    _spell.kyrian_nova = "Ascended Nova"
    _spell.kyrian_blast = "Ascended Blast"
    _spell.kyrian_steward = "Summon Steward"
    _spell.kyrian_phial = "Phial of Serenity"   --/use item:177278 from https://www.reddit.com/r/wow/comments/qlgxxz/macro_for_all_4_covenant_abilities/hj9efl2/
    _spell.necrolord_fleshcraft = "Fleshcraft"
    _spell.necrolord_unholy_nova = "Unholy Nova" 
    _spell.venthyr_mindgames = "Mindgames(Venthyr)"   
    _spell.night_fae_fae_guardians = "Fae Guardians"   
    _spell.night_fae_soulshape = "Soulshape"   
    _spell.trained_gromit_carrier = "Trained Gromit Carrier"   --/use item:187508 from https://www.wowhead.com/item=187508/trained-gromit-carrier
    -- _spell.summon_pocopoc = "Summon Pocopoc"   
  
 --Heroic
    _spell.voidwraith = "Voidwraith"

 


--Priest all
    _spell.desperate_prayer = "Desperate Prayer"
    _spell.fade = "Fade"
    _spell.flash_heal = "Flash Heal"
    _spell.mindblast = "Mind Blast"
    _spell.levitate = "Levitate"
    _spell.mind_soothe = "Mind Soothe"
    _spell.fort = "Power Word: Fortitude"
    _spell.shield = "Power Word: Shield"
    _spell.psychic_scream = "Psychic Scream"
    _spell.shadow_word_pain = "Shadow Word: Pain"
            delphi.track_aura[_spell.shadow_word_pain] = {} -- unique(1)
    _spell.shadow_word_pain_tagging = "Shadow Word: Pain"
    _spell.res = "Resurrection"


--Priest Talents https://www.wowhead.com/guide/classes/priest/shadow/abilities-talents-pve-dps#priest-class-talents
    --Priest Row 1 Talents
    _spell.renew = "Renew"
    _spell.purge = "Dispel Magic"
    _spell.shadowfiend = "Shadowfiend"
    --Priest Row 2 Talents
    _spell.prayer_of_mending = "Prayer of Mending"
    _spell.purify_disease = "Purify Disease"
    _spell.shadow_word_death = "Shadow Word: Death"
    --Priest Row 3 Talents
    _spell.holy_nova = "Holy Nova"
    _spell.angelic_feather = "Angelic Feather"
    --Priest Row 4 Talents
    _spell.leap_of_faith = "Leap of Faith"
    _spell.shackle_undead = "Shackle Undead"
        delphi.track_aura[_spell.shackle_undead] = {} -- unique(1)
    _spell.void_tendrils  = "Void Tendrils"
    _spell.mind_control = "Mind Control"
    _spell.dominate_mind = "Dominate Mind"
    --Priest Row 5 Talents
    _spell.mass_dispel = "Mass Dispel"
    _spell.power_infusion = "Power Infusion"
    _spell.vampiric_embrace = "Vampiric Embrace"
    --Priest Row 6 Talents
    _spell.body_and_soul = "Body and Soul"
    --Priest Row 8 Talents
    _spell.divine_star = "Divine Star"
    _spell.halo = "Halo"
    _spell.mindgames = "Mindgames"
    --Priest Row 9 Talents
    _spell.surge_of_light = "Surge of Light"
    --Priest Row 10 Talents
    _spell.power_word_life = "Power Word: Life"
    _spell.void_shift = "Void Shift"






--Shadow 
    _spell.mind_flay = "Mind Flay"
    _spell.vampiric_touch = "Vampiric Touch"
        delphi.track_aura[_spell.vampiric_touch] = {} -- unique(1)
    _spell.shadowform = "Shadowform"
    _spell.void_bolt = "Void Bolt"
    --changes into void bolt

--Shadow Talents
    --Shadow Row 1 Talents
    _spell.devouring_plague = "Devouring Plague"
        delphi.track_aura[_spell.devouring_plague] = {} -- unique(1)
    --Shadow Row 2 Talents
    _spell.dispersion = "Dispersion"
    _spell.silence = "Silence"
    --Shadow Row 3 Talents
    _spell.dark_void = "Dark Void"
    _spell.psychic_horror = "Psychic Horror"
    --Shadow Row 4 Talents
    _spell.mind_sear = "Mind Sear"
    _spell.mind_spike = "Mind Spike"
    --Shadow Row 5 Talents
    _spell.dark_ascension = "Dark Ascension"
    _spell.void_eruption = "Void Eruption"
    _spell.unfurling_darkness = "Unfurling Darkness" --buff
    --Shadow Row 6 Talents
    _spell.shadow_crash = "Shadow Crash"
    _spell.mind_melt = "Mind Melt" --buff
    --Shadow Row 8 Talents
    _spell.mindbender = "Mindbender" --replaces shadow fiend
    _spell.void_torrent = "Void Torrent"
--Shadow PvP Talents
    _spell.psyfiend = "Psyfiend"
    _spell.thoughtsteal = "Thoughtsteal"
    _spell.thoughtsteal_damage_frost_shock = "Frost Shock"
    _spell.thoughtsteal_damage_vampiric_touch = "Vampiric Touch"
    _spell.thoughtsteal_damage_penance = "Penance"
    _spell.thoughtsteal_damage_singe_mana = "Singe Mana"
    _spell.thoughtsteal_damage_living_flame = "Living Flame"

    _spell.thoughtsteal_control_polymorph = "Polymorph"
        delphi.track_aura[_spell.thoughtsteal_control_polymorph] = {} -- unique(1)

    _spell.thoughtsteal_control_fear = "Fear"
        delphi.track_aura[_spell.thoughtsteal_control_fear] = {} -- unique(1)

    _spell.thoughtsteal_heal_rejuvenation = "Rejuvenation"
    _spell.thoughtsteal_heal_renewing_mist = "Renewing Mist"
    _spell.thoughtsteal_heal_renew = "Renew"
    _spell.thoughtsteal_heal_wild_heal = "Wild Heal"
    _spell.thoughtsteal_heal_penance = "Penance"

    _spell.thoughtsteal_utility_blessing_of_freedom = "Blessing of Freedom"
--removed
-- _spell.shadow_mend = "Shadow Mend"
--_spell.searing_nightmare = "Searing Nightmare"
-- _spell.mind_bomb = "Mind Bomb"
-- _spell.madness = "Surrender to Madness"
--_spell.damnation = "Damnation"

--Shadow Buffs
    _spell.dark_thought = "Dark Thought"


--Discipline 
    _spell.penance = "Penance"

--Discipline Talents
    --Discipline Row 1 Talents
    _spell.atonement = "Atonement"
        delphi.track_aura[_spell.atonement] = {} -- unique(1)
    --Discipline Row 2 Talents
    _spell.power_word_radiance = "Power Word: Radiance"
    _spell.pain_suppression = "Pain Suppression"
    --Discipline Row 3 Talents
    _spell.schism = "Schism"
    --Discipline Row 4 Talents
    -- _spell.power_word_solace = "Power Word: Solace"
    _spell.power_word_barrier = "Power Word: Barrier"
    _spell.luminous_barrier = "Luminous Barrier"
    --Discipline Row 5 Talents
    _spell.purge_the_wicked = "Purge the Wicked"
    _spell.rapture = "Rapture"
    --_spell.shadow_covenant = "Shadow Covenant"
    --Discipline Row 6 Talents
    --Discipline Row 7 Talents
    --Discipline Row 8 Talents
--    _spell.lights_wrath = "Light's Wrath"
    _spell.ultimate_penitence = "Ultimate Penitence"
    _spell.evangelism = "Evangelism"
    --_spell.mindbender = "Mindbender" --replaces shadow fiend (UNDER SHADOW TALENTS)
    --Discipline Row 9 Talents
    --Discipline Row 10 Talents

--Discipline PvP Talents
    _spell.archangel = "Archangel"
    _spell.dark_archangel = "Dark Archangel"
    _spell.inner_light = "Inner Light"
    _spell.inner_shadow = "Inner Shadow"
    --_spell.thoughtsteal = "Thoughtsteal" (UNDER SHADOW TALENTS)


--OLD and REMOVED Discipline Talents
--_spell.spirit_shell = "Spirit Shell"




--Holy
    _spell.smite = "Smite"
    _spell.circle_of_healing = "Circle of Healing"
    _spell.divine_hymn = "Divine Hymn"
    _spell.guardian_spirit = "Guardian Spirit"
    _spell.heal = "Heal"
    _spell.holy_fire = "Holy Fire"
    _spell.holy_word_chastise = "Holy Word: Chastise"
    _spell.holy_word_sanctify = "Holy Word: Sanctify"
    _spell.holy_word_serenity = "Holy Word: Serenity"
    _spell.prayer_of_healing = "Prayer of Healing"
    _spell.cleanse = "Purify"
    _spell.symbol_of_hope = "Symbol of Hope"
    _spell.mass_res = "Mass Resurrection"


--Holy Talents
--    _spell.shining_force = "Shining Force" --Talent
--    _spell.binding_heals = "Binding Heals"
    _spell.apotheosis = "Apotheosis"
    _spell.holy_word_salvation = "Holy Word: Salvation"
    _spell.prayer_circle = "Prayer Circle"
    _spell.lightwell = "Lightwell"


--Holy PvP Talents
    _spell.greater_heal = "Greater Heal"
    _spell.ray_of_hope = "Ray of Hope"
    _spell.holy_ward = "Holy Ward"
    _spell.divine_ascension = "Divine Ascension"
    _spell.spirit_of_the_redeemer = "Spirit of Redemption(PVP Talent)"

--Oracle Heroic Talents
    _spell.premonition_of_insight       = "Premonition of Insight"
    _spell.premonition_of_piety         = "Premonition of Piety"
    _spell.premonition_of_solace        = "Premonition of Solace"
    _spell.premonition_of_clairvoyance  = "Premonition of Clairvoyance"
    _spell.premonition                  = "Premonition"

    _spell.special_target_1               = "special_target_1"
    _spell.special_target_2               = "special_target_2"
    _spell.special_target_3               = "special_target_3"
    _spell.special_target_4               = "special_target_4"
    _spell.special_target_5               = "special_target_5"
    _spell.special_target_6               = "special_target_6"
    _spell.special_target_7               = "special_target_7"


_spell.targetenemy    = "targetenemy"

_spell.petattack        = "petattack"
_spell.changetarget     = "changetarget"
_spell.extra_action_button_1        = "ExtraActionButton1"
_spell.siren_isle_crawler_mine_attack     = "Command Mine"
_spell.siren_isle_crawler_mine_buff     = "Crawler Mine"


local discipline_spec   = 1
local holy_spec         = 2
local shadow_spec       = 3

-- function Botchuloz_SpecialDelegate(spell,unit) 
--     if UnitIsUnit(unit,"target") then
--         return 999
--     elseif UnitIsUnit(unit,"target") then
--         return 998
--     elseif UnitIsUnit(unit,"target") then
--         return 997
--     elseif UnitIsUnit(unit,"target") then
--         return 996
--     else
--         return 1
--     end
-- end



local bind_once = 0
function _priest.SetBinds()
    if bind_once > 0 then 
        return nil
    end
    bind_once = 1

    CreateIconAndButton("NUMPAD1",170+300,-150,"",2) -- MC
    CreateIconAndButton("NUMPAD2",210+300,-150,"",2) -- CD
    CreateIconAndButton("NUMPAD3",250+300,-150,"",2) --  healer or DPS
    
    CreateIconAndButton("NUMPAD4",170+300,-200,"",2) -- PvE or PvP
    CreateIconAndButton("NUMPAD5",210+300,-200,"",2) -- special
    CreateIconAndButton("NUMPAD6",250+300,-200,"",2) -- Heal or Heal attack
    
    -- CreateIconAndButton("NUMPAD0",170+300,-300,"",3)     -- (0=?,1=?,...,N=?)
    -- CreateIconAndButton("NUMPADMINUS",210+300,-300,"",3) -- (0=?,1=?,...,N=?)
    -- CreateIconAndButton("NUMPADPLUS",250+300,-300,"",3)  -- (0=?,1=?,...,N=?)
    BindSpellToUnits(_spell.levitate,                   _unitids.player)
    -- BindSpellToUnits(_spell.kyrian_steward,             _unitids.player)
    -- BindSpellToUnits(_spell.kyrian_boon,                _unitids.player)
    -- BindSpellToUnits(_spell.kyrian_nova,                _unitids.player)
    -- BindSpellToUnits(_spell.kyrian_phial,               _unitids.player)
    -- BindSpellToUnits(_spell.necrolord_fleshcraft,       _unitids.player)
    -- BindSpellToUnits(_spell.night_fae_soulshape,        _unitids.player)
    -- BindSpellToUnits(_spell.kyrian_blast,               _unitids.target)
    -- BindSpellToUnits(_spell.night_fae_fae_guardians,    _unitids.standard_friendly)
    BindSpellToUnits(_spell.trained_gromit_carrier,     _unitids.player)
    BindSpellToUnits(_spell.healthstone,                _unitids.player)
    BindSpellToUnits(_spell.desperate_prayer,           _unitids.player)
    -- BindSpellToUnits(_spell.renew,           _unitids.player)

--    BindSpellToUnits(_spell.purge,                      _unitids.target)
    BindSpellToUnits(_spell.fade,                       _unitids.player)
    BindSpellToUnits(_spell.fort,                       _unitids.player)
    BindSpellToUnits(_spell.psychic_scream,             _unitids.player) 
    BindSpellToUnits(_spell.mass_dispel,                _unitids.player)
    BindSpellToUnits(_spell.halo,                       _unitids.player)
    BindSpellToUnits(_spell.divine_star,                _unitids.player)
    BindSpellToUnits(_spell.angelic_feather,            _unitids.player)--,"/cast [@player]Angelic Feather","",1)
    BindSpellToUnits(_spell.shield,                     _unitids.player)
    BindSpellToUnits(_spell.void_tendrils,              _unitids.player)
    BindSpellToUnits(_spell.dominate_mind,              _unitids.focus)
    BindSpellToUnits(_spell.shadow_word_death,          _unitids.target)
    BindSpellToUnits(_spell.thoughtsteal,               _unitids.target)
    BindSpellToUnits(_spell.thoughtsteal,               _unitids.player)
    BindSpellToUnits(_spell.thoughtsteal,               _unitids.standard_friendly)

    -- BindSpellToUnits(_spell.thoughtsteal_heal_wild_heal,_unitids.player)

    -- BindSpellToUnits(_spell.thoughtsteal_damage,        _unitids.target,"/cast Frost Shock\n/cast Vampiric Touch\n/cast Singe Mana\n/cast Living Flame",nil,1) --\n/cast Penance
    -- BindSpellToUnits(_spell.thoughtsteal_control,       _unitids.target,"/cast Polymorph\n/cast Fear",nil,1)    
    -- BindSpellToUnits(_spell.thoughtsteal_heal,          _unitids.player,"/cast Rejuvenation\n/cast Renewing Mist\n/cast Wild Heal",nil,1) --\n/cast Renew
    -- BindSpellToUnits(_spell.thoughtsteal_utility,       _unitids.player,"/cast Blessing of Freedom",nil,1)

    -- BindSpellToUnits(_spell.thoughtsteal,               _unitids.standard_friendly)
-- ++++BindSpellToUnits(spell,units,prefix,suffix,skipcontents,DelegateMacroCreation)
    BindSpellToUnits(_spell.shackle_undead,             _unitids.arena_hostile)
--    BindSpellToUnits(_spell.mind_control,               _unitids.target)
    BindSpellToUnits(_spell.flash_heal,                 _unitids.player)
    BindSpellToUnits(_spell.flash_heal,                 _unitids.party)

--    BindSpellToUnits(_spell.res,                        _unitids.standard_friendly)
    -- BindSpellToUnits(_spell.power_infusion,             _unitids.standard_friendly)
    -- BindSpellToUnits(_spell.necrolord_unholy_nova,      _unitids.standard_hostile)
    -- BindSpellToUnits(_spell.venthyr_mindgames,          _unitids.standard_hostile)
    -- BindSpellToUnits(_spell.kyrian_blast,               _unitids.standard_hostile)
    -- BindSpellToUnits(_spell.venthyr_mindgames,          _unitids.target)
--    BindSpellToUnits(_spell.shadow_word_pain,           _unitids.standard_hostile)

-- BindSpellToUnits(_spell.special_target_1,          _unitids.target,"/cleartarget [dead][noharm]\n/targetenemy [nodead]\n/tar [harm,nodead] Nullbot","",1)
-- BindSpellToUnits(_spell.special_target_2,          _unitids.target,"/cleartarget [dead][noharm]\n/targetenemy [nodead]\n/tar [harm,nodead] Medbot","",1)
-- BindSpellToUnits(_spell.special_target_3,          _unitids.target,"/cleartarget [dead][noharm]\n/targetenemy [nodead]\n/tar [harm,nodead] Corrupted Machinist","",1)
-- BindSpellToUnits(_spell.special_target_4,          _unitids.target,"/cleartarget [dead][noharm]\n/targetenemy [nodead]\n/tar [harm,nodead] Malfunctioning Pylon","",1)
-- BindSpellToUnits(_spell.special_target_5,          _unitids.target,"/cleartarget [dead][noharm]\n/targetenemy [nodead]\n/tar [harm,nodead] Explosive Bomberbot","",1)
-- BindSpellToUnits(_spell.special_target_6,          _unitids.target,"/cleartarget [dead][noharm]\n/targetenemy [nodead]\n/tar [harm,nodead] Swarmbot","",1)
-- BindSpellToUnits(_spell.special_target_7,          _unitids.target,"/cleartarget [dead][noharm]\n/targetenemy [nodead]\n/tar [harm,nodead] Awakened Phalanx","",1)

--    BindSpellToUnits(_spell.cd_trinkets,          _unitids.target,"/use 13\n/use 14","",1)
--Shadowlands


--    BindSpellToUnits(_spell.shadow_word_pain,           _unitids.raid_hostile)
    --Shared Spells END


      --BindSpellToUnit (  spell,               unit,   prefix..unit..suffix,nil  ,_skipSpell)
  --BindMacroToUnits(  spell,               units,                prefix,suffix)
  --BindMacroToUnits(_spell.extra_action_button_1,      _unitids.target,"/click ExtraActionButton1 ","",1)  
  BindSpellToUnits(_spell.extra_action_button_1,      _unitids.player,"/click ExtraActionButton1")  

    BindMacroToUnits(_spell.petattack,                  _unitids.target,"/petattack [@","]")

    BindMacroToUnits(_spell.changetarget,               _unitids.standard_hostile,"/target [@","]")

    -- CreateButton("set_focus","Y","/focus")
    -- CreateButton("set_pet_target","F","/petattack")

    CreateNewLabel("class",750,-320,function() 
        --local total_melee_attackers, player_melee_attackers, tank_melee_attackers = DK_NearbyMeleeEnemies()
        local combat, time_in_combat, time_ooc, last_fight_duration = CombatStatus()
    
        result = 
        (combat and ("**COMBAT**\n"..math.floor(time_in_combat+0.5)) or " NOT in combat")..
        "\n"..
        "Plague : "..UniqueCountSpellInstances(_spell.devouring_plague,4).."\n".. -- technically, 30 is the duration of the buff, but if we haven't scourge striked in 10sec, we may as well pretend any existing wounds are lost / unable to be reached
        "SW:P  : "..UniqueCountSpellInstances(_spell.shadow_word_pain,4).."\n"..
        "VT    : "..UniqueCountSpellInstances(_spell.vampiric_touch,4).."\n"..
        ""
        
        return 0,result
    end)

    CreateNewLabel("Free Binds", 750, -350, function()
        local free_binds = FreeBindCount()
        local result = "Free binds: " .. free_binds
        return 0, result
    end)

    CreateNewLabel("Next Spell", 750, -380, function()
    if activespell then
        local result = "NEXT: " .. activespell.spell .. " -> " .. (activespell.unitname or "Unknown")
        return 0, result
    else
        return 0, "NEXT: None queued"
    end
end)


     --print("delphi.class.priest.SetPriestBinds()")
end

local ua_limit = 1

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

-- throttle timer for special cast
local special_stopwatch = 0


-- function PriestForm()
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

if special_action_last_time == nil then
    special_action_last_time = 0
end


local fallStartTime = nil
local lastGroundTime = nil
local jumpThreshold = 1.5  -- Time that we consider as a normal jump duration
local groundContactThreshold = 0.7  -- Minimum time on the ground to reset the fall state

function FallingStatus()
    if IsFalling() then
        if lastGroundTime and GetTime() - lastGroundTime < groundContactThreshold then
            -- Player hasn't been on the ground long enough, so ignore this "fall"
            return false
        end
        
        if not fallStartTime then
            fallStartTime = GetTime()  -- Record the time when the fall started
        elseif GetTime() - fallStartTime > 2 and GetTime() - fallStartTime > jumpThreshold then
            return true  -- Falling for more than 2 seconds and beyond the normal jump time
        end
    else
        -- Player is not falling, reset fallStartTime and update lastGroundTime
        if fallStartTime then
            lastGroundTime = GetTime()  -- Record when the player landed on the ground
            fallStartTime = nil
        end
    end
    
    return false  -- Not falling or falling for less than 2 seconds or just a brief airborne period
end


-- /run print(Botchuloz_40YardHostile("Mind Flay","target"))
function Botchuloz_RangeCheckHarm_40Yard(spell,unit)
    return SpellUnit_RangeCheck("Shadow Word: Pain",unit)
end

function Botchuloz_RangeCheckHarm_30Yard(spell,unit)
    return SpellUnit_RangeCheck("Dispel Magic",unit)
end


function SpellUnit_RangeCheckHelp_40Yard(spell,unit)
    return SpellUnit_RangeCheck("Power Word: Shield",unit)
end

function Botchuloz_HarmDelegateRank(spell,unit) 
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

function Botchuloz_HelpDelegateRank(spell,unit) 
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


function OOC_Rank(spell,unit)
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

function UnitsHealthDeficitDetail(threshold_health_percent, required_units, units_list)
    local count = 0
    units_list = units_list or _unitids.standard_friendly

    for i, unit in next, units_list do
        if delphi.unit[unit].friendly then
            local unit_health_deficit_percent = delphi.unit[unit].health.deficit_percent
            if unit_health_deficit_percent ~= nil and unit_health_deficit_percent >= threshold_health_percent then
                count = count + 1
            end
        end
    end

    return count >= required_units
end

function SpellUnit_PremonitionExpired(spell,unit)
    return SpellUnit_MyBuffExpired(_spell.premonition_of_insight,unit) and SpellUnit_MyBuffExpired(_spell.premonition_of_piety,unit) and SpellUnit_MyBuffExpired(_spell.premonition_of_solace,unit) and SpellUnit_MyBuffExpired(_spell.premonition_of_clairvoyance,unit)
end


function SpellUnit_WeakenedSoulExpired(spell,unit)
     return SpellUnit_MyDebuffExpired(_spell.weakened_soul,unit)
end

function Botchuloz_VT_or_SWP_Missing(spell,unit)
    return SpellUnit_MyDebuffExpired(_spell.shadow_word_pain,unit) or SpellUnit_MyDebuffExpired(_spell.vampiric_touch,unit)
end

function Botchuloz_VT_or_SWP_ExpiringUnder5_ButIsntExpired(spell,unit)
    return SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired(_spell.shadow_word_pain,unit) or SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired(_spell.vampiric_touch,unit)
end

function SpellUnit_PurgeTheWicked_and_SWP_Missing(spell,unit)
    return SpellUnit_MyDebuffExpired(_spell.purge_the_wicked,unit) and SpellUnit_MyDebuffExpired(_spell.shadow_word_pain,unit)
end

function SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired(spell,unit)
    return SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired(_spell.purge_the_wicked,unit) or SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired(_spell.shadow_word_pain,unit)
end

function Botchuloz_Inner_Light_Shadow_Missing(spell,unit)
    return SpellUnit_MyBuffExpired(_spell.inner_light,unit) and SpellUnit_MyBuffExpired(_spell.inner_shadow,unit)
end

-- Shackle Undead: Only works on Undead targets
function SpellUnit_IsUndead(spell, unit)
    return UnitCreatureType(unit) == "Undead"
end

-- Thoughtsteal: Only works on Humanoids with mana
function SpellUnit_IsHumanoidWithMana(spell, unit)
    return UnitCreatureType(unit) == "Humanoid" and UnitPowerType(unit) == 0 -- 0 is mana
end

-- Mind Control: Does not work on Demon, Mechanical, or Undead beings (but does work on players)
function SpellUnit_ValidMindControlTarget(spell, unit)
    local creatureType = UnitCreatureType(unit) or ""
    return creatureType ~= "Demon" and creatureType ~= "Mechanical" and creatureType ~= "Undead"
end

-- Dominate Mind: Does not work on Demon, Mechanical, Undead beings, or players
function SpellUnit_ValidDominateMindTarget(spell, unit)
    local creatureType = UnitCreatureType(unit) or ""
    local isPlayer = UnitIsPlayer(unit)
    return creatureType ~= "Demon" and creatureType ~= "Mechanical" and creatureType ~= "Undead" and not isPlayer
end

-- Polymorph: Only works on Beasts, Humanoids, and Critters
function SpellUnit_ValidPolymorphTarget(spell, unit)
    local creatureType = UnitCreatureType(unit) or ""
    return creatureType == "Beast" or creatureType == "Humanoid" or creatureType == "Critter"
end

-- Shackle Undead: Check if casting is permitted (Limit 1, recast only if under 2s remaining or no other target has it)
function SpellUnit_ShackleUndeadPermitted(spell, unit)
    return UniqueCountSpellPermitted(_spell.shackle_undead, unit, 1, 50, 2) -- Limit 1, duration 50s, clip threshold 2s
end

-- Fear: Check if casting is permitted (Limit 1, recast only if under 2s remaining or no other target has it)
function SpellUnit_FearPermitted(spell, unit)
    return UniqueCountSpellPermitted(_spell.thoughtsteal_control_fear, unit, 1, 60, 2) -- Limit 1, duration 1 min (60s), clip threshold 2s
end

-- Polymorph: Check if casting is permitted (Limit 1, recast only if under 2s remaining or no other target has it)
function SpellUnit_PolymorphPermitted(spell, unit)
    return UniqueCountSpellPermitted(_spell.thoughtsteal_control_polymorph, unit, 1, 60, 2) -- Limit 1, duration 1 min (60s), clip threshold 2s
end



local ThoughtstealSpellLookup = {
    [_spell.thoughtsteal_heal_rejuvenation] = {
        spellID = 774, -- Rejuvenation
        checkKnown = function()
            return IsSpellKnownOrOverridesKnown(774)
        end
    },
    [_spell.thoughtsteal_heal_renewing_mist] = {
        spellID = 115151, -- Renewing Mist
        checkKnown = function()
            return IsSpellKnownOrOverridesKnown(115151)
        end
    },
    [_spell.thoughtsteal_heal_renew] = {
        spellID = 139, -- Renew
        checkKnown = function()
            -- Only allow casting Renew if stolen and NOT in Discipline or Holy spec (i.e., IsPlayerSpell(139) is false)
            return IsSpellKnownOrOverridesKnown(139) and not IsPlayerSpell(139)
        end
    },
    [_spell.thoughtsteal_heal_wild_heal] = {
        spellID = 323712, -- Wild Heal
        checkKnown = function()
            return IsSpellKnownOrOverridesKnown(323712)
        end
    },
    [_spell.thoughtsteal_damage_frost_shock] = {
        spellID = 196840, -- Frost Shock
        checkKnown = function()
            return IsSpellKnownOrOverridesKnown(196840)
        end
    },
    [_spell.thoughtsteal_damage_vampiric_touch] = {
        spellID = 34914, -- Vampiric Touch
        checkKnown = function()
            -- Only allow casting Vampiric Touch if stolen and NOT in Shadow spec (i.e., IsPlayerSpell(34914) is false)
            return IsSpellKnownOrOverridesKnown(34914) and not IsPlayerSpell(34914)
        end
    },
    [_spell.thoughtsteal_damage_penance] = {
        spellID = 47540, -- Penance
        checkKnown = function()
            -- Only allow casting Penance if stolen and NOT in Discipline spec (i.e., IsPlayerSpell(47540) is false)
            return IsSpellKnownOrOverridesKnown(47540) and not IsPlayerSpell(47540)
        end
    },
    [_spell.thoughtsteal_damage_singe_mana] = {
        spellID = 322516, -- Singe Mana
        checkKnown = function()
            return IsSpellKnownOrOverridesKnown(322516)
        end
    },
    [_spell.thoughtsteal_damage_living_flame] = {
        spellID = 361469, -- Living Flame
        checkKnown = function()
            return IsSpellKnownOrOverridesKnown(361469)
        end
    },
    [_spell.thoughtsteal_control_polymorph] = {
        spellID = 118, -- Polymorph
        checkKnown = function()
            return IsSpellKnownOrOverridesKnown(118)
        end
    },
    [_spell.thoughtsteal_control_fear] = {
        spellID = 5782, -- Fear
        checkKnown = function()
            return IsSpellKnownOrOverridesKnown(5782)
        end
    },
    [_spell.thoughtsteal_utility_blessing_of_freedom] = {
        spellID = 1044, -- Blessing of Freedom
        checkKnown = function()
            return IsSpellKnownOrOverridesKnown(1044)
        end
    }
}



function ComprehensiveAPICheck(spellID)
    local spec = GetSpecialization()

    -- Start Message
    ChatFrame7:AddMessage("=== Comprehensive API Checks ===")

    local success, result

    success, result = pcall(C_Spell.DoesSpellExist, spellID)
    ChatFrame7:AddMessage("C_Spell.DoesSpellExist: " .. tostring(result))

    success, result = pcall(C_Spell.GetDeadlyDebuffInfo, spellID)
    ChatFrame7:AddMessage("C_Spell.GetDeadlyDebuffInfo: " .. tostring(result))

    success, result = pcall(C_Spell.GetMawPowerBorderAtlasBySpellID, spellID)
    ChatFrame7:AddMessage("C_Spell.GetMawPowerBorderAtlasBySpellID: " .. tostring(result))

    success, result = pcall(C_Spell.GetMawPowerLinkBySpellID, spellID)
    ChatFrame7:AddMessage("C_Spell.GetMawPowerLinkBySpellID: " .. tostring(result))

    success, result = pcall(C_Spell.GetOverrideSpell, spellID, spec, true, nil)
    ChatFrame7:AddMessage("C_Spell.GetOverrideSpell: " .. tostring(result))

    success, result = pcall(C_Spell.GetSchoolString, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSchoolString: " .. tostring(result))

    success, result = pcall(C_Spell.GetSpellAutoCast, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellAutoCast: " .. tostring(result))

    success, result = pcall(C_Spell.GetSpellCastCount, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellCastCount: " .. tostring(result))

    -- Charges (table)
    success, result = pcall(C_Spell.GetSpellCharges, spellID)
    if success and type(result) == "table" then
        ChatFrame7:AddMessage("C_Spell.GetSpellCharges: (table contents)")
        for key, value in pairs(result) do
            ChatFrame7:AddMessage("   " .. tostring(key) .. ": " .. tostring(value))
        end
    else
        ChatFrame7:AddMessage("C_Spell.GetSpellCharges: " .. tostring(result))
    end

    -- Cooldown (table)
    success, result = pcall(C_Spell.GetSpellCooldown, spellID)
    if success and type(result) == "table" then
        ChatFrame7:AddMessage("C_Spell.GetSpellCooldown: (table contents)")
        for key, value in pairs(result) do
            ChatFrame7:AddMessage("   " .. tostring(key) .. ": " .. tostring(value))
        end
    else
        ChatFrame7:AddMessage("C_Spell.GetSpellCooldown: " .. tostring(result))
    end

    success, result = pcall(C_Spell.GetSpellDescription, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellDescription: " .. tostring(result))

    success, result = pcall(C_Spell.GetSpellIDForSpellIdentifier, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellIDForSpellIdentifier: " .. tostring(result))

    -- Spell Info (table)
    success, result = pcall(C_Spell.GetSpellInfo, spellID)
    if success and type(result) == "table" then
        ChatFrame7:AddMessage("C_Spell.GetSpellInfo: (table contents)")
        for key, value in pairs(result) do
            ChatFrame7:AddMessage("   " .. tostring(key) .. ": " .. tostring(value))
        end
    else
        ChatFrame7:AddMessage("C_Spell.GetSpellInfo: " .. tostring(result))
    end

    success, result = pcall(C_Spell.GetSpellLevelLearned, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellLevelLearned: " .. tostring(result))

    success, result = pcall(C_Spell.GetSpellLink, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellLink: " .. tostring(result))

    success, locStart, locDuration = pcall(C_Spell.GetSpellLossOfControlCooldown, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellLossOfControlCooldown: Start: " .. tostring(locStart) .. ", Duration: " .. tostring(locDuration))

    success, result = pcall(C_Spell.GetSpellName, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellName: " .. tostring(result))

    -- Power Cost (table)
    success, result = pcall(C_Spell.GetSpellPowerCost, spellID)
    if success and type(result) == "table" then
        ChatFrame7:AddMessage("C_Spell.GetSpellPowerCost: (table contents)")
        for _, v in ipairs(result) do
            if type(v) == "table" then
                ChatFrame7:AddMessage("   Power Type: " .. tostring(v.name))
                for costKey, costValue in pairs(v) do
                    if costKey ~= "name" then
                        ChatFrame7:AddMessage("      " .. tostring(costKey) .. ": " .. tostring(costValue))
                    end
                end
            end
        end
    else
        ChatFrame7:AddMessage("C_Spell.GetSpellPowerCost: " .. tostring(result))
    end

    success, result = pcall(C_Spell.GetSpellQueueWindow)
    ChatFrame7:AddMessage("C_Spell.GetSpellQueueWindow: " .. tostring(result))

    success, result = pcall(C_Spell.GetSpellSkillLineAbilityRank, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellSkillLineAbilityRank: " .. tostring(result))

    success, result = pcall(C_Spell.GetSpellSubtext, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellSubtext: " .. tostring(result))

    success, result = pcall(C_Spell.GetSpellTexture, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellTexture: " .. tostring(result))

    success, result = pcall(C_Spell.GetSpellTradeSkillLink, spellID)
    ChatFrame7:AddMessage("C_Spell.GetSpellTradeSkillLink: " .. tostring(result))

    success, result = pcall(C_Spell.IsAutoAttackSpell, spellID)
    ChatFrame7:AddMessage("C_Spell.IsAutoAttackSpell: " .. tostring(result))

    success, result = pcall(C_Spell.IsAutoRepeatSpell, spellID)
    ChatFrame7:AddMessage("C_Spell.IsAutoRepeatSpell: " .. tostring(result))

    success, result = pcall(C_Spell.IsClassTalentSpell, spellID)
    ChatFrame7:AddMessage("C_Spell.IsClassTalentSpell: " .. tostring(result))

    success, result = pcall(C_Spell.IsCurrentSpell, spellID)
    ChatFrame7:AddMessage("C_Spell.IsCurrentSpell: " .. tostring(result))

    success, result = pcall(C_Spell.IsPressHoldReleaseSpell, spellID)
    ChatFrame7:AddMessage("C_Spell.IsPressHoldReleaseSpell: " .. tostring(result))

    success, result = pcall(C_Spell.IsPvPTalentSpell, spellID)
    ChatFrame7:AddMessage("C_Spell.IsPvPTalentSpell: " .. tostring(result))

    success, result = pcall(C_Spell.IsRangedAutoAttackSpell, spellID)
    ChatFrame7:AddMessage("C_Spell.IsRangedAutoAttackSpell: " .. tostring(result))

    success, result = pcall(C_Spell.IsSpellDataCached, spellID)
    ChatFrame7:AddMessage("C_Spell.IsSpellDataCached: " .. tostring(result))

    success, result = pcall(C_Spell.IsSpellDisabled, spellID)
    ChatFrame7:AddMessage("C_Spell.IsSpellDisabled: " .. tostring(result))

    success, result = pcall(C_Spell.IsSpellHarmful, spellID)
    ChatFrame7:AddMessage("C_Spell.IsSpellHarmful: " .. tostring(result))

    success, result = pcall(C_Spell.IsSpellHelpful, spellID)
    ChatFrame7:AddMessage("C_Spell.IsSpellHelpful: " .. tostring(result))

    success, result = pcall(C_Spell.IsSpellInRange, spellID, "target")
    ChatFrame7:AddMessage("C_Spell.IsSpellInRange: " .. tostring(result))

    success, result = pcall(C_Spell.IsSpellPassive, spellID)
    ChatFrame7:AddMessage("C_Spell.IsSpellPassive: " .. tostring(result))

    success, usable, insufficientPower = pcall(C_Spell.IsSpellUsable, spellID)
    ChatFrame7:AddMessage("C_Spell.IsSpellUsable: Usable: " .. tostring(usable) .. ", Insufficient Power: " .. tostring(insufficientPower))

    success, result = pcall(C_Spell.SpellHasRange, spellID)
    ChatFrame7:AddMessage("C_Spell.SpellHasRange: " .. tostring(result))

    success, result = pcall(C_Spell.TargetSpellIsEnchanting, spellID)
    ChatFrame7:AddMessage("C_Spell.TargetSpellIsEnchanting: " .. tostring(result))

    success, result = pcall(C_Spell.TargetSpellJumpsUpgradeTrack, spellID)
    ChatFrame7:AddMessage("C_Spell.TargetSpellJumpsUpgradeTrack: " .. tostring(result))

    success, result = pcall(C_Spell.TargetSpellReplacesBonusTree, spellID)
    ChatFrame7:AddMessage("C_Spell.TargetSpellReplacesBonusTree: " .. tostring(result))

    -- Add check for buff active on player
    success, result = pcall(C_UnitAuras.GetAuraDataBySpell, "player", spellID, "HELPFUL")
    if success and result then
        local remainingTime = result.expirationTime and (result.expirationTime - GetTime()) or "N/A"
        ChatFrame7:AddMessage("Buff Active on Player: Yes - Remaining: " .. tostring(remainingTime) .. " seconds")
    else
        ChatFrame7:AddMessage("Buff Active on Player: No")
    end

    -- End Message
    ChatFrame7:AddMessage("=== End of Comprehensive API Checks ===")
end



function ComprehensiveDebuffAPICheck(unit)
    local maxDebuffs = 40
    print("=== Comprehensive Debuff API Check for unit: " .. (unit or "Unknown") .. " ===")
    for i = 1, maxDebuffs do
        local debuffData = C_UnitAuras.GetDebuffDataByIndex(unit, i)
        if not debuffData then
            break
        end
        print(string.format("Debuff %d:", i))
        print("  Name: " .. (debuffData.name or "Unknown"))
        print("  Spell ID: " .. (debuffData.spellId or "Unknown"))
        print("  Icon: " .. (debuffData.icon or "Unknown"))
        print("  Duration: " .. (debuffData.duration or "Unknown"))
        print("  Expiration Time: " .. (debuffData.expirationTime or "Unknown"))
        print("  Source Unit: " .. (debuffData.sourceUnit or "Unknown"))
        print("  Is Harmful: " .. tostring(debuffData.isHarmful))
        print("  Is Stealable: " .. tostring(debuffData.isStealable))
        print("  Applications: " .. (debuffData.applications or 0))
        print("  Can Apply Aura: " .. tostring(debuffData.canApplyAura))
        print("  Is Boss Aura: " .. tostring(debuffData.isBossAura))
        print("  Is From Player or Pet: " .. tostring(debuffData.isFromPlayerOrPlayerPet))
        print("  Dispel Type: " .. (debuffData.dispelName or "None"))
        print("  Is Nameplate Only: " .. tostring(debuffData.isNameplateOnly))
        print("  Is Raid: " .. tostring(debuffData.isRaid))
        print("  Max Charges: " .. (debuffData.maxCharges or 0))
        print("  Charges: " .. (debuffData.charges or 0))
        print("  Time Modifier: " .. (debuffData.timeMod or 1))
        print("-----------------------------")
    end
    print("=== End of Debuff API Check ===")
end


function ComprehensiveBuffAPICheck(unit)
    local maxBuffs = 40
    print("=== Comprehensive Buff API Check for unit: " .. (unit or "Unknown") .. " ===")
    for i = 1, maxBuffs do
        local buffData = C_UnitAuras.GetBuffDataByIndex(unit, i)
        if not buffData then
            break
        end
        print(string.format("Buff %d:", i))
        print("  Name: " .. (buffData.name or "Unknown"))
        print("  Spell ID: " .. (buffData.spellId or "Unknown"))
        print("  Icon: " .. (buffData.icon or "Unknown"))
        print("  Duration: " .. (buffData.duration or "Unknown"))
        print("  Expiration Time: " .. (buffData.expirationTime or "Unknown"))
        print("  Source Unit: " .. (buffData.sourceUnit or "Unknown"))
        print("  Is Helpful: " .. tostring(buffData.isHelpful))
        print("  Is Stealable: " .. tostring(buffData.isStealable))
        print("  Applications: " .. (buffData.applications or 0))
        print("  Can Apply Aura: " .. tostring(buffData.canApplyAura))
        print("  Is Boss Aura: " .. tostring(buffData.isBossAura))
        print("  Is From Player or Pet: " .. tostring(buffData.isFromPlayerOrPlayerPet))
        print("  Dispel Type: " .. (buffData.dispelName or "None"))
        print("  Is Nameplate Only: " .. tostring(buffData.isNameplateOnly))
        print("  Is Raid: " .. tostring(buffData.isRaid))
        print("  Max Charges: " .. (buffData.maxCharges or 0))
        print("  Charges: " .. (buffData.charges or 0))
        print("  Time Modifier: " .. (buffData.timeMod or 1))
        print("-----------------------------")
    end
    print("=== End of Buff API Check ===")
end


function CheckPowerWordShieldOverride()
    local pwsSpellId = 17 -- Power Word: Shield spell ID
    print("=== Power Word: Shield Override Check ===")
    
    local overrideSpellId = C_Spell.GetOverrideSpell(pwsSpellId)
    if overrideSpellId and overrideSpellId ~= pwsSpellId then
        local originalInfo = C_Spell.GetSpellInfo(pwsSpellId)
        local overrideInfo = C_Spell.GetSpellInfo(overrideSpellId)
        print("Power Word: Shield IS OVERRIDDEN!")
        print("  Original: " .. (originalInfo and originalInfo.name or "Unknown") .. " (ID: " .. pwsSpellId .. ")")
        print("  Override: " .. (overrideInfo and overrideInfo.name or "Unknown") .. " (ID: " .. overrideSpellId .. ")")
        print("  Override Icon: " .. (overrideInfo and overrideInfo.iconID or "Unknown"))
        return overrideSpellId, overrideInfo
    else
        print("Power Word: Shield has NO override")
        return pwsSpellId, C_Spell.GetSpellInfo(pwsSpellId)
    end
end









function Atonement_Missing(spell,unit)
    return SpellUnit_MyBuffExpired(_spell.atonement,unit)
end

function SpellUnit_BreakingBuffsExpired(spell,unit) -- formerly SpellUnit_SpiritofRedemptionExpired
    return SpellUnit_BuffExpired("Spirit of Redemption","player") and SpellUnit_BuffExpired("Dispersion","player")
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

    function SpellUnit_SpeedBuffExpired(spell, unit)
        local hasBeenFallingTooLong = FallingStatus()  -- Check if the player has been falling for more than 2 seconds
    
        return _unit.player.buff["Angelic Feather"].remaining == 0 and 
               _unit.player.buff["Body and Soul"].remaining == 0 and 
               _unit.player.buff["Blaze of Light"].remaining == 0 and 
               _unit.player.buff["Mawrat Harness"].remaining == 0 and 
               _unit.player.buff["Stampeding Roar"].remaining == 0 and 
               _unit.player.buff["Stampeding Roar(Bear Form)"].remaining == 0 and 
               _unit.player.buff["Stampeding Roar(Cat Form)"].remaining == 0 and 
               _unit.player.buff["Unburden"].remaining == 0 and 
               not IsSwimming() and 
               not hasBeenFallingTooLong  -- Prevent return true if falling for more than 2 seconds
    end
    
    function angelic_feather_check()
        local isSwimming = IsSwimming()
        local levitateExpired = SpellUnit_BuffExpired("Levitate", "player")
        local divineAscensionExpired = SpellUnit_BuffExpired("Divine Ascension", "player")
        local slowFallExpired = SpellUnit_BuffExpired("Slow Fall", "player")
        local hasBeenFallingTooLong = FallingStatus()  -- Check if the player has been falling for more than 2 seconds
        
        -- Return true if the player is not swimming, Levitate and Slow Fall have expired, and they haven't been falling for more than 2 seconds
        return not isSwimming and levitateExpired and divineAscensionExpired and slowFallExpired and not hasBeenFallingTooLong
    end
    
    -- function healthstone_count()
    --     --https://www.wowhead.com/item=5512/healthstone
    --     local healthstone = 5512
    --     local healthstone_count = GetItemCount(healthstone)
    --     return healthstone_count
    -- end
    
    -- function healthstone_cooldown(itemID)
    --     local startTime,duration,enable = GetItemCooldown(5512)
    --     if enable == 1 and duration == 0 and SpellUnit_BreakingBuffsExpired then
    --         return 0
    --     else 
    --         return 1
    --    end
    -- end
        
    -- function phial_count()
    --     --https://www.wowhead.com/item=177278/phial-of-serenity
    --     local phial = 177278
    --     local phial_count = GetItemCount(phial)
    --     return phial_count
    -- end
    
    -- -- function phial_cooldown()
    -- --     return ItemCD(177278)
    -- -- end
    -- function phial_cooldown(itemID)
    --     local startTime,duration,enable = GetItemCooldown(177278)
    --     if enable == 1 and duration == 0 and SpellUnit_BreakingBuffsExpired then
    --         return 0
    --     else 
    --         return 1
    --    end
    -- end
    
    
    function healthstone_count()
        -- Returns the number of Healthstones in bags (excludes bank, charges, reagent bank)
        -- https://www.wowhead.com/item=5512/healthstone
        local itemID = 5512
        local count = C_Item.GetItemCount(itemID, false, false, false) or 0
        return count
    end

    function healthstone_cooldown()
        -- Returns 0 if Healthstone is off cooldown and usable, 1 otherwise
        -- https://www.wowhead.com/item=5512/healthstone
        local itemID = 5512
        local startTime, duration, enable = C_Container.GetItemCooldown(itemID)
        if enable == 1 and duration == 0 and SpellUnit_BreakingBuffsExpired() then
            return 0
        else
            return 1
        end
    end
        
    function phial_count()
        -- Returns the number of Phial of Serenity in bags (excludes bank, charges, reagent bank)
        -- https://www.wowhead.com/item=177278/phial-of-serenity
        local itemID = 177278
        local count = C_Item.GetItemCount(itemID, false, false, false) or 0
        return count
    end

    function phial_cooldown()
        -- Returns 0 if Phial of Serenity is off cooldown and usable, 1 otherwise
        -- https://www.wowhead.com/item=177278/phial-of-serenity
        local itemID = 177278
        local startTime, duration, enable = C_Container.GetItemCooldown(itemID)
        if enable == 1 and duration == 0 and SpellUnit_BreakingBuffsExpired() then
            return 0
        else
            return 1
        end
    end

    function has_trained_gromit_carrier_in_bags()
        -- Checks if Trained Gromit Carrier (ID 187508) is in your bags/equipped (not bank).
        -- https://www.wowhead.com/item=187508/trained-gromit-carrier
        local carrier_id = 187508
        -- Parameters: includeBank=false (excludes bank), includeCharges=false, includeReagentBank=false
        local count = C_Item.GetItemCount(carrier_id, false, false, false) or 0
        return count > 0  -- Returns true if at least one is in bags, false otherwise
    end

    
    function trained_gromit_carrier_cooldown()
        -- Returns 0 if Trained Gromit Carrier (ID 187508) is off cooldown and usable, 1 otherwise.
        -- https://www.wowhead.com/item=187508/trained-gromit-carrier
        local itemID = 187508
        local startTime, duration, enable = C_Container.GetItemCooldown(itemID)
        if enable == 1 and duration == 0 and SpellUnit_BreakingBuffsExpired() then
            return 0  -- Ready to use
        else
            return 1  -- On cooldown or not usable
        end
    end


function PriestMovementStatus()
    local moving,moving_for,stationary,stationary_for,speed = MovementStatus()
    if (_unit.player.buff["Surrender to Madness"].remaining > 0.3 or _unit.player.buff["Spatial Paradox"].remaining > 0.3 or _unit.player.buff["Molten Feather"].remaining > 0.3)  then
        stationary = true
        stationary_for = 20
        moving = false
        moving_for = 0
        speed = 0
    end
    return moving,moving_for,stationary,stationary_for,speed
end





local last_mounted = 0
function _priest.CoreLogic()
    local moving,moving_for,stationary,stationary_for,speed = PriestMovementStatus()
    local combat, time_in_combat, time_ooc, last_fight_duration = CombatStatus()

    local insanity        = delphi.resource.insanity
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
    local party1_health,party1_health_perc,party1_health_max     = UnitHealthInfo("party1")

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

    local special_off,special_on                      = BiStateCheck("NUMPAD5","!special","special")
    local regular_healer,attack_healer      = BiStateCheck("NUMPAD6","Heal","HealAttk")    
    
    -- local army_auto,army_force,army_off     = TriStateCheck("NUMPAD0","army+","army","!army")
    -- local army_auto,army_force,army_off     = TriStateCheck("NUMPADMINUS","army+","army","!army")
    -- local army_auto,army_force,army_off     = TriStateCheck("NUMPADPLUS","army+","army","!army")

--Archon Heroic Talents
--    local have_power_surge_talent = IsPlayerSpell(453109)                        -- https://www.wowhead.com/spell=453109/power-surge      /run print(IsPlayerSpell(453109))
--    local have_perfected_form_talent = IsPlayerSpell(453917)                        -- https://www.wowhead.com/spell=453917/perfected-form      /run print(IsPlayerSpell(453917))
--    local have_resonant_energy_talent = IsPlayerSpell(453845)                        -- https://www.wowhead.com/spell=453845/resonant-energy      /run print(IsPlayerSpell(453845))
--    local have_manifested_power_talent = IsPlayerSpell(453783)                        -- https://www.wowhead.com/spell=453783/manifested-power      /run print(IsPlayerSpell(453783))
--    local have_shock_pulse_talent = IsPlayerSpell(453852)                        -- https://www.wowhead.com/spell=453852/shock-pulse      /run print(IsPlayerSpell(453852))
--    local have_incessant_screams_talent = IsPlayerSpell(453918)                        -- https://www.wowhead.com/spell=453918/incessant-screams      /run print(IsPlayerSpell(453918))
--    local have_word_of_supremacy_talent = IsPlayerSpell(453726)                        -- https://www.wowhead.com/spell=453726/word-of-supremacy      /run print(IsPlayerSpell(453726))
--    local have_heightened_alteration_talent = IsPlayerSpell(453729)                        -- https://www.wowhead.com/spell=453729/heightened-alteration      /run print(IsPlayerSpell(453729))
--    local have_empowered_surges_talent = IsPlayerSpell(453799)                        -- https://www.wowhead.com/spell=453799/empowered-surges      /run print(IsPlayerSpell(453799))
--    local have_energy_compression_talent = IsPlayerSpell(449874)                        -- https://www.wowhead.com/spell=449874/energy-compression      /run print(IsPlayerSpell(449874))
--    local have_sustained_potency_talent = IsPlayerSpell(454001)                        -- https://www.wowhead.com/spell=454001/sustained-potency      /run print(IsPlayerSpell(454001))
--    local have_concentrated_infusion_talent = IsPlayerSpell(453844)                        -- https://www.wowhead.com/spell=453844/concentrated-infusion      /run print(IsPlayerSpell(453844))
--    local have_energy_cycle_talent = IsPlayerSpell(453828)                        -- https://www.wowhead.com/spell=453828/energy-cycle      /run print(IsPlayerSpell(453828))
--    local have_divine_halo_talent = IsPlayerSpell(449806)                        -- https://www.wowhead.com/spell=449806/divine-halo      /run print(IsPlayerSpell(449806))
--Oracle Heroic Talents
local have_premonition_talent = IsPlayerSpell(428924)                        -- https://www.wowhead.com/spell=428924/premonition      /run print(IsPlayerSpell(428924))
--    local have_preventive_measures_talent = IsPlayerSpell(440662)                        -- https://www.wowhead.com/spell=440662/preventive-measures      /run print(IsPlayerSpell(440662))
--    local have_preemptive_care_talent = IsPlayerSpell(440671)                        -- https://www.wowhead.com/spell=440671/preemptive-care      /run print(IsPlayerSpell(440671))
--    local have_waste_no_time_talent = IsPlayerSpell(440681)                        -- https://www.wowhead.com/spell=440681/waste-no-time      /run print(IsPlayerSpell(440681))
    local have_miraculous_recovery_talent = IsPlayerSpell(440674)                        -- https://www.wowhead.com/spell=440674/miraculous-recovery      /run print(IsPlayerSpell(440674))
--    local have_assured_safety_talent = IsPlayerSpell(440766)                        -- https://www.wowhead.com/spell=440766/assured-safety      /run print(IsPlayerSpell(440766))
--    local have_divine_feathers_talent = IsPlayerSpell(440670)                        -- https://www.wowhead.com/spell=440670/divine-feathers      /run print(IsPlayerSpell(440670))
--    local have_save_the_day_talent = IsPlayerSpell(440669)                        -- https://www.wowhead.com/spell=440669/save-the-day      /run print(IsPlayerSpell(440669))
--    local have_foreseen_circumstances_talent = IsPlayerSpell(440738)                        -- https://www.wowhead.com/spell=440738/foreseen-circumstances      /run print(IsPlayerSpell(440738))
--    local have_prophets_will_talent = IsPlayerSpell(433905)                        -- https://www.wowhead.com/spell=433905/prophets-will      /run print(IsPlayerSpell(433905))
--    local have_desperate_measures_talent = IsPlayerSpell(458718)                        -- https://www.wowhead.com/spell=458718/desperate-measures      /run print(IsPlayerSpell(458718))
--    local have_divine_providence_talent = IsPlayerSpell(440742)                        -- https://www.wowhead.com/spell=440742/divine-providence      /run print(IsPlayerSpell(440742))
--    local have_fatebender_talent = IsPlayerSpell(440743)                        -- https://www.wowhead.com/spell=440743/fatebender      /run print(IsPlayerSpell(440743))
--    local have_perfect_vision_talent = IsPlayerSpell(440661)                        -- https://www.wowhead.com/spell=440661/perfect-vision      /run print(IsPlayerSpell(440661))
--    local have_clairvoyance_talent = IsPlayerSpell(428940)                        -- https://www.wowhead.com/spell=428940/clairvoyance      /run print(IsPlayerSpell(428940))
--Voidweaver Heroic Talents
--    local have_entropic_rift_talent = IsPlayerSpell(447444)                        -- https://www.wowhead.com/spell=447444/entropic-rift      /run print(IsPlayerSpell(447444))
--    local have_no_escape_talent = IsPlayerSpell(451204)                        -- https://www.wowhead.com/spell=451204/no-escape      /run print(IsPlayerSpell(451204))
    local have_dark_energy_talent = IsPlayerSpell(451018)                        -- https://www.wowhead.com/spell=451018/dark-energy      /run print(IsPlayerSpell(451018))
    local have_void_blast_talent = IsPlayerSpell(450405)                        -- https://www.wowhead.com/spell=450405/void-blast      /run print(IsPlayerSpell(450405))
--    local have_inner_quietus_talent = IsPlayerSpell(448278)                        -- https://www.wowhead.com/spell=448278/inner-quietus      /run print(IsPlayerSpell(448278))
--    local have_devour_matter_talent = IsPlayerSpell(451840)                        -- https://www.wowhead.com/spell=451840/devour-matter      /run print(IsPlayerSpell(451840))
--    local have_void_empowerment_talent = IsPlayerSpell(450138)                        -- https://www.wowhead.com/spell=450138/void-empowerment      /run print(IsPlayerSpell(450138))
--    local have_darkening_horizon_talent = IsPlayerSpell(449912)                        -- https://www.wowhead.com/spell=449912/darkening-horizon      /run print(IsPlayerSpell(449912))
--    local have_depth_of_shadows_talent = IsPlayerSpell(451308)                        -- https://www.wowhead.com/spell=451308/depth-of-shadows      /run print(IsPlayerSpell(451308))
    local have_voidwraith_talent = IsPlayerSpell(451234)                        -- https://www.wowhead.com/spell=451234/voidwraith      /run print(IsPlayerSpell(451234))
--    local have_voidheart_talent = IsPlayerSpell(449880)                        -- https://www.wowhead.com/spell=449880/voidheart      /run print(IsPlayerSpell(449880))
--    local have_void_infusion_talent = IsPlayerSpell(450612)                        -- https://www.wowhead.com/spell=450612/void-infusion      /run print(IsPlayerSpell(450612))
--    local have_void_leech_talent = IsPlayerSpell(451311)                        -- https://www.wowhead.com/spell=451311/void-leech      /run print(IsPlayerSpell(451311))
--    local have_embrace_the_shadow_talent = IsPlayerSpell(451569)                        -- https://www.wowhead.com/spell=451569/embrace-the-shadow      /run print(IsPlayerSpell(451569))
--    local have_collapsing_void_talent = IsPlayerSpell(448403)                        -- https://www.wowhead.com/spell=448403/collapsing-void      /run print(IsPlayerSpell(448403))

--Priest Row 1 Talents
    local have_renew_talent = IsPlayerSpell(139)                        -- https://www.wowhead.com/spell=139/renew      /run print(IsPlayerSpell(139))
    local have_dispel_magic_talent = IsPlayerSpell(528)                        -- https://www.wowhead.com/spell=528/dispel-magic      /run print(IsPlayerSpell(528))
    local have_shadowfiend_talent = IsPlayerSpell(34433)                        -- https://www.wowhead.com/spell=34433/shadowfiend      /run print(IsPlayerSpell(34433))
--Priest Row 2 Talents
    local have_prayer_of_mending_talent = IsPlayerSpell(33076)                        -- https://www.wowhead.com/spell=33076/prayer-of-mending      /run print(IsPlayerSpell(33076))
--    local have_improved_flash_heal_talent = IsPlayerSpell(393870)                        -- https://www.wowhead.com/spell=393870/improved-flash-heal      /run print(IsPlayerSpell(393870))
--    local have_improved_purify_talent = IsPlayerSpell(390632)                        -- https://www.wowhead.com/spell=390632/improved-purify      /run print(IsPlayerSpell(390632))
    local have_purify_disease_talent = IsPlayerSpell(213634)                        -- https://www.wowhead.com/spell=213634/purify-disease      /run print(IsPlayerSpell(213634))
--    local have_psychic_voice_talent = IsPlayerSpell(196704)                        -- https://www.wowhead.com/spell=196704/psychic-voice      /run print(IsPlayerSpell(196704))
--    local have_petrifying_scream_talent = IsPlayerSpell(55676)                        -- https://www.wowhead.com/spell=55676/petrifying-scream      /run print(IsPlayerSpell(55676))
    local have_shadow_word_death_talent = IsPlayerSpell(32379)                        -- https://www.wowhead.com/spell=32379/shadow-word-death      /run print(IsPlayerSpell(32379))
--Priest Row 3 Talents
--    local have_focused_mending_talent = IsPlayerSpell(372354)                        -- https://www.wowhead.com/spell=372354/focused-mending      /run print(IsPlayerSpell(372354))
    local have_holy_nova_talent = IsPlayerSpell(132157)                        -- https://www.wowhead.com/spell=132157/holy-nova      /run print(IsPlayerSpell(132157))
--    local have_protective_light_talent = IsPlayerSpell(193063)                        -- https://www.wowhead.com/spell=193063/protective-light      /run print(IsPlayerSpell(193063))
    local have_from_darkness_comes_light_talent = IsPlayerSpell(390615)                        -- https://www.wowhead.com/spell=390615/from-darkness-comes-light      /run print(IsPlayerSpell(390615))
    local have_angelic_feather_talent = IsPlayerSpell(121536)                        -- https://www.wowhead.com/spell=121536/angelic-feather      /run print(IsPlayerSpell(121536))
    local have_phantasm_talent = IsPlayerSpell(108942)                        -- https://www.wowhead.com/spell=108942/phantasm      /run print(IsPlayerSpell(108942))
--    local have_death_and_madness_talent = IsPlayerSpell(321291)                        -- https://www.wowhead.com/spell=321291/death-and-madness      /run print(IsPlayerSpell(321291))
--Priest Row 4 Talents
--    local have_spell_warding_talent = IsPlayerSpell(390667)                        -- https://www.wowhead.com/spell=390667/spell-warding      /run print(IsPlayerSpell(390667))
--    local have_blessed_recovery_talent = IsPlayerSpell(390767)                        -- https://www.wowhead.com/spell=390767/blessed-recovery      /run print(IsPlayerSpell(390767))
    local have_rhapsody_talent = IsPlayerSpell(390622)                        -- https://www.wowhead.com/spell=390622/rhapsody      /run print(IsPlayerSpell(390622))
    local have_leap_of_faith_talent = IsPlayerSpell(73325)                        -- https://www.wowhead.com/spell=73325/leap-of-faith      /run print(IsPlayerSpell(73325))
    local have_shackle_undead_talent = IsPlayerSpell(9484)                        -- https://www.wowhead.com/spell=9484/shackle-undead      /run print(IsPlayerSpell(9484))
--    local have_sheer_terror_talent = IsPlayerSpell(390919)                        -- https://www.wowhead.com/spell=390919/sheer-terror      /run print(IsPlayerSpell(390919))
    local have_void_tendrils_talent = IsPlayerSpell(108920)                        -- https://www.wowhead.com/spell=108920/void-tendrils      /run print(IsPlayerSpell(108920))
    local have_mind_control_talent = IsPlayerSpell(605)                        -- https://www.wowhead.com/spell=605/mind-control      /run print(IsPlayerSpell(605))
    local have_dominate_mind_talent = IsPlayerSpell(205364)                        -- https://www.wowhead.com/spell=205364/dominate-mind      /run print(IsPlayerSpell(205364))
--Priest Row 5 Talents
--    local have_words_of_the_pious_talent = IsPlayerSpell(377438)                        -- https://www.wowhead.com/spell=377438/words-of-the-pious      /run print(IsPlayerSpell(377438))
    local have_mass_dispel_talent = IsPlayerSpell(32375)                        -- https://www.wowhead.com/spell=32375/mass-dispel      /run print(IsPlayerSpell(32375))
--    local have_move_with_grace_talent = IsPlayerSpell(390620)                        -- https://www.wowhead.com/spell=390620/move-with-grace      /run print(IsPlayerSpell(390620))
    local have_power_infusion_talent = IsPlayerSpell(10060)                        -- https://www.wowhead.com/spell=10060/power-infusion      /run print(IsPlayerSpell(10060))
--    local have_sanguine_teachings_talent = IsPlayerSpell(373218)                        -- https://www.wowhead.com/spell=373218/sanguine-teachings      /run print(IsPlayerSpell(373218))
    local have_vampiric_embrace_talent = IsPlayerSpell(15286)                        -- https://www.wowhead.com/spell=15286/vampiric-embrace      /run print(IsPlayerSpell(15286))
--    local have_tithe_evasion_talent = IsPlayerSpell(373223)                        -- https://www.wowhead.com/spell=373223/tithe-evasion      /run print(IsPlayerSpell(373223))
--Priest Row 6 Talents
--    local have_inspiration_talent = IsPlayerSpell(390676)                        -- https://www.wowhead.com/spell=390676/inspiration      /run print(IsPlayerSpell(390676))
--    local have_mental_agility_talent = IsPlayerSpell(341167)                        -- https://www.wowhead.com/spell=341167/mental-agility      /run print(IsPlayerSpell(341167))
    local have_body_and_soul_talent = IsPlayerSpell(64129)                        -- https://www.wowhead.com/spell=64129/body-and-soul      /run print(IsPlayerSpell(64129))
    local have_twins_of_the_sun_priestess_talent = IsPlayerSpell(373466)                        -- https://www.wowhead.com/spell=373466/twins-of-the-sun-priestess      /run print(IsPlayerSpell(373466))
--    local have_void_shield_talent = IsPlayerSpell(280749)                        -- https://www.wowhead.com/spell=280749/void-shield      /run print(IsPlayerSpell(280749))
--    local have_sanlayn_talent = IsPlayerSpell(199855)                        -- https://www.wowhead.com/spell=199855/sanlayn      /run print(IsPlayerSpell(199855))
--    local have_apathy_talent = IsPlayerSpell(390668)                        -- https://www.wowhead.com/spell=390668/apathy      /run print(IsPlayerSpell(390668))
--Priest Row 7 Talents
--    local have_unwavering_will_talent = IsPlayerSpell(373456)                        -- https://www.wowhead.com/spell=373456/unwavering-will      /run print(IsPlayerSpell(373456))
--    local have_twist_of_fate_talent = IsPlayerSpell(390972)                        -- https://www.wowhead.com/spell=390972/twist-of-fate      /run print(IsPlayerSpell(390972))
--    local have_throes_of_pain_talent = IsPlayerSpell(377422)                        -- https://www.wowhead.com/spell=377422/throes-of-pain      /run print(IsPlayerSpell(377422))
--Priest Row 8 Talents
--    local have_angels_mercy_talent = IsPlayerSpell(238100)                        -- https://www.wowhead.com/spell=238100/angels-mercy      /run print(IsPlayerSpell(238100))
    local have_binding_heals_talent = IsPlayerSpell(368275)                        -- https://www.wowhead.com/spell=368275/binding-heals      /run print(IsPlayerSpell(368275))
--    local have_translucent_image_talent = IsPlayerSpell(373446)                        -- https://www.wowhead.com/spell=373446/translucent-image      /run print(IsPlayerSpell(373446))
    local have_cauterizing_shadows_talent = IsPlayerSpell(459990)                        -- https://www.wowhead.com/spell=459990/cauterizing-shadows      /run print(IsPlayerSpell(459990))
--Priest Row 8 Talents Shadow
    local have_divine_star_shadow_talent = IsPlayerSpell(122121)                        -- https://www.wowhead.com/spell=122121/divine-star-shadow      /run print(IsPlayerSpell(122121))
    local have_halo_shadow_talent = IsPlayerSpell(120644)                        -- https://www.wowhead.com/spell=120644/halo-shadow      /run print(IsPlayerSpell(120644))
--Priest Row 8 Talents Holy Disc
    local have_divine_star_holy_disc_talent = IsPlayerSpell(110744)                        -- https://www.wowhead.com/spell=110744/divine-star-holy-disc      /run print(IsPlayerSpell(110744))
    local have_halo_holy_disc_talent = IsPlayerSpell(120517)                        -- https://www.wowhead.com/spell=120517/halo-holy-disc      /run print(IsPlayerSpell(120517))
--Priest Row 9 Talents
    local have_surge_of_light_talent = IsPlayerSpell(109186)                        -- https://www.wowhead.com/spell=109186/surge-of-light      /run print(IsPlayerSpell(109186))
--    local have_lights_inspiration_talent = IsPlayerSpell(373450)                        -- https://www.wowhead.com/spell=373450/lights-inspiration      /run print(IsPlayerSpell(373450))
--    local have_crystalline_reflection_talent = IsPlayerSpell(373457)                        -- https://www.wowhead.com/spell=373457/crystalline-reflection      /run print(IsPlayerSpell(373457))
--    local have_improved_fade_talent = IsPlayerSpell(390670)                        -- https://www.wowhead.com/spell=390670/improved-fade      /run print(IsPlayerSpell(390670))
--    local have_manipulation_talent = IsPlayerSpell(459985)                        -- https://www.wowhead.com/spell=459985/manipulation      /run print(IsPlayerSpell(459985))
--Priest Row 10 Talents
--    local have_benevolence_talent = IsPlayerSpell(415416)                        -- https://www.wowhead.com/spell=415416/benevolence      /run print(IsPlayerSpell(415416))
    local have_power_word_life_talent = IsPlayerSpell(373481)                        -- https://www.wowhead.com/spell=373481/power-word-life      /run print(IsPlayerSpell(373481))
--    local have_angelic_bulwark_talent = IsPlayerSpell(108945)                        -- https://www.wowhead.com/spell=108945/angelic-bulwark      /run print(IsPlayerSpell(108945))
--    local have_essence_devourer_talent = IsPlayerSpell(415479)                        -- https://www.wowhead.com/spell=415479/essence-devourer      /run print(IsPlayerSpell(415479))
    local have_void_shift_talent = IsPlayerSpell(108968)                        -- https://www.wowhead.com/spell=108968/void-shift      /run print(IsPlayerSpell(108968))
--    local have_phantom_reach_talent = IsPlayerSpell(459559)                        -- https://www.wowhead.com/spell=459559/phantom-reach      /run print(IsPlayerSpell(459559))

--Shadow Row 1 Talents
--    local have_devouring_plague_talent = IsPlayerSpell(335467)                        -- https://www.wowhead.com/spell=335467/devouring-plague      /run print(IsPlayerSpell(335467))
--Shadow Row 2 Talents
    local have_dispersion_talent = IsPlayerSpell(47585)                        -- https://www.wowhead.com/spell=47585/dispersion      /run print(IsPlayerSpell(47585))
--    local have_shadowy_apparitions_talent = IsPlayerSpell(341491)                        -- https://www.wowhead.com/spell=341491/shadowy-apparitions      /run print(IsPlayerSpell(341491))
    local have_silence_talent = IsPlayerSpell(15487)                        -- https://www.wowhead.com/spell=15487/silence      /run print(IsPlayerSpell(15487))
--Shadow Row 3 Talents
--    local have_intangibility_talent = IsPlayerSpell(288733)                        -- https://www.wowhead.com/spell=288733/intangibility      /run print(IsPlayerSpell(288733))
--    local have_mental_fortitude_talent = IsPlayerSpell(377065)                        -- https://www.wowhead.com/spell=377065/mental-fortitude      /run print(IsPlayerSpell(377065))
    local have_misery_talent = IsPlayerSpell(238558)                        -- https://www.wowhead.com/spell=238558/misery      /run print(IsPlayerSpell(238558))
--    local have_last_word_talent = IsPlayerSpell(263716)                        -- https://www.wowhead.com/spell=263716/last-word      /run print(IsPlayerSpell(263716))
    local have_psychic_horror_talent = IsPlayerSpell(64044)                        -- https://www.wowhead.com/spell=64044/psychic-horror      /run print(IsPlayerSpell(64044))
--Shadow Row 4 Talents
    local have_thought_harvester_talent = IsPlayerSpell(406788)                        -- https://www.wowhead.com/spell=406788/thought-harvester      /run print(IsPlayerSpell(406788))
--    local have_psychic_link_talent = IsPlayerSpell(199484)                        -- https://www.wowhead.com/spell=199484/psychic-link      /run print(IsPlayerSpell(199484))
    local have_surge_of_insanity_talent = IsPlayerSpell(391399)                        -- https://www.wowhead.com/spell=391399/surge-of-insanity      /run print(IsPlayerSpell(391399))
--Shadow Row 5 Talents
    local have_shadow_crash_targeted_talent = IsPlayerSpell(457042)                        -- https://www.wowhead.com/spell=457042/shadow-crash-targeted      /run print(IsPlayerSpell(457042))
    local have_shadow_crash_placed_talent = IsPlayerSpell(205385)                        -- https://www.wowhead.com/spell=205385/shadow-crash-placed      /run print(IsPlayerSpell(205385))
    local have_unfurling_darkness_talent = IsPlayerSpell(341273)                        -- https://www.wowhead.com/spell=341273/unfurling-darkness      /run print(IsPlayerSpell(341273))
    local have_dark_ascension_talent = IsPlayerSpell(391109)                        -- https://www.wowhead.com/spell=391109/dark-ascension      /run print(IsPlayerSpell(391109))
    local have_void_eruption_talent = IsPlayerSpell(228260)                        -- https://www.wowhead.com/spell=228260/void-eruption      /run print(IsPlayerSpell(228260))
--    local have_mental_decay_talent = IsPlayerSpell(375994)                        -- https://www.wowhead.com/spell=375994/mental-decay      /run print(IsPlayerSpell(375994))
    local have_mind_spike_talent = IsPlayerSpell(73510)                        -- https://www.wowhead.com/spell=73510/mind-spike      /run print(IsPlayerSpell(73510))
--Shadow Row 6 Talents
--    local have_whispering_shadows_talent = IsPlayerSpell(406777)                        -- https://www.wowhead.com/spell=406777/whispering-shadows      /run print(IsPlayerSpell(406777))
    local have_shadowy_insight_talent = IsPlayerSpell(375888)                        -- https://www.wowhead.com/spell=375888/shadowy-insight      /run print(IsPlayerSpell(375888))
--    local have_ancient_madness_talent = IsPlayerSpell(341240)                        -- https://www.wowhead.com/spell=341240/ancient-madness      /run print(IsPlayerSpell(341240))
--    local have_voidtouched_talent = IsPlayerSpell(407430)                        -- https://www.wowhead.com/spell=407430/voidtouched      /run print(IsPlayerSpell(407430))
--    local have_mind_melt_talent = IsPlayerSpell(391090)                        -- https://www.wowhead.com/spell=391090/mind-melt      /run print(IsPlayerSpell(391090))
--Shadow Row 7 Talents
--    local have_maddening_touch_talent = IsPlayerSpell(391228)                        -- https://www.wowhead.com/spell=391228/maddening-touch      /run print(IsPlayerSpell(391228))
--    local have_dark_evangelism_talent = IsPlayerSpell(391095)                        -- https://www.wowhead.com/spell=391095/dark-evangelism      /run print(IsPlayerSpell(391095))
--    local have_mind_devourer_talent = IsPlayerSpell(373202)                        -- https://www.wowhead.com/spell=373202/mind-devourer      /run print(IsPlayerSpell(373202))
--    local have_phantasmal_pathogen_talent = IsPlayerSpell(407469)                        -- https://www.wowhead.com/spell=407469/phantasmal-pathogen      /run print(IsPlayerSpell(407469))
    local have_minds_eye_talent = IsPlayerSpell(407470)                        -- https://www.wowhead.com/spell=407470/minds-eye      /run print(IsPlayerSpell(407470))
    local have_distorted_reality_talent = IsPlayerSpell(409044)                        -- https://www.wowhead.com/spell=409044/distorted-reality      /run print(IsPlayerSpell(409044))
--Shadow Row 8 Talents
    local have_mindbender_shadow_talent = IsPlayerSpell(200174)                        -- https://www.wowhead.com/spell=200174/mindbender-shadow      /run print(IsPlayerSpell(200174))
    local have_deathspeaker_talent = IsPlayerSpell(392507)                        -- https://www.wowhead.com/spell=392507/deathspeaker      /run print(IsPlayerSpell(392507))
--    local have_auspicious_spirits_talent = IsPlayerSpell(155271)                        -- https://www.wowhead.com/spell=155271/auspicious-spirits      /run print(IsPlayerSpell(155271))
    local have_void_torrent_talent = IsPlayerSpell(263165)                        -- https://www.wowhead.com/spell=263165/void-torrent      /run print(IsPlayerSpell(263165))
--Shadow Row 9 Talents
--    local have_inescapable_torment_talent = IsPlayerSpell(373427)                        -- https://www.wowhead.com/spell=373427/inescapable-torment      /run print(IsPlayerSpell(373427))
--    local have_mastermind_talent = IsPlayerSpell(391151)                        -- https://www.wowhead.com/spell=391151/mastermind      /run print(IsPlayerSpell(391151))
--    local have_screams_of_the_void_talent = IsPlayerSpell(375767)                        -- https://www.wowhead.com/spell=375767/screams-of-the-void      /run print(IsPlayerSpell(375767))
--    local have_tormented_spirits_talent = IsPlayerSpell(391284)                        -- https://www.wowhead.com/spell=391284/tormented-spirits      /run print(IsPlayerSpell(391284))
--    local have_insidious_ire_talent = IsPlayerSpell(373212)                        -- https://www.wowhead.com/spell=373212/insidious-ire      /run print(IsPlayerSpell(373212))
--    local have_malediction_talent = IsPlayerSpell(373221)                        -- https://www.wowhead.com/spell=373221/malediction      /run print(IsPlayerSpell(373221))
--Shadow Row 10 Talents
--    local have_idol_of_yshaarj_talent = IsPlayerSpell(373310)                        -- https://www.wowhead.com/spell=373310/idol-of-yshaarj      /run print(IsPlayerSpell(373310))
--    local have_idol_of_nzoth_talent = IsPlayerSpell(373280)                        -- https://www.wowhead.com/spell=373280/idol-of-nzoth      /run print(IsPlayerSpell(373280))
--    local have_idol_of_yogg_saron_talent = IsPlayerSpell(373273)                        -- https://www.wowhead.com/spell=373273/idol-of-yogg-saron      /run print(IsPlayerSpell(373273))
--    local have_idol_of_cthun_talent = IsPlayerSpell(377349)                        -- https://www.wowhead.com/spell=377349/idol-of-cthun      /run print(IsPlayerSpell(377349))

--Holy Row 1 Talents
--    local have_holy_word_serenity_talent = IsPlayerSpell(2050)                        -- https://www.wowhead.com/spell=2050/holy-word-serenity      /run print(IsPlayerSpell(2050))
--Holy Row 2 Talents
    local have_holy_word_sanctify_talent = IsPlayerSpell(34861)                        -- https://www.wowhead.com/spell=34861/holy-word-sanctify      /run print(IsPlayerSpell(34861))
    local have_guardian_spirit_talent = IsPlayerSpell(47788)                        -- https://www.wowhead.com/spell=47788/guardian-spirit      /run print(IsPlayerSpell(47788))
    local have_holy_word_chastise_talent = IsPlayerSpell(88625)                        -- https://www.wowhead.com/spell=88625/holy-word-chastise      /run print(IsPlayerSpell(88625))
--Holy Row 3 Talents
    local have_prayer_of_healing_talent = IsPlayerSpell(596)                        -- https://www.wowhead.com/spell=596/prayer-of-healing      /run print(IsPlayerSpell(596))
--    local have_guardian_angel_talent = IsPlayerSpell(200209)                        -- https://www.wowhead.com/spell=200209/guardian-angel      /run print(IsPlayerSpell(200209))
    local have_guardians_of_the_light_talent = IsPlayerSpell(196437)                        -- https://www.wowhead.com/spell=196437/guardians-of-the-light      /run print(IsPlayerSpell(196437))
--    local have_censure_talent = IsPlayerSpell(200199)                        -- https://www.wowhead.com/spell=200199/censure      /run print(IsPlayerSpell(200199))
--    local have_empyreal_blaze_talent = IsPlayerSpell(372616)                        -- https://www.wowhead.com/spell=372616/empyreal-blaze      /run print(IsPlayerSpell(372616))
--Holy Row 4 Talents
    local have_circle_of_healing_talent = IsPlayerSpell(204883)                        -- https://www.wowhead.com/spell=204883/circle-of-healing      /run print(IsPlayerSpell(204883))
--    local have_revitalizing_prayers_talent = IsPlayerSpell(391208)                        -- https://www.wowhead.com/spell=391208/revitalizing-prayers      /run print(IsPlayerSpell(391208))
--    local have_sanctified_prayers_talent = IsPlayerSpell(196489)                        -- https://www.wowhead.com/spell=196489/sanctified-prayers      /run print(IsPlayerSpell(196489))
--    local have_cosmic_ripple_talent = IsPlayerSpell(238136)                        -- https://www.wowhead.com/spell=238136/cosmic-ripple      /run print(IsPlayerSpell(238136))
    local have_afterlife_talent = IsPlayerSpell(196707)                        -- https://www.wowhead.com/spell=196707/afterlife      /run print(IsPlayerSpell(196707))
--    local have_renewed_faith_talent = IsPlayerSpell(341997)                        -- https://www.wowhead.com/spell=341997/renewed-faith      /run print(IsPlayerSpell(341997))
--    local have_burning_vehemence_talent = IsPlayerSpell(372307)                        -- https://www.wowhead.com/spell=372307/burning-vehemence      /run print(IsPlayerSpell(372307))
--Holy Row 5 Talents
--    local have_prayer_circle_talent = IsPlayerSpell(321377)                        -- https://www.wowhead.com/spell=321377/prayer-circle      /run print(IsPlayerSpell(321377))
--    local have_healing_chorus_talent = IsPlayerSpell(390881)                        -- https://www.wowhead.com/spell=390881/healing-chorus      /run print(IsPlayerSpell(390881))
--    local have_prayerful_litany_talent = IsPlayerSpell(391209)                        -- https://www.wowhead.com/spell=391209/prayerful-litany      /run print(IsPlayerSpell(391209))
--    local have_trail_of_light_talent = IsPlayerSpell(200128)                        -- https://www.wowhead.com/spell=200128/trail-of-light      /run print(IsPlayerSpell(200128))
    local have_divine_hymn_talent = IsPlayerSpell(64843)                        -- https://www.wowhead.com/spell=64843/divine-hymn      /run print(IsPlayerSpell(64843))
--    local have_enlightenment_talent = IsPlayerSpell(193155)                        -- https://www.wowhead.com/spell=193155/enlightenment      /run print(IsPlayerSpell(193155))
--    local have_benediction_talent = IsPlayerSpell(193157)                        -- https://www.wowhead.com/spell=193157/benediction      /run print(IsPlayerSpell(193157))
--    local have_holy_mending_talent = IsPlayerSpell(391154)                        -- https://www.wowhead.com/spell=391154/holy-mending      /run print(IsPlayerSpell(391154))
--Holy Row 6 Talents
--    local have_orison_talent = IsPlayerSpell(390947)                        -- https://www.wowhead.com/spell=390947/orison      /run print(IsPlayerSpell(390947))
--    local have_everlasting_light_talent = IsPlayerSpell(391161)                        -- https://www.wowhead.com/spell=391161/everlasting-light      /run print(IsPlayerSpell(391161))
--    local have_gales_of_song_talent = IsPlayerSpell(372370)                        -- https://www.wowhead.com/spell=372370/gales-of-song      /run print(IsPlayerSpell(372370))
    local have_symbol_of_hope_talent = IsPlayerSpell(64901)                        -- https://www.wowhead.com/spell=64901/symbol-of-hope      /run print(IsPlayerSpell(64901))
--    local have_divine_service_talent = IsPlayerSpell(391233)                        -- https://www.wowhead.com/spell=391233/divine-service      /run print(IsPlayerSpell(391233))
--Holy Row 7 Talents
--    local have_crisis_management_talent = IsPlayerSpell(390954)                        -- https://www.wowhead.com/spell=390954/crisis-management      /run print(IsPlayerSpell(390954))
--    local have_prismatic_echoes_talent = IsPlayerSpell(390967)                        -- https://www.wowhead.com/spell=390967/prismatic-echoes      /run print(IsPlayerSpell(390967))
--    local have_prayers_of_the_virtuous_talent = IsPlayerSpell(390977)                        -- https://www.wowhead.com/spell=390977/prayers-of-the-virtuous      /run print(IsPlayerSpell(390977))
--Holy Row 8 Talents
--    local have_pontifex_talent = IsPlayerSpell(390980)                        -- https://www.wowhead.com/spell=390980/pontifex      /run print(IsPlayerSpell(390980))
    local have_apotheosis_talent = IsPlayerSpell(200183)                        -- https://www.wowhead.com/spell=200183/apotheosis      /run print(IsPlayerSpell(200183))
    local have_holy_word_salvation_talent = IsPlayerSpell(265202)                        -- https://www.wowhead.com/spell=265202/holy-word-salvation      /run print(IsPlayerSpell(265202))
--    local have_miracle_worker_talent = IsPlayerSpell(235587)                        -- https://www.wowhead.com/spell=235587/miracle-worker      /run print(IsPlayerSpell(235587))
--    local have_say_your_prayers_talent = IsPlayerSpell(391186)                        -- https://www.wowhead.com/spell=391186/say-your-prayers      /run print(IsPlayerSpell(391186))
--Holy Row 9 Talents
--    local have_resonant_words_talent = IsPlayerSpell(372309)                        -- https://www.wowhead.com/spell=372309/resonant-words      /run print(IsPlayerSpell(372309))
--    local have_light_of_the_naaru_talent = IsPlayerSpell(196985)                        -- https://www.wowhead.com/spell=196985/light-of-the-naaru      /run print(IsPlayerSpell(196985))
--    local have_answered_prayers_talent = IsPlayerSpell(391387)                        -- https://www.wowhead.com/spell=391387/answered-prayers      /run print(IsPlayerSpell(391387))
--    local have_voice_of_harmony_talent = IsPlayerSpell(390994)                        -- https://www.wowhead.com/spell=390994/voice-of-harmony      /run print(IsPlayerSpell(390994))
--    local have_desperate_times_talent = IsPlayerSpell(391381)                        -- https://www.wowhead.com/spell=391381/desperate-times      /run print(IsPlayerSpell(391381))
--    local have_epiphany_talent = IsPlayerSpell(414553)                        -- https://www.wowhead.com/spell=414553/epiphany      /run print(IsPlayerSpell(414553))
--Holy Row 10 Talents
--    local have_lightweaver_talent = IsPlayerSpell(390992)                        -- https://www.wowhead.com/spell=390992/lightweaver      /run print(IsPlayerSpell(390992))
    local have_lightwell_talent = IsPlayerSpell(372835)                        -- https://www.wowhead.com/spell=372835/lightwell      /run print(IsPlayerSpell(372835))
--    local have_divine_image_talent = IsPlayerSpell(392988)                        -- https://www.wowhead.com/spell=392988/divine-image      /run print(IsPlayerSpell(392988))
--    local have_restitution_talent = IsPlayerSpell(391124)                        -- https://www.wowhead.com/spell=391124/restitution      /run print(IsPlayerSpell(391124))
    local have_divine_word_talent = IsPlayerSpell(372760)                        -- https://www.wowhead.com/spell=372760/divine-word      /run print(IsPlayerSpell(372760))

--Discipline Row 1 Talents
--    local have_atonement_talent = IsPlayerSpell(81749)                        -- https://www.wowhead.com/spell=81749/atonement      /run print(IsPlayerSpell(81749))
--Discipline Row 2 Talents
    local have_power_word_radiance_talent = IsPlayerSpell(194509)                        -- https://www.wowhead.com/spell=194509/power-word-radiance      /run print(IsPlayerSpell(194509))
    local have_pain_suppression_talent = IsPlayerSpell(33206)                        -- https://www.wowhead.com/spell=33206/pain-suppression      /run print(IsPlayerSpell(33206))
--    local have_power_of_the_dark_side_talent = IsPlayerSpell(198068)                        -- https://www.wowhead.com/spell=198068/power-of-the-dark-side      /run print(IsPlayerSpell(198068))
--Discipline Row 3 Talents
--    local have_lights_promise_talent = IsPlayerSpell(322115)                        -- https://www.wowhead.com/spell=322115/lights-promise      /run print(IsPlayerSpell(322115))
--    local have_sanctuary_talent = IsPlayerSpell(231682)                        -- https://www.wowhead.com/spell=231682/sanctuary      /run print(IsPlayerSpell(231682))
--    local have_pain_transformation_talent = IsPlayerSpell(372991)                        -- https://www.wowhead.com/spell=372991/pain-transformation      /run print(IsPlayerSpell(372991))
--    local have_protector_of_the_frail_talent = IsPlayerSpell(373035)                        -- https://www.wowhead.com/spell=373035/protector-of-the-frail      /run print(IsPlayerSpell(373035))
--    local have_dark_indulgence_talent = IsPlayerSpell(372972)                        -- https://www.wowhead.com/spell=372972/dark-indulgence      /run print(IsPlayerSpell(372972))
--    local have_schism_talent = IsPlayerSpell(424509)                        -- https://www.wowhead.com/spell=424509/schism      /run print(IsPlayerSpell(424509))
--Discipline Row 4 Talents
--    local have_bright_pupil_talent = IsPlayerSpell(390684)                        -- https://www.wowhead.com/spell=390684/bright-pupil      /run print(IsPlayerSpell(390684))
--    local have_enduring_luminescence_talent = IsPlayerSpell(390685)                        -- https://www.wowhead.com/spell=390685/enduring-luminescence      /run print(IsPlayerSpell(390685))
--    local have_shield_discipline_talent = IsPlayerSpell(197045)                        -- https://www.wowhead.com/spell=197045/shield-discipline      /run print(IsPlayerSpell(197045))
    local have_luminous_barrier_talent = IsPlayerSpell(271466)                        -- https://www.wowhead.com/spell=271466/luminous-barrier      /run print(IsPlayerSpell(271466))
    local have_power_word_barrier_talent = IsPlayerSpell(62618)                        -- https://www.wowhead.com/spell=62618/power-word-barrier      /run print(IsPlayerSpell(62618))
--    local have_painful_punishment_talent = IsPlayerSpell(390686)                        -- https://www.wowhead.com/spell=390686/painful-punishment      /run print(IsPlayerSpell(390686))
--    local have_malicious_intent_talent = IsPlayerSpell(372969)                        -- https://www.wowhead.com/spell=372969/malicious-intent      /run print(IsPlayerSpell(372969))
--Discipline Row 5 Talents
    local have_purge_the_wicked_talent = IsPlayerSpell(204197)                        -- https://www.wowhead.com/spell=204197/purge-the-wicked      /run print(IsPlayerSpell(204197))
    local have_rapture_talent = IsPlayerSpell(47536)                        -- https://www.wowhead.com/spell=47536/rapture      /run print(IsPlayerSpell(47536))
    local have_shadow_covenant_talent = IsPlayerSpell(314867)                        -- https://www.wowhead.com/spell=314867/shadow-covenant      /run print(IsPlayerSpell(314867))
--Discipline Row 6 Talents
--    local have_revel_in_purity_talent = IsPlayerSpell(373003)                        -- https://www.wowhead.com/spell=373003/revel-in-purity      /run print(IsPlayerSpell(373003))
    local have_contrition_talent = IsPlayerSpell(197419)                        -- https://www.wowhead.com/spell=197419/contrition      /run print(IsPlayerSpell(197419))
--    local have_exaltation_talent = IsPlayerSpell(373042)                        -- https://www.wowhead.com/spell=373042/exaltation      /run print(IsPlayerSpell(373042))
--    local have_indemnity_talent = IsPlayerSpell(373049)                        -- https://www.wowhead.com/spell=373049/indemnity      /run print(IsPlayerSpell(373049))
--    local have_pain_and_suffering_talent = IsPlayerSpell(390689)                        -- https://www.wowhead.com/spell=390689/pain-and-suffering      /run print(IsPlayerSpell(390689))
    local have_twilight_corruption_talent = IsPlayerSpell(373065)                        -- https://www.wowhead.com/spell=373065/twilight-corruption      /run print(IsPlayerSpell(373065))
--Discipline Row 7 Talents
--    local have_borrowed_time_talent = IsPlayerSpell(390691)                        -- https://www.wowhead.com/spell=390691/borrowed-time      /run print(IsPlayerSpell(390691))
--    local have_castigation_talent = IsPlayerSpell(193134)                        -- https://www.wowhead.com/spell=193134/castigation      /run print(IsPlayerSpell(193134))
--    local have_abyssal_reverie_talent = IsPlayerSpell(373054)                        -- https://www.wowhead.com/spell=373054/abyssal-reverie      /run print(IsPlayerSpell(373054))
--Discipline Row 8 Talents
--    local have_train_of_thought_talent = IsPlayerSpell(390693)                        -- https://www.wowhead.com/spell=390693/train-of-thought      /run print(IsPlayerSpell(390693))
    local have_ultimate_penitence_talent = IsPlayerSpell(421453)                        -- https://www.wowhead.com/spell=421453/ultimate-penitence      /run print(IsPlayerSpell(421453))
--    local have_lenience_talent = IsPlayerSpell(238063)                        -- https://www.wowhead.com/spell=238063/lenience      /run print(IsPlayerSpell(238063))
    local have_evangelism_talent = IsPlayerSpell(246287)                        -- https://www.wowhead.com/spell=246287/evangelism      /run print(IsPlayerSpell(246287))
--    local have_void_summoner_talent = IsPlayerSpell(390770)                        -- https://www.wowhead.com/spell=390770/void-summoner      /run print(IsPlayerSpell(390770))
--Discipline Row 9 Talents
--    local have_divine_aegis_talent = IsPlayerSpell(47515)                        -- https://www.wowhead.com/spell=47515/divine-aegis      /run print(IsPlayerSpell(47515))
--    local have_blaze_of_light_talent = IsPlayerSpell(215768)                        -- https://www.wowhead.com/spell=215768/blaze-of-light      /run print(IsPlayerSpell(215768))
--    local have_heavens_wrath_talent = IsPlayerSpell(421558)                        -- https://www.wowhead.com/spell=421558/heavens-wrath      /run print(IsPlayerSpell(421558))
    local have_harsh_discipline_talent = IsPlayerSpell(373180)                        -- https://www.wowhead.com/spell=373180/harsh-discipline      /run print(IsPlayerSpell(373180))
--    local have_expiation_talent = IsPlayerSpell(390832)                        -- https://www.wowhead.com/spell=390832/expiation      /run print(IsPlayerSpell(390832))
--    local have_inescapable_torment_talent = IsPlayerSpell(373427)                        -- https://www.wowhead.com/spell=373427/inescapable-torment      /run print(IsPlayerSpell(373427)) ALSO SHADOW TALENT
--Discipline Row 10 Talents
--    local have_aegis_of_wrath_talent = IsPlayerSpell(238135)                        -- https://www.wowhead.com/spell=238135/aegis-of-wrath      /run print(IsPlayerSpell(238135))
--    local have_weal_and_woe_talent = IsPlayerSpell(390786)                        -- https://www.wowhead.com/spell=390786/weal-and-woe      /run print(IsPlayerSpell(390786))
--    local have_overloaded_with_light_talent = IsPlayerSpell(421557)                        -- https://www.wowhead.com/spell=421557/overloaded-with-light      /run print(IsPlayerSpell(421557))
    local have_twilight_equilibrium_talent = IsPlayerSpell(390705)                        -- https://www.wowhead.com/spell=390705/twilight-equilibrium      /run print(IsPlayerSpell(390705))
    local have_mindbender_disc_talent = IsPlayerSpell(123040)                        -- https://www.wowhead.com/spell=123040/mindbender-disc      /run print(IsPlayerSpell(123040))

--PVP Talents
    local have_absolute_faith_talent = IsPlayerSpell(408853)                        -- https://www.wowhead.com/spell=408853/absolute-faith      /run print(IsPlayerSpell(408853))
--    local have_catharsis_talent = IsPlayerSpell(391297)                        -- https://www.wowhead.com/spell=391297/catharsis      /run print(IsPlayerSpell(391297))
--    local have_driven_to_madness_talent = IsPlayerSpell(199259)                        -- https://www.wowhead.com/spell=199259/driven-to-madness      /run print(IsPlayerSpell(199259))
--    local have_improved_mass_dispel_talent = IsPlayerSpell(426438)                        -- https://www.wowhead.com/spell=426438/improved-mass-dispel      /run print(IsPlayerSpell(426438))
--    local have_mind_trauma_talent = IsPlayerSpell(199445)                        -- https://www.wowhead.com/spell=199445/mind-trauma      /run print(IsPlayerSpell(199445))
    local have_mindgames_talent = IsPlayerSpell(375901)                        -- https://www.wowhead.com/spell=375901/mindgames      /run print(IsPlayerSpell(375901))
    local have_phase_shift_talent = IsPlayerSpell(408557)                        -- https://www.wowhead.com/spell=408557/phase-shift      /run print(IsPlayerSpell(408557))
    local have_psyfiend_talent = IsPlayerSpell(211522)                        -- https://www.wowhead.com/spell=211522/psyfiend      /run print(IsPlayerSpell(211522))
    local have_thoughtsteal_talent = IsPlayerSpell(316262)                        -- https://www.wowhead.com/spell=316262/thoughtsteal      /run print(IsPlayerSpell(316262))
--    local have_void_volley_talent = IsPlayerSpell(357711)                        -- https://www.wowhead.com/spell=357711/void-volley      /run print(IsPlayerSpell(357711))
    local have_divine_ascension_talent = IsPlayerSpell(328530)                        -- https://www.wowhead.com/spell=328530/divine-ascension      /run print(IsPlayerSpell(328530))
    local have_greater_heal_talent = IsPlayerSpell(289666)                        -- https://www.wowhead.com/spell=289666/greater-heal      /run print(IsPlayerSpell(289666))
    local have_holy_ward_talent = IsPlayerSpell(213610)                        -- https://www.wowhead.com/spell=213610/holy-ward      /run print(IsPlayerSpell(213610))
--    local have_purification_talent = IsPlayerSpell(196439)                        -- https://www.wowhead.com/spell=196439/purification      /run print(IsPlayerSpell(196439))
    local have_ray_of_hope_talent = IsPlayerSpell(197268)                        -- https://www.wowhead.com/spell=197268/ray-of-hope      /run print(IsPlayerSpell(197268))
--    local have_sanctified_ground_talent = IsPlayerSpell(357481)                        -- https://www.wowhead.com/spell=357481/sanctified-ground      /run print(IsPlayerSpell(357481))
--    local have_seraphic_crescendo_talent = IsPlayerSpell(419110)                        -- https://www.wowhead.com/spell=419110/seraphic-crescendo      /run print(IsPlayerSpell(419110))
    local have_spirit_of_the_redeemer_talent = IsPlayerSpell(215982)                        -- https://www.wowhead.com/spell=215982/spirit-of-the-redeemer      /run print(IsPlayerSpell(215982))
    local have_archangel_talent = IsPlayerSpell(197862)                        -- https://www.wowhead.com/spell=197862/archangel      /run print(IsPlayerSpell(197862))
    local have_dark_archangel_talent = IsPlayerSpell(197871)                        -- https://www.wowhead.com/spell=197871/dark-archangel      /run print(IsPlayerSpell(197871))
    local have_inner_light_and_shadow_talent = IsPlayerSpell(356085)                        -- https://www.wowhead.com/spell=356085/inner-light-and-shadow      /run print(IsPlayerSpell(356085))
--    local have_strength_of_soul_talent = IsPlayerSpell(197535)                        -- https://www.wowhead.com/spell=197535/strength-of-soul      /run print(IsPlayerSpell(197535))
    local have_trinity_talent = IsPlayerSpell(214205)                        -- https://www.wowhead.com/spell=214205/trinity      /run print(IsPlayerSpell(214205))
    local have_ultimate_radiance_talent = IsPlayerSpell(236499)                        -- https://www.wowhead.com/spell=236499/ultimate-radiance      /run print(IsPlayerSpell(236499))

--Shadowlands
    local have_night_fae_talent = IsPlayerSpell(321077)                        -- https://www.wowhead.com/spell=321077/night-fae         /run print(IsPlayerSpell(321077))
    local have_kyrian_talent = IsPlayerSpell(321076)                        -- https://www.wowhead.com/spell=321076/kyrian      /run print(IsPlayerSpell(321076))
    local have_necrolord_talent = IsPlayerSpell(321078)                        -- https://www.wowhead.com/spell=321078/necrolord      /run print(IsPlayerSpell(321078))
    local have_venthyr_talent = IsPlayerSpell(321079)                        -- https://www.wowhead.com/spell=321079/venthyr      /run print(IsPlayerSpell(321079))
--    local have_strigidium_talent = IsPlayerSpell(325887)                        -- https://www.wowhead.com/spell=325887/strigidium      /run print(IsPlayerSpell(325887))

--  /run print(IsPlayerSpell(375901))
--  /run print(itemcd(177278))
   

    local in_party = not IsInRaid() and IsInGroup() --local in_party  = (IsInRaid() == false) and (IsInGroup() == true)
    local in_raid   = IsInRaid()  --/Print UnitExists("raid1")
    local in_group  = IsInGroup() --/run print(IsInGroup())


    local InstantSpellLookup = {
        [_spell.flash_heal] = {
            instantCast = function(spell, unit)
                return _unit.player.buff["Surge of Light"].remaining > 0
            end
        },
        [_spell.penance] = {
            instantCast = function(spell, unit)
                return true -- Always instant
            end
        },
        [_spell.power_word_radiance] = {
            instantCast = function(spell, unit)
                return have_ultimate_radiance_talent or _unit.player.buff["Waste No Time"].remaining > 0
            end
        },
        [_spell.renew] = {
            instantCast = function(spell, unit)
                return true -- Always instant
            end
        },
        [_spell.shadow_word_pain] = {
            instantCast = function(spell, unit)
                return true -- Always instant
            end
        }
    }
    
    local function CheckInstantCast(spellRef, unit)
        local spellData = InstantSpellLookup[spellRef]
        if spellData and spellData.instantCast then
            return spellData.instantCast(spellRef, unit)
        else
            -- Fallback to check if the spell is instant by nature using C_Spell.GetSpellInfo
            local spellInfo = C_Spell.GetSpellInfo(spellRef)
            if spellInfo and spellInfo.castTime == 0 then
                return true -- Spell is instant by nature (cast time is 0 milliseconds)
            end
            return false -- Default to non-instant if not defined or not instant by nature
        end
    end
          


    -- function pvp_zone_or_pvp_target()
    --     local name,type = GetInstanceInfo()
    --     if type == "arena" or type == "pvp" then
    --         return true
    --     elseif SpellUnit_UnitAliveAndHostile("","target") and UnitPlayerControlled("target") then
    --         return true
    --     end
    --     return false
    -- end
    
    --/tar speaker Kuldas
    --/tar Nullbot
    --medbot
    --malfunctioning pylon
    --automatic ironstrider
    --explosive bomberbot
    --swarmbot
 


    -- function MeleeAttackers(units,seconds)
    --     if type(units) == "string" then
    --         units = {units}
    --     end
    
    --     local foes = {}
    
    --     for i,unit in next,units do
    --         local unit_guid = UnitGUID(unit) or ""
    --         local current_attackers = select_row(table_meleeAttacks_byDestAndSource,unit_guid)
    --         for source_guid,last_attack in pairs(current_attackers) do
    --             if last_attack + seconds > _now then
    --                 foes[source_guid] = last_attack
    --             end
    --         end
    
    --         if table_meleeAttacks_bySource[unit_guid] then
    --             local event_time = table_meleeAttacks_bySource[unit_guid].event_time or 0
    --             local dest_guid  = table_meleeAttacks_bySource[unit_guid].dest_guid or 0
    --             local dest_units_last_melee  = foes[dest_guid] or 0
    --             if dest_units_last_melee and event_time > dest_units_last_melee then
    --                 foes[dest_guid] = dest_units_last_melee
    --             end
    --         end
    --     end
    --     return count_table(foes),foes
    -- end
    
                -- Table of special target names
                local specialTargets = {
                    ["Speaker Kuldas"] = true,
                    ["Nullbot"] = true,
                    ["Corrupted Machinist"] = true,
                    ["Medbot"] = true,
                    ["Malfunctioning Pylon"] = true,
                    ["Automatic Ironstrider"] = true,
                    ["Explosive Bomberbot"] = true,
                    ["Swarmbot"] = true
                }

                -- Function to check if the unit is a Special target
                function isSpecialTarget(unit)
                    local name = UnitName(unit) -- Get the unit's name
                    local isSpecial = UnitIsSpecial(unit) -- Placeholder for actual special check
                    return specialTargets[name] and isSpecial -- Check both name and special status
                end

                -- -- Example usage
                -- local target = "target" -- The unit to check, "target" is the current target in the game
                -- if isSpecialTarget(target) then
                --     print(UnitName(target) .. " is a Special target!")
                -- else
                --     print(UnitName(target) .. " is not a Special target.")
                -- end

    local spam_string = ""
    _global.Off()

    if 1==0 then
    
    elseif RedLight() then
        _global.Off()


        elseif mc_on and delphi.spell[_spell.dominate_mind].ready and stationary and delphi.unit.focus.hostile and have_dominate_mind_talent and C_Spell.IsSpellInRange("Dominate Mind", "focus") then
            CastSpellUnits(
                _spell.dominate_mind,
                _unitids.focus,
                true, -- Logic condition is already checked (ready, stationary, hostile, talent, range)
                {SpellUnit_RangeCheck, SpellUnit_UnitAliveAndHostile, SpellUnit_ValidHarm, SpellUnit_ValidDominateMindTarget},
                nil
            )    
--old   elseif mc_on and delphi.spell[_spell.dominate_mind].ready and stationary and delphi.unit.focus.hostile and have_dominate_mind_talent and C_Spell.IsSpellInRange("Dominate Mind","focus") then _global.SetSpellUnit(_spell.dominate_mind,"focus")  
--and delphi.unit.focus.harm 
        
    elseif (delphi.unit.player.channelling and delphi.unit.player.cast_remaining > 0.1) or delphi.unit.player.buff["Dispersion"].remaining > 0 or delphi.unit.player.buff["Ultimate Penitence"].remaining > 0  or (delphi.unit.player.buff["Refreshment"].remaining > 0 and delphi.unit.player.health.percent > 0.40) then
        --print("CHANNELLING")
        _global.Off()
    -- elseif _unit.player.buff[_spell.fort].remaining == 0 and not combat then

   elseif special_on then 
    BindSpellToUnits(_spell.shadow_word_pain,   _unitids.raid_hostile,         "",     "/targetenemy")
    BindSpellToUnits(_spell.shadow_word_pain_tagging,   _unitids.tagging,       "",     "/targetenemy")
    --                (spell,                     unit,                         prefix,             suffix,         skipcontents,DelegateMacroCreation)

    BindMacroToUnits(_spell.targetenemy,        _unitids.blank,              "/targetenemy",     "\n/targetenemy",1,1)  

-- --BindMacroToUnits(_assist,hostile_units,"/assist ","" ) => creates the macros "/assist Party1" to "/assist Party4" etc
-- function BindMacroToUnits(spell,units,prefix,suffix)
--     --print("Binding ",spell," to ",units[1]," et al")
--     for i,unit in ipairs(units) do
--         --shh_binding_announcements = unit ~= "target"
--         BindSpellToUnit(spell,unit,prefix..unit..suffix,nil,_skipSpell)
--     end
-- end



    spam_string = spam_string .. "special_"
     --print(spam_string)
     if 1 == 0 then


                elseif CastSpellUnits(
                    _spell.shadow_word_pain_tagging
                        ,_unitids.tagging
                        ,RemainingCooldown(_spell.shadow_word_pain_tagging) < 0.5
                        ,{
                            --SpellUnit_UnitAliveAndHostile
                            SpellUnit_MyDebuffExpired
                            ,SpellUnit_RangeCheck
                            --,SpellUnit_ValidHarm
                        }
                        ) then --print("Shadow Word: Pain")   

            
                elseif CastSpellUnits(
                    _spell.shadow_word_pain
                        ,_unitids.raid_hostile
                        ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                        ,{
                        SpellUnit_UnitAliveAndHostile
                        ,SpellUnit_MyDebuffExpired
                        ,SpellUnit_RangeCheck
                        ,SpellUnit_ValidHarm
                        }
                        ) then --print("Shadow Word: Pain")   


                            
                        elseif CastSpellUnits(
                            _spell.targetenemy
                            ,_unitids.blank
                            ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                        ) then
                            print("delphi is attempting to press /targetenemy")
                            GreenlistSpellUnit("targetenemy", "blank")
                            delphi.player.casting = {
                                spell_name = "targetenemy",
                                dest_name = "blank"
                            }
                            active_spell = {
                                source      = "keypress_event",
                                unit        = "blank",
                                spell       = "targetenemy",
                                unit_name   = "blank",
                                unit_guid   = "",
                                time_start  = _now,
                                time_end    = _now + 0.25 + latency_est
                            }
                        
                

      end   
-- BindSpellToUnits(_spell.special_target_7,          _unitids.target,"/cleartarget [dead][noharm]\n/targetenemy [nodead]\n/tar [harm,nodead] Awakened Phalanx","",1)

 
--                 -- elseif special_on and special_scenario() then _global.SetSpellUnit(_spell.special_target_1,"target") --print("TRINKETS")
--             elseif special_on and special_scenario() and (GetTime() - special_action_last_time >= 0.5) then
--                 -- Update the last execution time
--                 special_action_last_time = GetTime()

--                 -- Execute all 7 special scenario actions
--                 CastSpellUnits(_spell.special_target_1,_unitids.target, special_scenario())
--                 CastSpellUnits(_spell.special_target_2, _unitids.target, special_scenario())
--                 CastSpellUnits(_spell.special_target_3, _unitids.target, special_scenario())
--                 CastSpellUnits(_spell.special_target_4, _unitids.target, special_scenario())
--                 CastSpellUnits(_spell.special_target_5, _unitids.target, special_scenario())
--                 CastSpellUnits(_spell.special_target_6, _unitids.target, special_scenario())
--                 CastSpellUnits(_spell.special_target_7, _unitids.target, special_scenario())
--             end       



                            -- elseif CastSpellUnits(_spell.renew
                            -- ,_unitids.player
                            -- ,RemainingCooldown(_spell.renew) < 0.5 and (stationary or CheckInstantCast(_spell.renew,"player"))
                            -- ,{SpellUnit_RangeCheck,	SpellUnit_AliveAndFriendly}
                            -- ,nil					
                            -- ) then --print("	Thoughtsteal Heal	")				


                    elseif CastSpellUnits(_spell.shackle_undead --add debuff check
                        ,_unitids.arena_hostile
                        ,RemainingCooldown(_spell.shackle_undead) < 0.5 and (stationary or CheckInstantCast(_spell.shackle_undead,"player")) and have_shackle_undead_talent
                        ,{SpellUnit_RangeCheck, SpellUnit_UnitAliveAndHostile, SpellUnit_ValidHarm, SpellUnit_SafeToCrowdControl,SpellUnit_DebuffExpiredUnder2,SpellUnit_ShackleUndeadPermitted,SpellUnit_IsUndead}
                        ,nil
                    ) then --ChatFrame7:AddMessage("Casting Shackle Undead")



                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.target
                        ,RemainingCooldown(_spell.thoughtsteal) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal,"player")) and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining == 0 --and combat
                        ,{SpellUnit_RangeCheck, SpellUnit_UnitAliveAndHostile, SpellUnit_ValidHarm, SpellUnit_SafeToAttack, SpellUnit_IsHumanoidWithMana}
                        ,nil
                    ) then --ChatFrame7:AddMessage("Casting Thoughtsteal on hostile target")

                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.target
                        ,RemainingCooldown(_spell.thoughtsteal_damage_frost_shock) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_damage_frost_shock,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_damage_frost_shock].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck, SpellUnit_UnitAliveAndHostile, SpellUnit_ValidHarm, SpellUnit_SafeToAttack}
                        ,nil
                    ) then --ChatFrame7:AddMessage("message")

                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.target
                        ,RemainingCooldown(_spell.thoughtsteal_damage_vampiric_touch) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_damage_vampiric_touch,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_damage_vampiric_touch].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck, SpellUnit_UnitAliveAndHostile, SpellUnit_ValidHarm, SpellUnit_SafeToAttack}
                        ,nil
                    ) then --ChatFrame7:AddMessage("message")

                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.target
                        ,RemainingCooldown(_spell.thoughtsteal_damage_penance) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_damage_penance,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_damage_penance].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck, SpellUnit_UnitAliveAndHostile, SpellUnit_ValidHarm, SpellUnit_SafeToAttack}
                        ,nil
                    ) then --ChatFrame7:AddMessage("message")

                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.target
                        ,RemainingCooldown(_spell.thoughtsteal_damage_singe_mana) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_damage_singe_mana,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_damage_singe_mana].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck, SpellUnit_UnitAliveAndHostile, SpellUnit_ValidHarm, SpellUnit_SafeToAttack}
                        ,nil
                    ) then --ChatFrame7:AddMessage("message")

                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.target
                        ,RemainingCooldown(_spell.thoughtsteal_damage_living_flame) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_damage_living_flame,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_damage_living_flame].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck, SpellUnit_UnitAliveAndHostile, SpellUnit_ValidHarm, SpellUnit_SafeToAttack}
                        ,nil
                    ) then --ChatFrame7:AddMessage("message")


                    elseif CastSpellUnits(_spell.thoughtsteal --add debuff check
                        ,_unitids.target
                        ,RemainingCooldown(_spell.thoughtsteal_control_fear) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_control_fear,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_control_fear].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck, SpellUnit_UnitAliveAndHostile, SpellUnit_ValidHarm,SpellUnit_SafeToCrowdControl, SpellUnit_DebuffExpiredUnder2,SpellUnit_FearPermitted}
                        ,nil
                    ) then --ChatFrame7:AddMessage("Casting Thoughtsteal control  on hostile target")

                    elseif CastSpellUnits(_spell.thoughtsteal --add debuff check
                        ,_unitids.target
                        ,RemainingCooldown(_spell.thoughtsteal_control_polymorph) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_control_polymorph,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_control_polymorph].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck, SpellUnit_UnitAliveAndHostile, SpellUnit_ValidHarm,SpellUnit_SafeToCrowdControl, SpellUnit_DebuffExpiredUnder2,SpellUnit_PolymorphPermitted, SpellUnit_ValidPolymorphTarget}
                        ,nil
                    ) then --ChatFrame7:AddMessage("Casting Thoughtsteal control  on hostile target")

                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.standard_friendly
                        ,RemainingCooldown(_spell.thoughtsteal_heal_rejuvenation) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_heal_rejuvenation,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_heal_rejuvenation].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck,	SpellUnit_AliveAndFriendly}--,SpellUnit_MyBuffExpired(_spell.thoughtsteal_heal_rejuvenation)} -- need to do track aura maybe
                        ,nil					
                    ) then --print("	Thoughtsteal Heal	")	

                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.standard_friendly
                        ,RemainingCooldown(_spell.thoughtsteal_heal_renewing_mist) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_heal_renewing_mist,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_heal_renewing_mist].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck,	SpellUnit_AliveAndFriendly}--,SpellUnit_MyBuffExpired(_spell.thoughtsteal_heal_renewing_mist,unit)}
                        ,nil					
                    ) then --print("	Thoughtsteal Heal	")				

                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.standard_friendly
                        ,RemainingCooldown(_spell.thoughtsteal_heal_renew) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_heal_renew,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_heal_renew].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck,	SpellUnit_AliveAndFriendly}--,SpellUnit_MyBuffExpired(_spell.thoughtsteal_heal_renew,unit)}
                        ,nil					
                    ) then --print("	Thoughtsteal Heal	")				

                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.standard_friendly
                        ,RemainingCooldown(_spell.thoughtsteal_heal_wild_heal) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_heal_wild_heal,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_heal_wild_heal].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck,	SpellUnit_AliveAndFriendly}
                        ,nil					
                    ) then --print("	Thoughtsteal Heal	")				

                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.standard_friendly
                        ,RemainingCooldown(_spell.thoughtsteal_heal_penance) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_heal_penance,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_heal_penance].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck,	SpellUnit_AliveAndFriendly}
                        ,nil					
                    ) then --print("	Thoughtsteal Heal	")				


                    elseif CastSpellUnits(_spell.thoughtsteal
                        ,_unitids.player
                        ,RemainingCooldown(_spell.thoughtsteal_utility_blessing_of_freedom) < 0.5 and (stationary or CheckInstantCast(_spell.thoughtsteal_utility_blessing_of_freedom,"player")) and ThoughtstealSpellLookup[_spell.thoughtsteal_utility_blessing_of_freedom].checkKnown() and combat and have_thoughtsteal_talent and _unit.player.buff[_spell.thoughtsteal].remaining > 0
                        ,{SpellUnit_RangeCheck,SpellUnit_AliveAndFriendly}
                        ,nil						
                    ) then --print("Thoughtsteal Utility")				



    elseif CastSpellUnits(
        _spell.levitate,_unitids.player
        ,RemainingCooldown(_spell.levitate) < 0.5 and FallingStatus() and _unit.player.buff["Divine Ascension"].remaining == 0
        ,{SpellUnit_AliveAndFriendly,SpellUnit_BuffExpired}
    ) then --print("Levitate from falling")

            elseif CastSpellUnits(
                _spell.extra_action_button_1
                ,_unitids.player
                ,combat and HasExtraActionBar() and ExtraActionButton1:IsShown() and IsUsableAction(ExtraActionButton1.action) and select(2, GetActionCooldown(ExtraActionButton1.action)) == 0 and _unit.player.buff["Crawler Mine"].remaining > 0
                ,{
                    SpellUnit_AliveAndFriendly
                }
            ) then --print("Siren Isle Crawler Mine Attack")
    

    elseif CastSpellUnits(
            _spell.kyrian_steward
            ,_unitids.player
            ,RemainingCooldown(_spell.kyrian_steward) < 0.5 and shadowlands() and have_kyrian_faciton and not combat and phial_count() < 3
            ,{
                SpellUnit_AliveAndFriendly
            }
        ) then --print("Steward")

    elseif CastSpellUnits(
        _spell.kyrian_blast --replaces mind flay and smite 
        ,_unitids.target
        ,RemainingCooldown(_spell.kyrian_blast) < 0.5 and shadowlands() and have_kyrian_faciton and combat and _unit.player.buff["Boon of the Ascended"].remaining > 0 and not have_mind_spike_talent
        ,{
            SpellUnit_UnitAliveAndHostile
            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
            ,SpellUnit_ValidHarm
            --,SpellUnit_NoRecasting
        }
        ) then --print("Ascended Blast")
 
    elseif CastSpellUnits(
        _spell.kyrian_blast --replaces mind flay and smite 
        ,_unitids.standard_hostile
        ,RemainingCooldown(_spell.kyrian_blast) < 0.5 and shadowlands() and have_kyrian_faciton and combat and _unit.player.buff["Boon of the Ascended"].remaining > 0 and not have_mind_spike_talent
        ,{
            SpellUnit_UnitAliveAndHostile
            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
            ,SpellUnit_ValidHarm
            --,SpellUnit_NoRecasting
        }
        ) then --print("Ascended Blast")
    

    elseif CastSpellUnits(
        _spell.kyrian_nova
        ,_unitids.player
        ,RemainingCooldown(_spell.kyrian_nova) < 0.5 and shadowlands() and have_kyrian_faciton and combat and _unit.player.buff["Boon of the Ascended"].remaining > 0
        ,{
            SpellUnit_AliveAndFriendly
        }
    ) then --print("Nova of the Ascended")
        
    
    elseif CastSpellUnits(
        _spell.kyrian_boon
        ,_unitids.player
        ,RemainingCooldown(_spell.kyrian_boon) < 0.5 and shadowlands() and have_kyrian_faciton and combat and stationary 
        ,{
            SpellUnit_MyBuffExpired
        }
    ) then --print("Boon of the Ascended")

   
        
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
        ,RemainingCooldown(_spell.necrolord_fleshcraft) < 0.5 and shadowlands() and have_necrolord_faciton and stationary and SpellUnit_BreakingBuffsExpired
        ,{
            SpellUnit_MyBuffExpired
        }
    ) then --print("Fleshcraft")
    

    elseif CastSpellUnits(
        _spell.necrolord_unholy_nova
        ,_unitids.standard_hostile
        ,RemainingCooldown(_spell.necrolord_unholy_nova) < 0.5 and shadowlands() and have_necrolord_faciton and combat
        ,{
            SpellUnit_UnitAliveAndHostile
            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
            ,SpellUnit_ValidHarm
            --,SpellUnit_NoRecasting
        }
        ) then --print("Unholy Nova")

            
    elseif CastSpellUnits(
        _spell.venthyr_mindgames
        ,_unitids.standard_hostile
        ,RemainingCooldown(_spell.venthyr_mindgames) < 0.5 and shadowlands() and have_venthyr_faciton and combat and stationary and not have_mindgames_talent
        ,{
            SpellUnit_UnitAliveAndHostile
            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
            ,SpellUnit_ValidHarm
            --,SpellUnit_NoRecasting
        }
        ) then --print("Mind Games")

            
    elseif CastSpellUnits(
        _spell.night_fae_fae_guardians
        ,_unitids.standard_friendly
        ,RemainingCooldown(_spell.night_fae_fae_guardians) < 0.5 and shadowlands() and have_night_fae_faciton and combat
        ,{
            SpellUnit_AliveAndFriendly
            ,SpellUnit_RangeCheck
        }
        ) then --print("Fae Guardians")
  
  
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
        
      
                    
    elseif CastSpellUnits( --kyrian_phial)
        _spell.trained_gromit_carrier
        ,_unitids.player
        ,RemainingCooldown(_spell.trained_gromit_carrier) < 0.5 and maw_and_korthia() and not combat and stationary and has_trained_gromit_carrier_in_bags and trained_gromit_carrier_cooldown() == 0 and delphi.unit.player.buff["Swagsnout Gromit"].remaining == 0
        ,{
            SpellUnit_AliveAndFriendly
        }
    ) then --print("gromit")


   
        -- elseif CastSpellUnits(
        --     _spell.summon_pocopoc
        --     ,_unitids.player
        --     ,RemainingCooldown(_spell.summon_pocopoc) < 0.5 and zereth_mortis() and have_summon_pocopoc_talent and (_unit.player.buff["Pocopoc Recharge"].remaining_or_high < 0.5)
        --     ,{
        --         SpellUnit_NoRecasting
        --         ,SpellUnit_AliveAndFriendly
        --     }
        -- ) then --print("Summon Pocopoc") _unit.player.buff["Perceptive Pocopoc"].remaining == 0 or 
            

    elseif CastSpellUnits(
        _spell.healthstone
        ,_unitids.player
        ,RemainingCooldown(_spell.healthstone) < 0.5 and combat and healthstone_count() > 0 and healthstone_cooldown() == 0 and delphi.unit.player.buff["Spirit of Redemption"].remaining == 0
        ,{
            SpellUnit_AliveAndFriendly
            ,SpellUnit_HealthBelow50
        }
    ) then --print("healthstone")




        elseif CastSpellUnits(
            _spell.fade,_unitids.player
                ,RemainingCooldown(_spell.fade) < 0.5 and combat and have_phantasm_talent and delphi.unit.player.debuff[450505].remaining > 0 and delphi.unit.player.buff["Spirit of Redemption"].remaining == 0
                ,{SpellUnit_AliveAndFriendly,SpellUnit_ExpiringOrExpired}
                ) then --print("Fade")

            elseif CastSpellUnits(
                _spell.desperate_prayer,_unitids.player
                ,RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 and delphi.unit.player.buff["Spirit of Redemption"].remaining == 0
                ,{SpellUnit_AliveAndFriendly}
                ) then --print("Desperate Prayer")
    
            --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

        elseif CastSpellUnits(
            _spell.psychic_scream
                ,_unitids.player
                ,RemainingCooldown(_spell.psychic_scream) < 0.5 and combat and player_health_perc < 0.6 -- and not have_mind_bomb_talent
                ,{
                    SpellUnit_AliveAndFriendly
                }
            ) then --print("Psychic Scream")
    
            elseif CastSpellUnits(
                _spell.void_tendrils,_unitids.player
                    ,RemainingCooldown(_spell.void_tendrils) < 0.5 and not stationary and have_void_tendrils_talent and combat and player_health_perc < 0.65
                    ,{SpellUnit_AliveAndFriendly}
                    ) then --print("Void Tendrils")

            elseif CastSpellUnits(_spell.flash_heal,_unitids.player,RemainingCooldown(_spell.flash_heal) < 0.5
             and delphi.resource.mana_percent > 0.11
             and combat and (stationary or (_unit.player.buff["Surge of Light"].remaining > 0))
             and ((player_health_perc < 0.81 and _unit.player.buff["From Darkness Comes Light"].stacks >= 18 and _unit.player.buff["From Darkness Comes Light"].remaining > 0)
             or   (player_health_perc < 0.79 and _unit.player.buff["From Darkness Comes Light"].stacks >= 20 and _unit.player.buff["From Darkness Comes Light"].remaining > 0))
             ,{SpellUnit_AliveAndFriendly,SpellUnit_NoRecasting,SpellUnit_HealthBelow95,SpellUnit_RangeCheck}) 
             then --print("Fomes Darkness Comes Light Heal")

             elseif CastSpellUnits(_spell.flash_heal,_unitids.party,RemainingCooldown(_spell.flash_heal) < 0.5
             and delphi.resource.mana_percent > 0.11 and isBrannInParty() and special_delve()
             and combat and (stationary or (_unit.player.buff["Surge of Light"].remaining > 0))
             and ((party1_health_perc < 0.99 and _unit.player.buff["From Darkness Comes Light"].stacks >= 18 and _unit.player.buff["From Darkness Comes Light"].remaining > 0)
             or   (party1_health_perc < 0.98 and _unit.player.buff["From Darkness Comes Light"].stacks >= 20 and _unit.player.buff["From Darkness Comes Light"].remaining > 0))
             ,{SpellUnit_AliveAndFriendly,SpellUnit_NoRecasting,SpellUnit_HealthBelow95,SpellUnit_RangeCheck}) 
             then --print("Fomes Darkness Comes Light Heal on Brann")


             elseif CastSpellUnits(
                _spell.angelic_feather,_unitids.player
                    ,RemainingCooldown(_spell.angelic_feather) < 0.5 and moving_for > 1 and have_angelic_feather_talent and angelic_feather_check() --and not stationary
                    ,{
                        SpellUnit_MyBuffExpired
                        ,SpellUnit_SpeedBuffExpired
                    }
                    ) then --print("Angelic Feather")

                    elseif CastSpellUnits(
                        _spell.shield,_unitids.player
                            ,RemainingCooldown(_spell.shield) < 0.5 and have_body_and_soul_talent and moving_for > 1 --and not stationary
                            ,{
                                SpellUnit_AliveAndFriendly
                                ,SpellUnit_SpeedBuffExpired
                                -- ,SpellUnit_Expired
                                --,SpellUnit_WeakenedSoulExpired
                            }
                        ) then print("Power Word: Shield Sprint line 2271")


        
    elseif CastSpellUnits(
        _spell.fort
        ,_unitids.player
        ,RemainingCooldown(_spell.fort) < 0.5 and not combat
        ,{
            SpellUnit_BuffExpiringUnder300
        }
    ) then --print("self:fort")


    elseif CastSpellUnits(
        _spell.spirit_of_the_redeemer
            ,_unitids.player
            ,RemainingCooldown(_spell.spirit_of_the_redeemer) < 0.5 and have_spirit_of_the_redeemer_talent and combat
            ,{
                SpellUnit_AliveAndFriendly
                ,SpellUnit_ExpiringOrExpired  
                ,SpellUnit_HealthBelow30                                                           
            }
        ) then --print("Spirit of Redemption")

-- --
-- --         dP oo                   oo          dP oo                   
-- --         88                                  88                      
-- --   .d888b88 dP .d8888b. .d8888b. dP 88d888b. 88 dP 88d888b. .d8888b. 
-- --   88'  `88 88 Y8ooooo. 88'  `"" 88 88'  `88 88 88 88'  `88 88ooood8 
-- --   88.  .88 88       88 88.  ... 88 88.  .88 88 88 88    88 88.  ... 
-- --   `88888P8 dP `88888P' `88888P' dP 88Y888P' dP dP dP    dP `88888P' 
-- --                                    88                               
-- --                                    dP                                       
    elseif discipline_spec == delphi.spec then 
        --Spec Spells START
        BindSpellToUnits(_spell.holy_nova,                  _unitids.player)
        BindSpellToUnits(_spell.mass_res,                   _unitids.player)
--        BindSpellToUnits(_spell.shining_force,              _unitids.player)
        BindSpellToUnits(_spell.angelic_feather,            _unitids.player)
        BindSpellToUnits(_spell.divine_star,                _unitids.player)
        BindSpellToUnits(_spell.halo,                       _unitids.player)
        BindSpellToUnits(_spell.power_word_barrier,         _unitids.player)--,"/cast [@player] Power Word: Barrier","",1)
        BindSpellToUnits(_spell.luminous_barrier,           _unitids.player) 
        BindSpellToUnits(_spell.evangelism,                 _unitids.player)
        BindSpellToUnits(_spell.archangel,                  _unitids.player)
        BindSpellToUnits(_spell.dark_archangel,             _unitids.player)
        BindSpellToUnits(_spell.inner_light,                _unitids.player)
        BindSpellToUnits(_spell.inner_shadow,               _unitids.player)
        BindSpellToUnits(_spell.ultimate_penitence,         _unitids.player)

        BindSpellToUnits(_spell.mindblast,                  _unitids.target)
        BindSpellToUnits(_spell.mindbender,                 _unitids.target)
        BindSpellToUnits(_spell.shadowfiend,                _unitids.target)
--        BindSpellToUnits(_spell.schism,                     _unitids.target)
        BindSpellToUnits(_spell.penance,                    _unitids.target)------------multiple
        BindSpellToUnits(_spell.smite,                      _unitids.target)
        -- BindSpellToUnits(_spell.thoughtsteal,               _unitids.target)
--        BindSpellToUnits(_spell.lights_wrath,               _unitids.target)


        BindSpellToUnits(_spell.flash_heal,                 _unitids.standard_friendly)------------multiple
        BindSpellToUnits(_spell.penance,                    _unitids.standard_friendly)------------multiple
        BindSpellToUnits(_spell.pain_suppression,           _unitids.standard_friendly)
        BindSpellToUnits(_spell.power_word_radiance,        _unitids.standard_friendly)
        -- BindSpellToUnits(_spell.shadow_covenant,            _unitids.standard_friendly)
        BindSpellToUnits(_spell.rapture,                    _unitids.standard_friendly)
        BindSpellToUnits(_spell.shield,                     _unitids.standard_friendly)------------multiple
--        BindSpellToUnits(_spell.cleanse,                    _unitids.standard_friendly)

        --BindSpellToUnits(_spell.shield,                     _unitids.raid_friendly)------------multiple
--        BindSpellToUnits(_spell.flash_heal,                 _unitids.raid_friendly)

        BindSpellToUnits(_spell.penance,                    _unitids.standard_hostile)------------multiple
        BindSpellToUnits(_spell.shadow_word_pain,           _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.purge_the_wicked,           _unitids.standard_hostile)
        BindSpellToUnits(_spell.mindblast,                  _unitids.standard_hostile)
        BindSpellToUnits(_spell.mindbender,                 _unitids.standard_hostile)
        BindSpellToUnits(_spell.shadowfiend,                _unitids.standard_hostile)
        BindSpellToUnits(_spell.smite,                      _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.power_word_solace,          _unitids.standard_hostile)------------multiple
--        BindSpellToUnits(_spell.schism,                     _unitids.standard_hostile)

        BindSpellToUnits(_spell.renew,                      _unitids.raid_friendly)
        BindSpellToUnits(_spell.power_word_life,            _unitids.raid_friendly)
        -- BindSpellToUnits(_spell.penance,                    _unitids.raid_friendly)------------multiple
        -- BindSpellToUnits(_spell.flash_heal,                 _unitids.raid_friendly)------------multiple
        -- BindSpellToUnits(_spell.shield,                     _unitids.raid_friendly)------------multiple
        -- BindSpellToUnits(_spell.power_word_radiance,        _unitids.raid_friendly)

        BindSpellToUnits(_spell.shadow_word_pain,           _unitids.raid_hostile)
        
        -- BindSpellToUnits(_spell.penance,                    _unitids.raid_hostile)------------multiple
        -- BindSpellToUnits(_spell.power_word_solace,          _unitids.raid_hostile)------------multiple
        -- BindSpellToUnits(_spell.purge_the_wicked,           _unitids.raid_hostile)
        -- BindSpellToUnits(_spell.mindblast,                  _unitids.raid_hostile)
        -- BindSpellToUnits(_spell.mindbender,                 _unitids.raid_hostile)
        -- BindSpellToUnits(_spell.shadowfiend,                _unitids.raid_hostile)
        -- BindSpellToUnits(_spell.schism,                     _unitids.raid_hostile)
        -- BindSpellToUnits(_spell.smite,                      _unitids.raid_hostile)

--        OLD
--        BindSpellToUnits(_spell.spirit_shell,               _unitids.player)



    
        --Spec Spells END
        spam_string = "disc_"   
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
                            print("test section")

                            elseif CastSpellUnits(_spell.	power_word_radiance	,_unitids.	standard_friendly	,		
                            RemainingCooldown(_spell.	power_word_radiance	) < 0.5 and (stationary or CheckInstantCast(_spell.		power_word_radiance	, "player")) and 	 combat
                            ,{SpellUnit_RangeCheck,	SpellUnit_AliveAndFriendly					}
                            ,RankUnits_MaxHealthDeficit						
                            ) then --print("	Power Word Radiance	")				

                        





                 
                    
                                -- elseif CastSpellUnits(_spell.penance,_unitids.raid_friendly,
                                --         RemainingCooldown(_spell.penance) < 0.5
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_RangeCheck,SpellUnit_MediumHealth}
                                --         ,RankUnits_MaxHealthDeficit
                                --         ) then --print("Penance Heal")
                                    
                                -- --+++Generic Block Start+++
                                -- elseif CastSpellUnits(_spell.power_word_life,_unitids.raid_friendly
                                --         ,have_power_word_life_talent and combat and RemainingCooldown(440678) < 0.5  and have_miraculous_recovery_talent and _unit.raid_friendly.health.percent < 0.50
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_RangeCheck,SpellUnit_NoRecasting,SpellUnit_HealthBelow50}
                                --         ,RankUnits_MaxHealthDeficitPercent
                                --         ) then --print("Power Word: Life 50%")

                                -- elseif CastSpellUnits(_spell.power_word_life,_unitids.raid_friendly
                                --         ,have_power_word_life_talent and combat and RemainingCooldown(373481) < 0.5 and not have_miraculous_recovery_talent and _unit.raid_friendly.health.percent < 0.35
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_RangeCheck,SpellUnit_NoRecasting,SpellUnit_HealthBelow35}
                                --         ,RankUnits_MaxHealthDeficitPercent
                                --         ) then --print("Power Word: Life 35%")

            
                                -- elseif CastSpellUnits(_spell.pain_suppression,_unitids.standard_friendly
                                --         ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_VeryLowHealth,SpellUnit_RangeCheck,SpellUnit_Expired}
                                --         ) then --print("Pain Suppression")
            

                                -- elseif CastSpellUnits(_spell.flash_heal,_unitids.raid_friendly
                                --         ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_HealthBelow90,SpellUnit_RangeCheck}
                                --         ,RankUnits_MaxHealthDeficitPercent
                                --         ) then  --print("Surge of Light flash heal")
        
            
                                -- elseif CastSpellUnits(_spell.rapture,_unitids.standard_friendly
                                --         ,RemainingCooldown(_spell.rapture) < 0.5 and combat and have_rapture_talent
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_HealthBelow30,SpellUnit_RangeCheck}
                                --         ) then --print("Rapture")
             

                                -- elseif CastSpellUnits(_spell.shield,_unitids.raid_friendly
                                --         ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_ExpiringOrExpired,SpellUnit_RangeCheck,Botchuloz_SpellUnit_Help_Rank_Shield}
                                --         ) then --print("Power Word: Shield Normal")            
                                                                            
                                -- elseif CastSpellUnits(_spell.evangelism,_unitids.player
                                --         ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 4.5 and have_evangelism_talent and combat
                                --         ,{}
                                --         ) then --print("Evangelism")
                                        
                                -- elseif CastSpellUnits(_spell.power_word_barrier,_unitids.player
                                --         ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat and have_power_word_barrier_talent
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_HealthBelow50}
                                --         ) then --print("Power Word: Barrier")
        
                                -- elseif CastSpellUnits(_spell.luminous_barrier,_unitids.player
                                --         ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat and have_luminous_barrier_talent
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_VeryLowHealth}
                                --         ) then --print("Luminous Barrier")
            

                                -- elseif CastSpellUnits(_spell.shadowfiend,_unitids.target
                                --         ,((RemainingCooldown(_spell.voidwraith ) < 0.5 and have_voidwraith_talent) or 
                                --           (RemainingCooldown(_spell.mindbender ) < 0.5 and not have_voidwraith_talent and have_mindbender_disc_talent) or 
                                --           (RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_voidwraith_talent and not have_mindbender_disc_talent)) and 
                                --         time_in_combat >= 10 
                                --         ,{SpellUnit_UnitAliveAndHostile,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                --         ) then --print("Shadowfiend")

    
                                -- elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                --         ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                --          (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                --         ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                --         ) then --print("Shadow Word: Pain")   
            

                                -- elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                --         ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                --          (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                --         ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                --         ) then --print("Shadow Word: Pain refresh") 

                                -- elseif CastSpellUnits(_spell.power_word_radiance,_unitids.raid_friendly
                                --         ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and (stationary or have_ultimate_radiance_pvp_talent or _unit.player.buff["Waste No Time"].remaining > 0) and have_power_word_radiance_talent and UnitsHealthDeficitDetail(0.09, 4, _unitids.raid_friendly)
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_NoRecasting,SpellUnit_RangeCheck}
                                --         ) then --print("Power Word: Radiance")

                                -- elseif CastSpellUnits(_spell.divine_star,_unitids.player
                                --         ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                --         ,{SpellUnit_AliveAndFriendly}
                                --         ) then --print("Divine Star")

                                -- elseif CastSpellUnits(_spell.halo,_unitids.player
                                --         ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                --         ,{SpellUnit_AliveAndFriendly}
                                --         ) then --print("Halo")

                                -- elseif CastSpellUnits(_spell.ultimate_penitence,_unitids.player
                                --         ,RemainingCooldown(_spell.ultimate_penitence) < 0.5 and have_ultimate_penitence_talent and stationary and combat and time_in_combat >= 15
                                --         ,{SpellUnit_AliveAndFriendly}
                                --         ) then --print("Ultimate Penitence")
                                         

                                -- elseif CastSpellUnits(_spell.shield,_unitids.raid_friendly
                                --         ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_RangeCheck,SpellUnit_NoRecasting,Atonement_Missing,SpellUnit_HealthBelow95,SpellUnit_ExpiringOrExpired}
                                --         ) then --print("Shield to apply Atonement")        

                                -- elseif CastSpellUnits(_spell.renew,_unitids.raid_friendly
                                --         ,RemainingCooldown(_spell.renew) < 0.5 and have_renew_talent and RemainingCooldown(_spell.shield) > 0.5 and combat
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_RangeCheck,SpellUnit_NoRecasting,Atonement_Missing,SpellUnit_HealthBelow90,SpellUnit_ExpiringOrExpired}
                                --         ) then --print("Renew to apply Atonement")        
    



                                -- --+++Attack and Target Type Block END+++                                
                                -- elseif CastSpellUnits(_spell.flash_heal,_unitids.standard_friendly
                                --         ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_NoRecasting,SpellUnit_AlmostEmpty,SpellUnit_RangeCheck}
                                --         ,RankUnits_MaxHealthDeficitPercent
                                --         ) then --print("Flash Heal")

                                -- elseif CastSpellUnits(_spell.smite,_unitids.standard_hostile
                                --         ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                --         ,{SpellUnit_UnitAliveAndHostile,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                --         ) then --print("Smite")
                        
        

                                -- --+++Attack and Target Type Block END+++                                
                                
                                    

                                -- elseif CastSpellUnits(_spell.flash_heal,_unitids.raid_friendly
                                --         ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                --         ,{SpellUnit_AliveAndFriendly,SpellUnit_HealthBelow95,SpellUnit_RangeCheck}
                                --         ) then --print("Flash Heal OOC")


                                             
                 else _global.Off()
                 end



                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)
                                if 1 == 0 then
                                            

                            -- elseif CastSpellUnits(
                            --     _spell.power_word_solace
                            --     ,_unitids.target
                            --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                            --     ,{
                            --         SpellUnit_UnitAliveAndHostile
                            --         ,SpellUnit_RangeCheck
                            --         ,SpellUnit_ValidHarm
                            --     }
                            --     ) then --print("Schism")
            
                                --+++Penance BLOCK END+++                                                                       
                            elseif CastSpellUnits(
                                _spell.penance
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.penance) < 0.5
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_HealthBelow20
                                    }
                                    ) then --print("Penance Heal Low HP")

                                        
                            elseif CastSpellUnits(
                                _spell.penance
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.penance) < 0.5 and have_contrition_talent and combat
                                    ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_MediumHealth
                                    }
                                    ,RankUnits_MaxHealthDeficitPercent
                                    ) then --print("Penance and Contrition Heal")

                

                            elseif CastSpellUnits(
                                _spell.penance
                                    ,_unitids.standard_hostile
                                    ,RemainingCooldown(_spell.penance) < 0.5 and not have_contrition_talent and not have_twilight_corruption_talent and not have_harsh_discipline_talent 
                                    ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Penance attack")  
                                                                    

                            elseif CastSpellUnits(
                                _spell.penance
                                    ,_unitids.standard_hostile
                                    ,RemainingCooldown(_spell.penance) < 0.5 and (((have_shadow_covenant_talent) and _unit.player.buff["Shadow Covenant"].remaining > 0) or (have_harsh_discipline_talent and _unit.player.buff["Harsh Discipline"].remaining > 0))
                                    ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Penance attack")  

                            --+++Penance BLOCK END+++                                                                       

                                --+++Generic Block Start+++
                            elseif CastSpellUnits(
                                _spell.power_word_life
                                    ,_unitids.raid_friendly
                                    ,RemainingCooldown(_spell.power_word_life) < 0.5 and have_power_word_life_talent and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow35
                                        ,SpellUnit_RangeCheck                                                           
                                    }
                                ) then --print("Power Word: Life")

                            -- elseif CastSpellUnits(
                            --     _spell.power_word_solace
                            --     ,_unitids.standard_hostile
                            --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                            --     ,{
                            --         SpellUnit_UnitAliveAndHostile
                            --         ,SpellUnit_RangeCheck
                            --         ,SpellUnit_ValidHarm
                            --     }
                            --     ) then --print("Power Word: Solsace")
        
                            elseif CastSpellUnits(
                                _spell.pain_suppression
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow30
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_Expired
                                    }
                                ) then --print("Pain Suppression")
        
 
                            elseif CastSpellUnits(
                                _spell.flash_heal
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_NoRecasting
                                        ,SpellUnit_HealthBelow95
                                        ,SpellUnit_RangeCheck
                                        
                                    }
                                        ,RankUnits_MaxHealthDeficitPercent
                                ) then  --print("Surge of Light flash heal")
    
       
                            elseif CastSpellUnits(
                                _spell.rapture
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.rapture) < 0.5 and combat and have_rapture_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                        ,SpellUnit_HealthBelow30
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Rapture")
         

                            elseif CastSpellUnits(
                                _spell.shield
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                        --,SpellUnit_WeakenedSoulExpired
                                        ,SpellUnit_RangeCheck
                                        --,Botchuloz_SpellUnit_Help_Rank_Shield
                                    }
                                    ,RankUnits_PvETargets
                                ) then print("Power Word: Shield Normal line 2698")

        
                                                                        
                                elseif CastSpellUnits(
                                    _spell.evangelism
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 5 and have_evangelism_talent and combat
                                    ,{
                                        --SpellUnit_MyBuffExpiringUnder5
                                    }
                                    ) then --print("Evangelism")
                                        
                                elseif CastSpellUnits(
                                    _spell.power_word_barrier
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat and have_power_word_barrier_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow30
                                    }
                                    ) then --print("Power Word: Barrier")
        
                                elseif CastSpellUnits(
                                    _spell.luminous_barrier
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat and have_luminous_barrier_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_VeryLowHealth
                                    }
                                    ) then --print("Luminous Barrier")
            
    
                                elseif CastSpellUnits(
                                    _spell.shadowfiend
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_disc_talent and mana_percent <0.80 and combat
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Shadowfiend")
        
                                elseif CastSpellUnits(
                                    _spell.mindbender
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_disc_talent and mana_percent <0.95 and combat
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Mindbender")
    
    
                                            
    
                                        elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain")   
            

                                elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain refresh") 

        

                            elseif CastSpellUnits(
                                _spell.power_word_radiance
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and GroupHealthDeficit() > 12000 and stationary and have_power_word_radiance_talent and not have_ultimate_radiance_pvp_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_HealthBelow90
                                        ,SpellUnit_NoRecasting
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Power Word: Radiance")

                            elseif CastSpellUnits(
                                _spell.power_word_radiance
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and GroupHealthDeficit() > 12000 and have_power_word_radiance_talent and have_ultimate_radiance_pvp_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_HealthBelow90
                                        ,SpellUnit_NoRecasting
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Power Word: Radiance instant cast")

                                                    
                            --+++Generic Block END+++
                        

                            --+++DPS BLOCK START+++

                            elseif CastSpellUnits(
                                _spell.mindblast
                                    ,_unitids.target
                                    ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Mind Blast")

                            elseif CastSpellUnits(
                                _spell.shadow_word_death
                                        ,_unitids.target
                                        ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and have_shadow_word_death_talent and player_health_perc > 0.45 and _unit.target.health.percent < 0.2
                                        ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        }
                                    ) then --print("Shadow Word: Death")
                                                                

                            -- elseif CastSpellUnits(
                            --     _spell.shadow_word_death
                            --             ,_unitids.target
                            --             ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and have_shadow_word_death_talent and player_health_perc > 0.40 and have_shadow_covenant_talent and _unit.player.buff["Shadow Covenant"].remaining > 0
                            --             ,{
                            --             SpellUnit_UnitAliveAndHostile
                            --             ,SpellUnit_RangeCheck
                            --             ,SpellUnit_ValidHarm
                            --             }
                            --         ) then --print("Shadow Word: Death with Shadow Covenant")


                            --+++DPS BLOCK END+++
                            --++Halo and Divine Star START+++
                            elseif CastSpellUnits(
                                _spell.divine_star
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat and not have_twilight_corruption_talent and not have_harsh_discipline_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Divine Star Normal")

                            elseif CastSpellUnits(
                                _spell.halo
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and not have_twilight_corruption_talent and not have_harsh_discipline_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Halo Normal")


                            elseif CastSpellUnits(
                                _spell.divine_star
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and (((have_shadow_covenant_talent) and _unit.player.buff["Shadow Covenant"].remaining > 0) or (have_harsh_discipline_talent and _unit.player.buff["Harsh Discipline"].remaining > 0))
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Divine Star DPS Talents")

                            elseif CastSpellUnits(
                                _spell.halo
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and (((have_shadow_covenant_talent) and _unit.player.buff["Shadow Covenant"].remaining > 0) or (have_harsh_discipline_talent and _unit.player.buff["Harsh Discipline"].remaining > 0))
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Halo DPS Talents")


                            elseif RemainingCooldown(
                                _spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  
                            --+++shared speed spells END+++

                            --+++Attack and Target Type Block END+++                                
                            -- elseif CastSpellUnits(
                            --         _spell.flash_heal
                            --             ,_unitids.standard_friendly
                            --             ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                            --             ,{
                            --                 SpellUnit_AliveAndFriendly
                            --                 ,SpellUnit_NoRecasting
                            --                 ,SpellUnit_HealthBelow80
                            --                 ,SpellUnit_RangeCheck
                            --             }
                            --             ,RankUnits_MaxHealthDeficitPercent
                            --         ) then --print("Flash Heal")

    
                            elseif CastSpellUnits(
                                _spell.renew
                                ,_unitids.raid_friendly
                                ,RemainingCooldown(_spell.renew) < 0.5
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_ExpiringOrExpired
                                    ,SpellUnit_HealthBelow90
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_NoRecasting
                                }
                                ,RankUnits_MaxHealthDeficitPercent
                            ) then --print("Renew")        


                            elseif CastSpellUnits(
                                _spell.smite
                                    ,_unitids.standard_hostile
                                    ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Smite")
                                
                            --+++Attack and Target Type Block END+++                                
                            
                                

                            elseif CastSpellUnits(
                                _spell.flash_heal
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow95
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
                                                                    
                                --+++Penance and BLOCK START+++                                                
                            elseif CastSpellUnits(
                                _spell.penance
                                    ,_unitids.standard_hostile
                                    ,RemainingCooldown(_spell.penance) < 0.5 and not have_twilight_corruption_talent and not have_harsh_discipline_talent
                                    ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Penance attack")  


                                                                    

                            elseif CastSpellUnits(
                                _spell.penance
                                    ,_unitids.standard_hostile
                                    ,RemainingCooldown(_spell.penance) < 0.5 and (((have_shadow_covenant_talent) and _unit.player.buff["Shadow Covenant"].remaining > 0) or (have_harsh_discipline_talent and _unit.player.buff["Harsh Discipline"].remaining > 0))
                                    ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Penance attack")  

                                --+++Penance BLOCK END+++                                                                       

                                --+++Generic Block Start+++
                            elseif CastSpellUnits(
                                _spell.power_word_life
                                    ,_unitids.raid_friendly
                                    ,RemainingCooldown(_spell.power_word_life) < 0.5 and have_power_word_life_talent and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow35
                                        ,SpellUnit_RangeCheck                                                           
                                    }
                                ) then --print("Power Word: Life")

                            -- elseif CastSpellUnits(
                            --     _spell.power_word_solace
                            --     ,_unitids.standard_hostile
                            --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                            --     ,{
                            --         SpellUnit_UnitAliveAndHostile
                            --         ,SpellUnit_RangeCheck
                            --         ,SpellUnit_ValidHarm
                            --     }
                            --     ) then --print("Power Word: Solsace")
        
                            elseif CastSpellUnits(
                                _spell.pain_suppression
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow30
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_Expired
                                    }
                                ) then --print("Pain Suppression")
        


                            elseif CastSpellUnits(
                                _spell.flash_heal
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_NoRecasting
                                        ,SpellUnit_HealthBelow95
                                        ,SpellUnit_RangeCheck
                                        
                                    }
                                        ,RankUnits_MaxHealthDeficitPercent
                                ) then  --print("Surge of Light flash heal")
    
        
                            elseif CastSpellUnits(
                                _spell.rapture
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.rapture) < 0.5 and combat and have_rapture_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                        ,SpellUnit_HealthBelow30
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Rapture")
         

                            elseif CastSpellUnits(
                                _spell.shield
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                        --,SpellUnit_WeakenedSoulExpired
                                        ,SpellUnit_RangeCheck
                                        ,Botchuloz_SpellUnit_Help_Rank_Shield
                                    }
                                ) then print("Power Word: Shield Normal line 3056")

        
                                                                        
                                elseif CastSpellUnits(
                                    _spell.evangelism
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 5 and have_evangelism_talent and combat
                                    ,{
                                        --SpellUnit_MyBuffExpiringUnder5
                                    }
                                    ) then --print("Evangelism")
                                        
                                elseif CastSpellUnits(
                                    _spell.power_word_barrier
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat and have_power_word_barrier_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow30
                                    }
                                    ) then --print("Power Word: Barrier")
        
                                elseif CastSpellUnits(
                                    _spell.luminous_barrier
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat and have_luminous_barrier_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_VeryLowHealth
                                    }
                                    ) then --print("Luminous Barrier")
            
    
                                elseif CastSpellUnits(
                                    _spell.shadowfiend
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_disc_talent and mana_percent <0.80 and combat
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Shadowfiend")
        
                                elseif CastSpellUnits(
                                    _spell.mindbender
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_disc_talent and mana_percent <0.95 and combat
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Mindbender")
    
    
                                        elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain")   
            

                                elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain refresh") 
        

                            elseif CastSpellUnits(
                                _spell.power_word_radiance
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and GroupHealthDeficit() > 12000 and stationary and have_power_word_radiance_talent and not have_ultimate_radiance_pvp_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_HealthBelow90
                                        ,SpellUnit_NoRecasting
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Power Word: Radiance")

                            elseif CastSpellUnits(
                                _spell.power_word_radiance
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and GroupHealthDeficit() > 12000 and have_power_word_radiance_talent and have_ultimate_radiance_pvp_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_HealthBelow90
                                        ,SpellUnit_NoRecasting
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Power Word: Radiance instant cast")

                                        
                                                    
                            --+++Generic Block END+++


                                            --+++DPS BLOCK START+++
                                            -- elseif CastSpellUnits(
                                            --     _spell.schism
                                            --     ,_unitids.target
                                            --     ,RemainingCooldown(_spell.schism) < 0.5 and stationary and have_schism_talent
                                            --     ,{
                                            --         SpellUnit_UnitAliveAndHostile
                                            --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                            --         ,SpellUnit_ValidHarm
                                            --     }
                                            -- ) then --print("Schism")

                                            -- elseif CastSpellUnits(
                                            --     _spell.lights_wrath
                                            --         ,_unitids.standard_hostile
                                            --         ,RemainingCooldown(_spell.lights_wrath) < 0.5 and stationary and have_lights_wrath_talent
                                            --         ,{
                                            --         SpellUnit_UnitAliveAndHostile
                                            --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                            --         ,SpellUnit_ValidHarm
                                            --         }
                                            --         ) then --print("Light's Wrath")  

                                            elseif CastSpellUnits(
                                                _spell.mindblast
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Mind Blast")

                                            elseif CastSpellUnits(
                                                _spell.shadow_word_death
                                                        ,_unitids.target
                                                        ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and have_shadow_word_death_talent and player_health_perc > 0.45 and _unit.target.health.percent < 0.2
                                                        ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                        }
                                                    ) then --print("Shadow Word: Death")
                                                                                

                                            -- elseif CastSpellUnits(
                                            --     _spell.shadow_word_death
                                            --             ,_unitids.target
                                            --             ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and have_shadow_word_death_talent and player_health_perc > 0.40 and have_shadow_covenant_talent and _unit.player.buff["Shadow Covenant"].remaining > 0
                                            --             ,{
                                            --             SpellUnit_UnitAliveAndHostile
                                            --             ,SpellUnit_RangeCheck
                                            --             ,SpellUnit_ValidHarm
                                            --             }
                                            --         ) then --print("Shadow Word: Death with Shadow Covenant")


                                            elseif CastSpellUnits(
                                                _spell.smite
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Smite")
                                            --+++DPS BLOCK END+++
                                            --++Halo and Divine Star START+++
                                            elseif CastSpellUnits(
                                                _spell.divine_star
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat and not have_twilight_corruption_talent and not have_harsh_discipline_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                    }
                                                ) then --print("Divine Star Normal")

                                            elseif CastSpellUnits(
                                                _spell.halo
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and not have_twilight_corruption_talent and not have_harsh_discipline_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                    }
                                                ) then --print("Halo Normal")


                                            elseif CastSpellUnits(
                                                _spell.divine_star
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and (((have_shadow_covenant_talent) and _unit.player.buff["Shadow Covenant"].remaining > 0) or (have_harsh_discipline_talent and _unit.player.buff["Harsh Discipline"].remaining > 0))
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                    }
                                                ) then --print("Divine Star DPS Talents")

                                            elseif CastSpellUnits(
                                                _spell.halo
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and (((have_shadow_covenant_talent) and _unit.player.buff["Shadow Covenant"].remaining > 0) or (have_harsh_discipline_talent and _unit.player.buff["Harsh Discipline"].remaining > 0))
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                    }
                                                ) then --print("Halo DPS Talents")
                                            --++Halo and Divine Star END+++



                                            elseif CastSpellUnits(
                                                _spell.renew
                                                ,_unitids.raid_friendly
                                                ,RemainingCooldown(_spell.renew) < 0.5
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    ,SpellUnit_HealthBelow90
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_NoRecasting
                                                }
                                                ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Renew")        


                                            elseif CastSpellUnits(
                                                _spell.smite
                                                    ,_unitids.standard_hostile
                                                    ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Smite")
                                                
                                            --+++Attack and Target Type Block END+++                                
                                            
                                                

                                            elseif CastSpellUnits(
                                                _spell.flash_heal
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_HealthBelow95
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
                                                        

                                    -- elseif CastSpellUnits(
                                    --     _spell.power_word_solace
                                    --     ,_unitids.standard_hostile
                                    --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                                    --     ,{
                                    --         SpellUnit_UnitAliveAndHostile
                                    --         ,SpellUnit_RangeCheck
                                    --         ,SpellUnit_ValidHarm
                                    --     }
                                    --     ) then --print("Schism")
                    

                                    elseif CastSpellUnits(
                                        _spell.rapture
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.rapture) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                ,SpellUnit_HealthBelow30
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Rapture")
                        

                                    elseif CastSpellUnits(
                                        _spell.shield
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                --,SpellUnit_WeakenedSoulExpired
                                                ,SpellUnit_RangeCheck
                                                ,Botchuloz_SpellUnit_Help_Rank_Shield
                                            }
                                        ) then print("Power Word: Shield Normal line 3366")

                                    elseif CastSpellUnits(
                                        _spell.shield
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.shield) < 0.5 and _unit.player.buff["Rapture"].remaining > 0 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                ,SpellUnit_RangeCheck
                                                ,Botchuloz_SpellUnit_Help_Rank_Shield
                                                --no weakened soul
                                            }
                                        ) then print("Power Word: Shield Rapture")

                                    elseif CastSpellUnits(
                                        _spell.power_word_radiance
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and stationary and not have_ultimate_radiance_pvp_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow90
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Power Word: Radiance")

                                    elseif CastSpellUnits(
                                        _spell.power_word_radiance
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and have_ultimate_radiance_pvp_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow90
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Power Word: Radiance instant cast")


                                        elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain")   
            

                                elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain refresh") 


                                        
                                    elseif CastSpellUnits(
                                        _spell.penance
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.penance) < 0.5
                                            ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Penance attack")  


                                        
                                    -- elseif CastSpellUnits(
                                    --     _spell.shadow_covenant
                                    --         ,_unitids.standard_friendly
                                    --         ,RemainingCooldown(_spell.shadow_covenant) < 0.5 and have_shadow_covenant_talent and combat
                                    --         ,{
                                    --         SpellUnit_AliveAndFriendly
                                    --         ,SpellUnit_RangeCheck
                                    --         }
                                    --         ) then --print("Shadow Convenant")      ----------------------------------------------------need ranking heal----------------------------------------
                                                ----------------------------------------------------need ranking heal---------------------------------------- 


                                    elseif CastSpellUnits(
                                        _spell.mindblast
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Mind Blast")

                                                                        
                                    elseif CastSpellUnits(
                                        _spell.evangelism
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 5 and have_evangelism_talent and combat
                                        ,{
                                            --SpellUnit_MyBuffExpiringUnder5
                                        }
                                        ) then --print("Evangelism")
                                            
                                    elseif CastSpellUnits(
                                        _spell.power_word_barrier
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_HealthBelow30
                                        }
                                        ) then --print("Power Word: Barrier")

                                    elseif CastSpellUnits(
                                        _spell.divine_star
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Divine Star")

                                    elseif CastSpellUnits(
                                        _spell.halo
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Divine Star")


                                    elseif CastSpellUnits(
                                        _spell.shadowfiend
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_disc_talent and mana_percent <0.80 and combat
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Shadowfiend")

                                    elseif CastSpellUnits(
                                        _spell.mindbender
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_disc_talent and mana_percent <0.95 and combat
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Mindbender")
            
                                            


                                    elseif CastSpellUnits(
                                            _spell.flash_heal
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow80
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Shadow Mend")
                                            
                                    elseif CastSpellUnits(
                                        _spell.pain_suppression
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow30
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Pain Suppression")

                                

                                    --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  
            
                                    elseif CastSpellUnits(
                                        _spell.flash_heal
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Shadow Mend")
            
                                                        
                            else _global.Off()
                            end




                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)

                                    if 1 == 0 then
                                                

                                    -- elseif CastSpellUnits(
                                    --     _spell.power_word_solace
                                    --     ,_unitids.target
                                    --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                                    --     ,{
                                    --         SpellUnit_UnitAliveAndHostile
                                    --         ,SpellUnit_RangeCheck
                                    --         ,SpellUnit_ValidHarm
                                    --     }
                                    --     ) then --print("Schism")
                    

                                    elseif CastSpellUnits(
                                        _spell.rapture
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.rapture) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                ,SpellUnit_HealthBelow30
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Rapture")
                        

                                    elseif CastSpellUnits(
                                        _spell.shield
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                --,SpellUnit_WeakenedSoulExpired
                                                ,SpellUnit_RangeCheck
                                                ,Botchuloz_SpellUnit_Help_Rank_Shield
                                            }
                                        ) then print("Power Word: Shield Normal line 3606")

                                    elseif CastSpellUnits(
                                        _spell.shield
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.shield) < 0.5 and _unit.player.buff["Rapture"].remaining > 0 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                ,SpellUnit_RangeCheck
                                                ,Botchuloz_SpellUnit_Help_Rank_Shield
                                                --no weakened soul
                                            }
                                        ) then print("Power Word: Shield Rapture")


                                        elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain")   
            

                                elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain refresh") 

                                    elseif CastSpellUnits(
                                        _spell.power_word_radiance
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and stationary and not have_ultimate_radiance_pvp_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow90
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Power Word: Radiance")

                                    elseif CastSpellUnits(
                                        _spell.power_word_radiance
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and have_ultimate_radiance_pvp_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow90
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Power Word: Radiance instant cast")


                                        
                                    elseif CastSpellUnits(
                                        _spell.penance
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.penance) < 0.5
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_HealthBelow30
                                            }
                                            ) then --print("Penance Heal Low HP")
                                                                            

                                    elseif CastSpellUnits(
                                        _spell.penance
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.penance) < 0.5 and not have_contrition_talent
                                            ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Penance attack")  

                
                                    elseif CastSpellUnits(
                                        _spell.penance
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.penance) < 0.5 and have_contrition_talent and combat
                                            ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_HealthBelow80
                                            }
                                            ) then --print("Penance and Contrition Heal")      ----------------------------------------------------need ranking heal----------------------------------------
                                                ----------------------------------------------------need ranking heal---------------------------------------- 

                                    -- elseif CastSpellUnits(
                                    --     _spell.schism
                                    --     ,_unitids.target
                                    --     ,RemainingCooldown(_spell.schism) < 0.5 and stationary and have_schism_talent
                                    --     ,{
                                    --         SpellUnit_UnitAliveAndHostile
                                    --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                    --         ,SpellUnit_ValidHarm
                                    --     }
                                    -- ) then --print("Schism")

                                        
                                    -- elseif CastSpellUnits(
                                    --     _spell.shadow_covenant
                                    --         ,_unitids.standard_friendly
                                    --         ,RemainingCooldown(_spell.shadow_covenant) < 0.5 and have_shadow_covenant_talent and combat
                                    --         ,{
                                    --         SpellUnit_AliveAndFriendly
                                    --         ,SpellUnit_RangeCheck
                                    --         }
                                    --         ) then --print("Shadow Convenant")      ----------------------------------------------------need ranking heal----------------------------------------
                                                ----------------------------------------------------need ranking heal---------------------------------------- 


                                    elseif CastSpellUnits(
                                        _spell.mindblast
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Mind Blast")

                                    elseif CastSpellUnits(
                                        _spell.shadow_word_death
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                            ) then --print("Shadow Word: Death")
                                                                        

                                    -- elseif CastSpellUnits(
                                    --     _spell.shadow_word_death
                                    --             ,_unitids.target
                                    --             ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and player_health_perc > 0.45 and have_shadow_covenant_talent and _unit.player.buff["Shadow Covenant"].remaining > 0
                                    --             ,{
                                    --                 SpellUnit_UnitAliveAndHostile
                                    --             ,SpellUnit_RangeCheck
                                    --             ,SpellUnit_ValidHarm
                                    --             }
                                    --         ) then --print("Shadow Word: Death with Shadow Covenant")
                                                                        
                                    elseif CastSpellUnits(
                                        _spell.evangelism
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 5 and have_evangelism_talent and combat
                                        ,{
                                            --SpellUnit_MyBuffExpiringUnder5
                                        }
                                        ) then --print("Evangelism")
                                            
                                    elseif CastSpellUnits(
                                        _spell.power_word_barrier
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_HealthBelow30
                                        }
                                        ) then --print("Power Word: Barrier")

                                    elseif CastSpellUnits(
                                        _spell.divine_star
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Divine Star")

                                    elseif CastSpellUnits(
                                        _spell.halo
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Divine Star")


                                    elseif CastSpellUnits(
                                        _spell.shadowfiend
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_disc_talent and mana_percent <0.80 and combat
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Shadowfiend")

                                    elseif CastSpellUnits(
                                        _spell.mindbender
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_disc_talent and mana_percent <0.95 and combat
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Mindbender")
            
                                            


                                    elseif CastSpellUnits(
                                            _spell.flash_heal
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow50
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Shadow Mend")
            


                                    elseif CastSpellUnits(
                                        _spell.smite
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Smite")
                
                                    -- elseif CastSpellUnits(
                                    --     _spell.flash_heal
                                    --         ,_unitids.standard_friendly
                                    --         ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and have_shadow_covenant_talent and _unit.player.buff["Shadow Covenant"].remaining > 0
                                    --         ,{
                                    --             SpellUnit_AliveAndFriendly
                                    --             ,SpellUnit_HealthBelow90
                                    --             ,SpellUnit_RangeCheck
                                    --         }
                                    --     ) then --print("Shadow Mend")
                                            
                                    elseif CastSpellUnits(
                                        _spell.pain_suppression
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow30
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Pain suppression")

                                

                                    --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  
            
                                    elseif CastSpellUnits(
                                        _spell.flash_heal
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Shadow Mend")
            
                                                        
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
                                                                                        

                                        -- elseif CastSpellUnits(
                                        --     _spell.power_word_solace
                                        --     ,_unitids.target
                                        --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                                        --     ,{
                                        --         SpellUnit_UnitAliveAndHostile
                                        --         ,SpellUnit_RangeCheck
                                        --         ,SpellUnit_ValidHarm
                                        --     }
                                        --     ) then --print("Schism")
                        

                                        elseif CastSpellUnits(
                                            _spell.rapture
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.rapture) < 0.5 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    ,SpellUnit_HealthBelow30
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Rapture")
                            

                                        elseif CastSpellUnits(
                                            _spell.shield
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    --,SpellUnit_WeakenedSoulExpired
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then print("Power Word: Shield Normal line 3928")

                                        elseif CastSpellUnits(
                                            _spell.shield
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.shield) < 0.5 and _unit.player.buff["Rapture"].remaining > 0 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    ,SpellUnit_RangeCheck
                                                    ,Botchuloz_SpellUnit_Help_Rank_Shield
                                                    --no weakened soul
                                                }
                                            ) then print("Power Word: Shield Rapture")


                                            elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                            ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                             (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                            ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                            ) then --print("Shadow Word: Pain")   
                
    
                                    elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                            ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                             (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                            ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                            ) then --print("Shadow Word: Pain refresh") 
    
                                        elseif CastSpellUnits(
                                            _spell.power_word_radiance
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and have_ultimate_radiance_pvp_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow90
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Power Word: Radiance instant cast")


                                                                                

                                        elseif CastSpellUnits(
                                            _spell.penance
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.penance) < 0.5
                                                ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Penance attack")  

                    

                                        -- elseif CastSpellUnits(
                                        --     _spell.schism
                                        --     ,_unitids.target
                                        --     ,RemainingCooldown(_spell.schism) < 0.5 and stationary and have_schism_talent
                                        --     ,{
                                        --         SpellUnit_UnitAliveAndHostile
                                        --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                        --         ,SpellUnit_ValidHarm
                                        --     }
                                        -- ) then --print("Schism")

                            
                                        elseif CastSpellUnits(
                                            _spell.mindblast
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Mind Blast")

                                        elseif CastSpellUnits(
                                            _spell.shadow_word_death
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                ) then --print("Shadow Word: Death")
                                                                            

                                        -- elseif CastSpellUnits(
                                        --     _spell.shadow_word_death
                                        --             ,_unitids.target
                                        --             ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and player_health_perc > 0.45 and have_shadow_covenant_talent and _unit.player.buff["Shadow Covenant"].remaining > 0
                                        --             ,{
                                        --                 SpellUnit_UnitAliveAndHostile
                                        --             ,SpellUnit_RangeCheck
                                        --             ,SpellUnit_ValidHarm
                                        --             }
                                        --         ) then --print("Shadow Word: Death with Shadow Covenant")
                                                                            
                                        elseif CastSpellUnits(
                                            _spell.evangelism
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 5 and have_evangelism_talent and combat
                                            ,{
                                                --SpellUnit_MyBuffExpiringUnder5
                                            }
                                            ) then --print("Evangelism")
                                                
                                        elseif CastSpellUnits(
                                            _spell.power_word_barrier
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow30
                                            }
                                            ) then --print("Power Word: Barrier")

                                        elseif CastSpellUnits(
                                            _spell.divine_star
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Divine Star")

                                        elseif CastSpellUnits(
                                            _spell.halo
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Divine Star")


                                        elseif CastSpellUnits(
                                            _spell.shadowfiend
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_disc_talent and mana_percent <0.80 and combat
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Shadowfiend")

                                        elseif CastSpellUnits(
                                            _spell.mindbender
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_disc_talent and mana_percent <0.95 and combat
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Mindbender")

                                                


                                        elseif CastSpellUnits(
                                                _spell.flash_heal
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_HealthBelow30
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Shadow Mend")



                                        elseif CastSpellUnits(
                                            _spell.mind_flay
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.mind_flay) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_Debuff_ExpiringNextGCDOrExpired
                                                ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Mind Sear")
                    
                                                                                        
                                        elseif CastSpellUnits(
                                            _spell.pain_suppression
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow30
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Pain suppression")

                                    

                                        --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                                        elseif CastSpellUnits(
                                            _spell.flash_heal
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Shadow Mend")
                
                                                            
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
                                    _spell.penance
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.penance) < 0.5
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_MediumHealth
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                        ) then --print("Penance Heal")
                                                
                                    --+++Generic Block Start+++
                            elseif CastSpellUnits(
                                _spell.power_word_life
                                    ,_unitids.raid_friendly
                                    ,RemainingCooldown(_spell.power_word_life) < 0.5 and have_power_word_life_talent and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow35
                                        ,SpellUnit_RangeCheck                                                           
                                    }
                                ) then --print("Power Word: Life")

                            -- elseif CastSpellUnits(
                            --     _spell.power_word_solace
                            --     ,_unitids.standard_hostile
                            --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                            --     ,{
                            --         SpellUnit_UnitAliveAndHostile
                            --         ,SpellUnit_RangeCheck
                            --         ,SpellUnit_ValidHarm
                            --     }
                            --     ) then --print("Power Word: Solsace")
        
                            elseif CastSpellUnits(
                                _spell.pain_suppression
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow30
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_Expired
                                    }
                                ) then --print("Pain Suppression")
        

                                elseif CastSpellUnits(
                                    _spell.flash_heal
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            --,SpellUnit_NoRecasting
                                            ,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                            
                                        }
                                            ,RankUnits_MaxHealthDeficitPercent
                                    ) then  --print("Surge of Light flash heal")
    
        
                            elseif CastSpellUnits(
                                _spell.rapture
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.rapture) < 0.5 and combat and have_rapture_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                        ,SpellUnit_HealthBelow30
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Rapture")
         

                            elseif CastSpellUnits(
                                _spell.shield
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                        --,SpellUnit_WeakenedSoulExpired
                                        ,SpellUnit_RangeCheck
                                        ,Botchuloz_SpellUnit_Help_Rank_Shield
                                    }
                                ) then print("Power Word: Shield Normal line 4257")

      
                                                                        
                                elseif CastSpellUnits(
                                    _spell.evangelism
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 5 and have_evangelism_talent and combat
                                    ,{
                                        --SpellUnit_MyBuffExpiringUnder5
                                    }
                                    ) then --print("Evangelism")
                                        
                                elseif CastSpellUnits(
                                    _spell.power_word_barrier
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat and have_power_word_barrier_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow30
                                    }
                                    ) then --print("Power Word: Barrier")
        
                                elseif CastSpellUnits(
                                    _spell.luminous_barrier
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat and have_luminous_barrier_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_VeryLowHealth
                                    }
                                    ) then --print("Luminous Barrier")
            
    
                                elseif CastSpellUnits(
                                    _spell.shadowfiend
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_disc_talent and mana_percent <0.80 and combat
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Shadowfiend")
        
                                elseif CastSpellUnits(
                                    _spell.mindbender
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_disc_talent and mana_percent <0.95 and combat
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Mindbender")
    
    
                                        elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain")   
            

                                elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain refresh") 
        

                            elseif CastSpellUnits(
                                _spell.power_word_radiance
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and GroupHealthDeficit() > 12000 and stationary and have_power_word_radiance_talent and not have_ultimate_radiance_pvp_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_HealthBelow90
                                        ,SpellUnit_NoRecasting
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Power Word: Radiance")

                            elseif CastSpellUnits(
                                _spell.power_word_radiance
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and GroupHealthDeficit() > 12000 and have_power_word_radiance_talent and have_ultimate_radiance_pvp_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_HealthBelow90
                                        ,SpellUnit_NoRecasting
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Power Word: Radiance instant cast")


                                        
                                                    
                            --+++Generic Block END+++
                                        

                            -- --++Halo and Divine Star START+++
                            elseif CastSpellUnits(
                                _spell.divine_star
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat and not have_twilight_corruption_talent and not have_harsh_discipline_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Divine Star Normal")

                            elseif CastSpellUnits(
                                _spell.halo
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and not have_twilight_corruption_talent and not have_harsh_discipline_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Halo Normal")


                            elseif CastSpellUnits(
                                _spell.divine_star
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and (((have_shadow_covenant_talent) and _unit.player.buff["Shadow Covenant"].remaining > 0) or (have_harsh_discipline_talent and _unit.player.buff["Harsh Discipline"].remaining > 0))
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Divine Star DPS Talents")

                            elseif CastSpellUnits(
                                _spell.halo
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.halo) < 0.5  and have_halo_holy_disc_talent and combat and (((have_shadow_covenant_talent) and _unit.player.buff["Shadow Covenant"].remaining > 0) or (have_harsh_discipline_talent and _unit.player.buff["Harsh Discipline"].remaining > 0))
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Halo DPS Talents")
                            -- --++Halo and Divine Star END+++



                            --+++Attack and Target Type Block END+++                                
                            elseif CastSpellUnits(
                                    _spell.flash_heal
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_NoRecasting
                                            ,SpellUnit_HealthBelow80
                                            ,SpellUnit_RangeCheck
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                    ) then --print("Flash Heal")

                            elseif CastSpellUnits(
                                _spell.smite
                                    ,_unitids.standard_hostile
                                    ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Smite")
                    
    
                            elseif CastSpellUnits(
                                _spell.renew
                                ,_unitids.raid_friendly
                                ,RemainingCooldown(_spell.renew) < 0.5
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_ExpiringOrExpired
                                    ,SpellUnit_HealthBelow90
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_NoRecasting
                                }
                                ,RankUnits_MaxHealthDeficitPercent
                            ) then --print("Renew")        

                            --+++Attack and Target Type Block END+++                                
                            
                                

                            elseif CastSpellUnits(
                                _spell.flash_heal
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow95
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Flash Heal OOC")


                                            
                                --+++++++++++PVP START+++++++++++

                                elseif CastSpellUnits(
                                    _spell.archangel
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 3 and have_archangel_pvp_talent and combat
                                    ,{
                                        --SpellUnit_MyBuffExpiringUnder5
                                    }
                                    ) then --print("Evangelism")

                                elseif CastSpellUnits(
                                    _spell.dark_archangel
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 8 and have_dark_archangel_pvp_talent and combat
                                    ,{
                                        --SpellUnit_MyBuffExpiringUnder5
                                    }
                                    ) then --print("Evangelism")

                                elseif CastSpellUnits(
                                    _spell.inner_light
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.inner_light) < 0.5 and not combat and have_inner_light_and_shadow_talent
                                    ,{
                                        SpellUnit_MyBuffExpired
                                    }
                                    ) then --print("Inner Light")                            
                
                                --+++++++++++PVP END+++++++++++
                                                    
                        else _global.Off()
                        end



                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)

                                    if 1 == 0 then
                                                
                                    --+++Penance BLOCK END+++                                                                       
                                elseif CastSpellUnits(
                                    _spell.penance
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.penance) < 0.5
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_HealthBelow20
                                        }
                                        ) then --print("Penance Heal Low HP")
    
                                            
                                elseif CastSpellUnits(
                                    _spell.penance
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.penance) < 0.5 and have_contrition_talent and combat
                                        ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_MediumHealth
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                        ) then --print("Penance and Contrition Heal")
    
                    
    
                                elseif CastSpellUnits(
                                    _spell.penance
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.penance) < 0.5 and not have_contrition_talent and not have_twilight_corruption_talent and not have_harsh_discipline_talent 
                                        ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Penance attack")  
                                                                     
    
                                elseif CastSpellUnits(
                                    _spell.penance
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.penance) < 0.5 and (((have_shadow_covenant_talent) and _unit.player.buff["Shadow Covenant"].remaining > 0) or (have_harsh_discipline_talent and _unit.player.buff["Harsh Discipline"].remaining > 0))
                                        ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Penance attack")  
    
                                --+++Penance BLOCK END+++                                                                       
                            
                                -- elseif CastSpellUnits(
                                --         _spell.power_word_solace
                                --         ,_unitids.target
                                --         ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                                --         ,{
                                --             SpellUnit_UnitAliveAndHostile
                                --             ,SpellUnit_RangeCheck
                                --             ,SpellUnit_ValidHarm
                                --         }
                                --         ) then --print("Schism")
                    
        
                                        --+++Generic Block Start+++
                                    elseif CastSpellUnits(
                                        _spell.power_word_life
                                            ,_unitids.raid_friendly
                                            ,RemainingCooldown(_spell.power_word_life) < 0.5 and have_power_word_life_talent and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow35
                                                ,SpellUnit_RangeCheck                                                           
                                            }
                                        ) then --print("Power Word: Life")
        
                                    -- elseif CastSpellUnits(
                                    --     _spell.power_word_solace
                                    --     ,_unitids.standard_hostile
                                    --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                                    --     ,{
                                    --         SpellUnit_UnitAliveAndHostile
                                    --         ,SpellUnit_RangeCheck
                                    --         ,SpellUnit_ValidHarm
                                    --     }
                                    --     ) then --print("Power Word: Solsace")
                
                                    elseif CastSpellUnits(
                                        _spell.pain_suppression
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow30
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_Expired
                                            }
                                        ) then --print("Pain Suppression")
                
                                    elseif CastSpellUnits(
                                        _spell.flash_heal
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_NoRecasting
                                                ,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                                
                                            }
                                                ,RankUnits_MaxHealthDeficitPercent
                                        ) then  --print("Surge of Light flash heal")
                
                                    elseif CastSpellUnits(
                                        _spell.rapture
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.rapture) < 0.5 and combat and have_rapture_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                ,SpellUnit_HealthBelow30
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Rapture")
                 
        
                                    elseif CastSpellUnits(
                                        _spell.shield
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                --,SpellUnit_WeakenedSoulExpired
                                                ,SpellUnit_RangeCheck
                                                ,Botchuloz_SpellUnit_Help_Rank_Shield
                                            }
                                        ) then print("Power Word: Shield Normal line 4635")
        
                
                                                                                
                                        elseif CastSpellUnits(
                                            _spell.evangelism
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 5 and have_evangelism_talent and combat
                                            ,{
                                                --SpellUnit_MyBuffExpiringUnder5
                                            }
                                            ) then --print("Evangelism")
                                                
                                        elseif CastSpellUnits(
                                            _spell.power_word_barrier
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat and have_power_word_barrier_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow30
                                            }
                                            ) then --print("Power Word: Barrier")
                
                                        elseif CastSpellUnits(
                                            _spell.luminous_barrier
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat and have_luminous_barrier_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_VeryLowHealth
                                            }
                                            ) then --print("Luminous Barrier")
                    
            
                                        elseif CastSpellUnits(
                                            _spell.shadowfiend
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_disc_talent and mana_percent <0.80 and combat
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Shadowfiend")
                
                                        elseif CastSpellUnits(
                                            _spell.mindbender
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_disc_talent and mana_percent <0.95 and combat
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Mindbender")
            
            
            
            
                                                    
            
                                                elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                                ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                                 (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                                ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                                ) then --print("Shadow Word: Pain")   
                    
        
                                        elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                                ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                                 (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                                ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                                ) then --print("Shadow Word: Pain refresh") 
                        
        
                                    elseif CastSpellUnits(
                                        _spell.power_word_radiance
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and GroupHealthDeficit() > 12000 and stationary and have_power_word_radiance_talent and not have_ultimate_radiance_pvp_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_HealthBelow90
                                                ,SpellUnit_NoRecasting
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Power Word: Radiance")
        
                                    elseif CastSpellUnits(
                                        _spell.power_word_radiance
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and GroupHealthDeficit() > 12000 and have_power_word_radiance_talent and have_ultimate_radiance_pvp_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_HealthBelow90
                                                ,SpellUnit_NoRecasting
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Power Word: Radiance instant cast")
        
                                                            
                                    --+++Generic Block END+++
        
                                    --+++DPS BLOCK START+++
        
                                    elseif CastSpellUnits(
                                        _spell.mindblast
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Mind Blast")
        
                                    elseif CastSpellUnits(
                                        _spell.shadow_word_death
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and have_shadow_word_death_talent and player_health_perc > 0.45 and _unit.target.health.percent < 0.2
                                                ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                            ) then --print("Shadow Word: Death")
                                                                        
        
                                    -- elseif CastSpellUnits(
                                    --     _spell.shadow_word_death
                                    --             ,_unitids.target
                                    --             ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and have_shadow_word_death_talent and player_health_perc > 0.40 and have_shadow_covenant_talent and _unit.player.buff["Shadow Covenant"].remaining > 0
                                    --             ,{
                                    --             SpellUnit_UnitAliveAndHostile
                                    --             ,SpellUnit_RangeCheck
                                    --             ,SpellUnit_ValidHarm
                                    --             }
                                    --         ) then --print("Shadow Word: Death with Shadow Covenant")
        
        
                                    --+++DPS BLOCK END+++
                                    --++Halo and Divine Star START+++
                                    elseif CastSpellUnits(
                                        _spell.divine_star
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat and not have_twilight_corruption_talent and not have_harsh_discipline_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Divine Star Normal")
        
                                    elseif CastSpellUnits(
                                        _spell.halo
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and not have_twilight_corruption_talent and not have_harsh_discipline_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Halo Normal")
        
        
                                    elseif CastSpellUnits(
                                        _spell.divine_star
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.divine_star) < 0.5 and (((have_shadow_covenant_talent) and _unit.player.buff["Shadow Covenant"].remaining > 0) or (have_harsh_discipline_talent and _unit.player.buff["Harsh Discipline"].remaining > 0))
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Divine Star DPS Talents")
        
                                    elseif CastSpellUnits(
                                        _spell.halo
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and (((have_shadow_covenant_talent) and _unit.player.buff["Shadow Covenant"].remaining > 0) or (have_harsh_discipline_talent and _unit.player.buff["Harsh Discipline"].remaining > 0))
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Halo DPS Talents")

        
            
                                    elseif CastSpellUnits(
                                        _spell.renew
                                        ,_unitids.raid_friendly
                                        ,RemainingCooldown(_spell.renew) < 0.5
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                            ,SpellUnit_HealthBelow90
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_NoRecasting
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                    ) then --print("Renew")        
        
        
                                    elseif CastSpellUnits(
                                        _spell.smite
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Smite")
                                        
                                    --+++Attack and Target Type Block END+++                                
                                    
                                        
        
                                    elseif CastSpellUnits(
                                        _spell.flash_heal
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Flash Heal OOC")
        
                                                    

                                    --+++++++++++PVP START+++++++++++

                                    elseif CastSpellUnits(
                                        _spell.archangel
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 3 and have_archangel_pvp_talent and combat
                                        ,{
                                            --SpellUnit_MyBuffExpiringUnder5
                                        }
                                        ) then --print("Evangelism")

                                    elseif CastSpellUnits(
                                        _spell.dark_archangel
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 8 and have_dark_archangel_pvp_talent and combat
                                        ,{
                                            --SpellUnit_MyBuffExpiringUnder5
                                        }
                                        ) then --print("Evangelism")

                                    elseif CastSpellUnits(
                                        _spell.inner_light
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.inner_light) < 0.5 and not combat and have_inner_light_and_shadow_talent
                                        ,{
                                            Botchuloz_Inner_Light_Shadow_Missing
                                        }
                                        ) then --print("Inner Light")
                                    
                                    elseif CastSpellUnits(
                                        _spell.inner_shadow
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.inner_shadow) < 0.5 and not combat and have_inner_light_and_shadow_talent
                                        ,{
                                            SpellUnit_MyBuffExpired
                                            --Botchuloz_Inner_Light_Shadow_Missing
                                        }
                                        ) then --print("Inner Shadow")
                                
                    
                                    --+++++++++++PVP END+++++++++++
                                                        
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
                                                                                            
                                    -- elseif CastSpellUnits(
                                    --     _spell.power_word_solace
                                    --     ,_unitids.target
                                    --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                                    --     ,{
                                    --         SpellUnit_UnitAliveAndHostile
                                    --         ,SpellUnit_RangeCheck
                                    --         ,SpellUnit_ValidHarm
                                    --     }
                                    --     ) then --print("Schism")
                    

                                    elseif CastSpellUnits(
                                        _spell.rapture
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.rapture) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                ,SpellUnit_HealthBelow30
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Rapture")
                        

                                    elseif CastSpellUnits(
                                        _spell.shield
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                --,SpellUnit_WeakenedSoulExpired
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then print("Power Word: Shield Normal line 4948")

                                    elseif CastSpellUnits(
                                        _spell.shield
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.shield) < 0.5 and _unit.player.buff["Rapture"].remaining > 0 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                ,SpellUnit_RangeCheck
                                                ,Botchuloz_SpellUnit_Help_Rank_Shield
                                                --no weakened soul
                                            }
                                        ) then print("Power Word: Shield Rapture")


                                        elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain")   
            

                                elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                        ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                         (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                        ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                        ) then --print("Shadow Word: Pain refresh") 

                                    elseif CastSpellUnits(
                                        _spell.power_word_radiance
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and have_ultimate_radiance_pvp_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow90
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Power Word: Radiance instant cast")


                                                                            

                                    elseif CastSpellUnits(
                                        _spell.penance
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.penance) < 0.5
                                            ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Penance attack")  

                

                                    -- elseif CastSpellUnits(
                                    --     _spell.schism
                                    --     ,_unitids.target
                                    --     ,RemainingCooldown(_spell.schism) < 0.5 and stationary and have_schism_talent
                                    --     ,{
                                    --         SpellUnit_UnitAliveAndHostile
                                    --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                    --         ,SpellUnit_ValidHarm
                                    --     }
                                    -- ) then --print("Schism")

                        
                                    elseif CastSpellUnits(
                                        _spell.mindblast
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Mind Blast")

                                    elseif CastSpellUnits(
                                        _spell.shadow_word_death
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                            ) then --print("Shadow Word: Death")
                                                                        

                                    -- elseif CastSpellUnits(
                                    --     _spell.shadow_word_death
                                    --             ,_unitids.target
                                    --             ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and player_health_perc > 0.45 and have_shadow_covenant_talent and _unit.player.buff["Shadow Covenant"].remaining > 0
                                    --             ,{
                                    --                 SpellUnit_UnitAliveAndHostile
                                    --             ,SpellUnit_RangeCheck
                                    --             ,SpellUnit_ValidHarm
                                    --             }
                                    --         ) then --print("Shadow Word: Death with Shadow Covenant")
                                                                        
                                    elseif CastSpellUnits(
                                        _spell.evangelism
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 5 and have_evangelism_talent and combat
                                        ,{
                                            --SpellUnit_MyBuffExpiringUnder5
                                        }
                                        ) then --print("Evangelism")
                                            
                                    elseif CastSpellUnits(
                                        _spell.power_word_barrier
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_HealthBelow30
                                        }
                                        ) then --print("Power Word: Barrier")

                                    elseif CastSpellUnits(
                                        _spell.divine_star
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Divine Star")

                                    elseif CastSpellUnits(
                                        _spell.halo
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Divine Star")


                                    elseif CastSpellUnits(
                                        _spell.shadowfiend
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_disc_talent and mana_percent <0.80 and combat
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Shadowfiend")

                                    elseif CastSpellUnits(
                                        _spell.mindbender
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_disc_talent and mana_percent <0.95 and combat
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Mindbender")

                                            


                                    elseif CastSpellUnits(
                                            _spell.flash_heal
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow30
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Shadow Mend")



                                    elseif CastSpellUnits(
                                        _spell.mind_flay
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.mind_flay) < 0.5 and stationary
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_Debuff_ExpiringNextGCDOrExpired
                                            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                            ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Mind Sear")
                
                                                                                    
                                    elseif CastSpellUnits(
                                        _spell.pain_suppression
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow30
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Pain suppression")

                                

                                    --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                                    elseif CastSpellUnits(
                                        _spell.flash_heal
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Shadow Mend")

            
                                    --+++++++++++PVP START+++++++++++

                                    elseif CastSpellUnits(
                                        _spell.archangel
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 3 and have_archangel_pvp_talent and combat
                                        ,{
                                            --SpellUnit_MyBuffExpiringUnder5
                                        }
                                        ) then --print("Evangelism")

                                    elseif CastSpellUnits(
                                        _spell.dark_archangel
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 8 and have_dark_archangel_pvp_talent and combat
                                        ,{
                                            --SpellUnit_MyBuffExpiringUnder5
                                        }
                                        ) then --print("Evangelism")

                                    elseif CastSpellUnits(
                                        _spell.inner_light
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.inner_light) < 0.5 and not combat and have_inner_light_and_shadow_talent
                                        ,{
                                            Botchuloz_Inner_Light_Shadow_Missing
                                        }
                                        ) then --print("Inner Light")
                                    
                                    elseif CastSpellUnits(
                                        _spell.inner_shadow
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.inner_shadow) < 0.5 and not combat and have_inner_light_and_shadow_talent
                                        ,{
                                            SpellUnit_MyBuffExpired
                                            --Botchuloz_Inner_Light_Shadow_Missing
                                        }
                                        ) then --print("Inner Shadow")
                                
                    
                                    --+++++++++++PVP END+++++++++++
                                                        
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
                                                                        

                                        -- elseif CastSpellUnits(
                                        --     _spell.power_word_solace
                                        --     ,_unitids.standard_hostile
                                        --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                                        --     ,{
                                        --         SpellUnit_UnitAliveAndHostile
                                        --         ,SpellUnit_RangeCheck
                                        --         ,SpellUnit_ValidHarm
                                        --     }
                                        --     ) then --print("Schism")
                        

                                        elseif CastSpellUnits(
                                            _spell.rapture
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.rapture) < 0.5 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    ,SpellUnit_HealthBelow30
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Rapture")
                            

                                        elseif CastSpellUnits(
                                            _spell.shield
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    --,SpellUnit_WeakenedSoulExpired
                                                    ,SpellUnit_RangeCheck
                                                    ,Botchuloz_SpellUnit_Help_Rank_Shield
                                                }
                                            ) then print("Power Word: Shield Normal line 5266")

                                        elseif CastSpellUnits(
                                            _spell.shield
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.shield) < 0.5 and _unit.player.buff["Rapture"].remaining > 0 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    ,SpellUnit_RangeCheck
                                                    ,Botchuloz_SpellUnit_Help_Rank_Shield
                                                    --no weakened soul
                                                }
                                            ) then print("Power Word: Shield Rapture")


                                            elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                            ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                             (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                            ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                            ) then --print("Shadow Word: Pain")   
                
    
                                    elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                            ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                             (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                            ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                            ) then --print("Shadow Word: Pain refresh") 
    
                                        elseif CastSpellUnits(
                                            _spell.power_word_radiance
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and stationary and not have_ultimate_radiance_pvp_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow90
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Power Word: Radiance")

                                        elseif CastSpellUnits(
                                            _spell.power_word_radiance
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and have_ultimate_radiance_pvp_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow90
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Power Word: Radiance instant cast")


                                            
                                        elseif CastSpellUnits(
                                            _spell.penance
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.penance) < 0.5
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_HealthBelow30
                                                }
                                                ) then --print("Penance Heal Low HP")
                                                                                

                                        elseif CastSpellUnits(
                                            _spell.penance
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.penance) < 0.5 and not have_contrition_talent
                                                ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Penance attack")  

                    
                                        elseif CastSpellUnits(
                                            _spell.penance
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.penance) < 0.5 and have_contrition_talent and combat
                                                ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_HealthBelow80
                                                }
                                                ) then --print("Penance and Contrition Heal")      ----------------------------------------------------need ranking heal----------------------------------------
                                                    ----------------------------------------------------need ranking heal---------------------------------------- 

                                        -- elseif CastSpellUnits(
                                        --     _spell.schism
                                        --     ,_unitids.standard_hostile
                                        --     ,RemainingCooldown(_spell.schism) < 0.5 and stationary and have_schism_talent
                                        --     ,{
                                        --         SpellUnit_UnitAliveAndHostile
                                        --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                        --         ,SpellUnit_ValidHarm
                                        --     }
                                        -- ) then --print("Schism")

                                            
                                        -- elseif CastSpellUnits(
                                        --     _spell.shadow_covenant
                                        --         ,_unitids.standard_friendly
                                        --         ,RemainingCooldown(_spell.shadow_covenant) < 0.5 and have_shadow_covenant_talent and combat
                                        --         ,{
                                        --         SpellUnit_AliveAndFriendly
                                        --         ,SpellUnit_RangeCheck
                                        --         }
                                        --         ) then --print("Shadow Convenant")      ----------------------------------------------------need ranking heal----------------------------------------
                                        --             ----------------------------------------------------need ranking heal---------------------------------------- 


                                        elseif CastSpellUnits(
                                            _spell.mindblast
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Mind Blast")

                                        elseif CastSpellUnits(
                                            _spell.shadow_word_death
                                                    ,_unitids.standard_hostile
                                                    ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                ) then --print("Shadow Word: Death")
                                                                            

                                        -- elseif CastSpellUnits(
                                        --     _spell.shadow_word_death
                                        --             ,_unitids.standard_hostile
                                        --             ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and player_health_perc > 0.45 and have_shadow_covenant_talent and _unit.player.buff["Shadow Covenant"].remaining > 0
                                        --             ,{
                                        --                 SpellUnit_UnitAliveAndHostile
                                        --             ,SpellUnit_RangeCheck
                                        --             ,SpellUnit_ValidHarm
                                        --             }
                                        --         ) then --print("Shadow Word: Death with Shadow Covenant")
                                                                            
                                        elseif CastSpellUnits(
                                            _spell.evangelism
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 5 and have_evangelism_talent and combat
                                            ,{
                                                --SpellUnit_MyBuffExpiringUnder5
                                            }
                                            ) then --print("Evangelism")
                                                
                                        elseif CastSpellUnits(
                                            _spell.power_word_barrier
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow30
                                            }
                                            ) then --print("Power Word: Barrier")

                                        elseif CastSpellUnits(
                                            _spell.divine_star
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Divine Star")

                                        elseif CastSpellUnits(
                                            _spell.halo
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Divine Star")


                                        elseif CastSpellUnits(
                                            _spell.shadowfiend
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_disc_talent and mana_percent <0.80 and combat
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Shadowfiend")

                                        elseif CastSpellUnits(
                                            _spell.mindbender
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_disc_talent and mana_percent <0.95 and combat
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Mindbender")
                
                                                


                                        elseif CastSpellUnits(
                                                _spell.flash_heal
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_HealthBelow80
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Shadow Mend")
                


                                        elseif CastSpellUnits(
                                            _spell.smite
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Smite")
                                                
                                        elseif CastSpellUnits(
                                            _spell.pain_suppression
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow30
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Shadow Mend")

                                    

                                        --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                                        elseif CastSpellUnits(
                                            _spell.flash_heal
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Shadow Mend")
                                                            

                                        --+++++++++++PVP START+++++++++++

                                        elseif CastSpellUnits(
                                            _spell.archangel
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 3 and have_archangel_pvp_talent and combat
                                            ,{
                                                --SpellUnit_MyBuffExpiringUnder5
                                            }
                                            ) then --print("Evangelism")

                                        elseif CastSpellUnits(
                                            _spell.dark_archangel
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 8 and have_dark_archangel_pvp_talent and combat
                                            ,{
                                                --SpellUnit_MyBuffExpiringUnder5
                                            }
                                            ) then --print("Evangelism")

                                        elseif CastSpellUnits(
                                            _spell.inner_light
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.inner_light) < 0.5 and not combat and have_inner_light_and_shadow_talent
                                            ,{
                                                SpellUnit_MyBuffExpired
                                            }
                                            ) then --print("Inner Light")                            
                        
                                        --+++++++++++PVP END+++++++++++
                                                            
                                else _global.Off()
                                end





                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)
                                if 1 == 0 then
                                                        

                                -- elseif CastSpellUnits(
                                --     _spell.power_word_solace
                                --     ,_unitids.standard_hostile
                                --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                                --     ,{
                                --         SpellUnit_UnitAliveAndHostile
                                --         ,SpellUnit_RangeCheck
                                --         ,SpellUnit_ValidHarm
                                --     }
                                --     ) then --print("Schism")
                

                                elseif CastSpellUnits(
                                    _spell.rapture
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.rapture) < 0.5 and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                            ,SpellUnit_HealthBelow30
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Rapture")
                    

                                elseif CastSpellUnits(
                                    _spell.shield
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                            --,SpellUnit_WeakenedSoulExpired
                                            ,SpellUnit_RangeCheck
                                            ,Botchuloz_SpellUnit_Help_Rank_Shield
                                        }
                                    ) then print("Power Word: Shield Normal line 5607")

                                elseif CastSpellUnits(
                                    _spell.shield
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.shield) < 0.5 and _unit.player.buff["Rapture"].remaining > 0 and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                            ,SpellUnit_RangeCheck
                                            ,Botchuloz_SpellUnit_Help_Rank_Shield
                                            --no weakened soul
                                        }
                                    ) then print("Power Word: Shield Rapture")


                                    elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                    ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                     (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                    ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                    ) then --print("Shadow Word: Pain")   
        

                            elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                    ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                     (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                    ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                    ) then --print("Shadow Word: Pain refresh") 


                                elseif CastSpellUnits(
                                    _spell.power_word_radiance
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and stationary and not have_ultimate_radiance_pvp_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_HealthBelow90
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Power Word: Radiance")

                                elseif CastSpellUnits(
                                    _spell.power_word_radiance
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and have_ultimate_radiance_pvp_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_HealthBelow90
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Power Word: Radiance instant cast")


                                    
                                elseif CastSpellUnits(
                                    _spell.penance
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.penance) < 0.5
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_HealthBelow30
                                        }
                                        ) then --print("Penance Heal Low HP")
                                                                        

                                elseif CastSpellUnits(
                                    _spell.penance
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.penance) < 0.5 and not have_contrition_talent
                                        ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Penance attack")  

            
                                elseif CastSpellUnits(
                                    _spell.penance
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.penance) < 0.5 and have_contrition_talent and combat
                                        ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_HealthBelow80
                                        }
                                        ) then --print("Penance and Contrition Heal")      ----------------------------------------------------need ranking heal----------------------------------------
                                            ----------------------------------------------------need ranking heal---------------------------------------- 

                                -- elseif CastSpellUnits(
                                --     _spell.schism
                                --     ,_unitids.standard_hostile
                                --     ,RemainingCooldown(_spell.schism) < 0.5 and stationary and have_schism_talent
                                --     ,{
                                --         SpellUnit_UnitAliveAndHostile
                                --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                --         ,SpellUnit_ValidHarm
                                --     }
                                -- ) then --print("Schism")

                                    
                                -- elseif CastSpellUnits(
                                --     _spell.shadow_covenant
                                --         ,_unitids.standard_friendly
                                --         ,RemainingCooldown(_spell.shadow_covenant) < 0.5 and have_shadow_covenant_talent and combat
                                --         ,{
                                --         SpellUnit_AliveAndFriendly
                                --         ,SpellUnit_RangeCheck
                                --         }
                                --         ) then --print("Shadow Convenant")      ----------------------------------------------------need ranking heal----------------------------------------
                                            ----------------------------------------------------need ranking heal---------------------------------------- 


                                elseif CastSpellUnits(
                                    _spell.mindblast
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Mind Blast")

                                elseif CastSpellUnits(
                                    _spell.shadow_word_death
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                            }
                                        ) then --print("Shadow Word: Death")
                                                                    

                                -- elseif CastSpellUnits(
                                --     _spell.shadow_word_death
                                --             ,_unitids.standard_hostile
                                --             ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and player_health_perc > 0.45 and have_shadow_covenant_talent and _unit.player.buff["Shadow Covenant"].remaining > 0
                                --             ,{
                                --                 SpellUnit_UnitAliveAndHostile
                                --             ,SpellUnit_RangeCheck
                                --             ,SpellUnit_ValidHarm
                                --             }
                                --         ) then --print("Shadow Word: Death with Shadow Covenant")
                                                                    
                                elseif CastSpellUnits(
                                    _spell.evangelism
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 5 and have_evangelism_talent and combat
                                    ,{
                                        --SpellUnit_MyBuffExpiringUnder5
                                    }
                                    ) then --print("Evangelism")
                                        
                                elseif CastSpellUnits(
                                    _spell.power_word_barrier
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow30
                                    }
                                    ) then --print("Power Word: Barrier")

                                elseif CastSpellUnits(
                                    _spell.divine_star
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                        }
                                    ) then --print("Divine Star")

                                elseif CastSpellUnits(
                                    _spell.halo
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                        }
                                    ) then --print("Divine Star")


                                elseif CastSpellUnits(
                                    _spell.shadowfiend
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_disc_talent and mana_percent <0.80 and combat
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Shadowfiend")

                                elseif CastSpellUnits(
                                    _spell.mindbender
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_disc_talent and mana_percent <0.95 and combat
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Mindbender")
        
                                        


                                elseif CastSpellUnits(
                                        _spell.flash_heal
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow50
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Shadow Mend")
        


                                elseif CastSpellUnits(
                                    _spell.smite
                                        ,_unitids.standard_hostile
                                        ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Smite")
            
                                -- elseif CastSpellUnits(
                                --     _spell.flash_heal
                                --         ,_unitids.standard_friendly
                                --         ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and have_shadow_covenant_talent and _unit.player.buff["Shadow Covenant"].remaining > 0
                                --         ,{
                                --             SpellUnit_AliveAndFriendly
                                --             ,SpellUnit_HealthBelow90
                                --             ,SpellUnit_RangeCheck
                                --         }
                                --     ) then --print("Shadow Mend")
                                        
                                elseif CastSpellUnits(
                                    _spell.pain_suppression
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_HealthBelow30
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Pain suppression")

                            

                                --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                                elseif CastSpellUnits(
                                    _spell.flash_heal
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Shadow Mend")
                                            
                                --+++++++++++PVP START+++++++++++

                                elseif CastSpellUnits(
                                    _spell.archangel
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 3 and have_archangel_pvp_talent and combat
                                    ,{
                                        --SpellUnit_MyBuffExpiringUnder5
                                    }
                                    ) then --print("Evangelism")

                                elseif CastSpellUnits(
                                    _spell.dark_archangel
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 8 and have_dark_archangel_pvp_talent and combat
                                    ,{
                                        --SpellUnit_MyBuffExpiringUnder5
                                    }
                                    ) then --print("Evangelism")

                                elseif CastSpellUnits(
                                    _spell.inner_light
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.inner_light) < 0.5 and not combat and have_inner_light_and_shadow_talent
                                    ,{
                                        Botchuloz_Inner_Light_Shadow_Missing
                                    }
                                    ) then --print("Inner Light")
                                
                                elseif CastSpellUnits(
                                    _spell.inner_shadow
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.inner_shadow) < 0.5 and not combat and have_inner_light_and_shadow_talent
                                    ,{
                                        SpellUnit_MyBuffExpired
                                        --Botchuloz_Inner_Light_Shadow_Missing
                                    }
                                    ) then --print("Inner Shadow")
                            
                
                                --+++++++++++PVP END+++++++++++
                                                    
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
                                                                            

                                        -- elseif CastSpellUnits(
                                        --     _spell.power_word_solace
                                        --     ,_unitids.standard_hostile
                                        --     ,RemainingCooldown(_spell.power_word_solace) < 0.5 and have_power_word_solace_talent
                                        --     ,{
                                        --         SpellUnit_UnitAliveAndHostile
                                        --         ,SpellUnit_RangeCheck
                                        --         ,SpellUnit_ValidHarm
                                        --     }
                                        --     ) then --print("Schism")
                        

                                        elseif CastSpellUnits(
                                            _spell.rapture
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.rapture) < 0.5 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    ,SpellUnit_HealthBelow30
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Rapture")
                            

                                        elseif CastSpellUnits(
                                            _spell.shield
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    --,SpellUnit_WeakenedSoulExpired
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then print("Power Word: Shield Normal line 5971")

                                        elseif CastSpellUnits(
                                            _spell.shield
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.shield) < 0.5 and _unit.player.buff["Rapture"].remaining > 0 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    ,SpellUnit_RangeCheck
                                                    ,Botchuloz_SpellUnit_Help_Rank_Shield
                                                    --no weakened soul
                                                }
                                            ) then print("Power Word: Shield Rapture")


                                            elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                            ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                             (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                            ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_and_SWP_Missing,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                            ) then --print("Shadow Word: Pain")   
                
    
                                    elseif CastSpellUnits(_spell.shadow_word_pain,_unitids.raid_hostile
                                            ,(RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_purge_the_wicked_talent) or 
                                             (RemainingCooldown(_spell.purge_the_wicked) < 0.5 and have_purge_the_wicked_talent)
                                            ,{SpellUnit_UnitAliveAndHostile,SpellUnit_PurgeTheWicked_or_SWP_ExpiringUnder5_ButIsntExpired,SpellUnit_RangeCheck,SpellUnit_ValidHarm}
                                            ) then --print("Shadow Word: Pain refresh") 
    

                                        elseif CastSpellUnits(
                                            _spell.power_word_radiance
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.power_word_radiance) < 0.5 and combat and have_ultimate_radiance_pvp_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow90
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Power Word: Radiance instant cast")

                                        elseif CastSpellUnits(
                                            _spell.penance
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.penance) < 0.5
                                                ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Penance attack")  

                                        -- elseif CastSpellUnits(
                                        --     _spell.schism
                                        --     ,_unitids.standard_hostile
                                        --     ,RemainingCooldown(_spell.schism) < 0.5 and stationary and have_schism_talent
                                        --     ,{
                                        --         SpellUnit_UnitAliveAndHostile
                                        --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                        --         ,SpellUnit_ValidHarm
                                        --     }
                                        -- ) then --print("Schism")


                                        elseif CastSpellUnits(
                                            _spell.mindblast
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Mind Blast")

                                        elseif CastSpellUnits(
                                            _spell.shadow_word_death
                                                    ,_unitids.standard_hostile
                                                    ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                ) then --print("Shadow Word: Death")
                                                                            

                                        -- elseif CastSpellUnits(
                                        --     _spell.shadow_word_death
                                        --             ,_unitids.standard_hostile
                                        --             ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and player_health_perc > 0.45 and have_shadow_covenant_talent and _unit.player.buff["Shadow Covenant"].remaining > 0
                                        --             ,{
                                        --                 SpellUnit_UnitAliveAndHostile
                                        --             ,SpellUnit_RangeCheck
                                        --             ,SpellUnit_ValidHarm
                                        --             }
                                        --         ) then --print("Shadow Word: Death with Shadow Covenant")
                                                                            
                                        elseif CastSpellUnits(
                                            _spell.evangelism
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.evangelism) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 5 and have_evangelism_talent and combat
                                            ,{
                                                --SpellUnit_MyBuffExpiringUnder5
                                            }
                                            ) then --print("Evangelism")
                                                
                                        elseif CastSpellUnits(
                                            _spell.power_word_barrier
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.power_word_barrier) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow30
                                            }
                                            ) then --print("Power Word: Barrier")

                                        elseif CastSpellUnits(
                                            _spell.divine_star
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Divine Star")

                                        elseif CastSpellUnits(
                                            _spell.halo
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Divine Star")


                                        elseif CastSpellUnits(
                                            _spell.shadowfiend
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_disc_talent and mana_percent <0.80 and combat
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Shadowfiend")

                                        elseif CastSpellUnits(
                                            _spell.mindbender
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_disc_talent and mana_percent <0.95 and combat
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Mindbender")

                                                
                                        elseif CastSpellUnits(
                                                _spell.flash_heal
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_HealthBelow30
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Shadow Mend")


                                        elseif CastSpellUnits(
                                            _spell.mind_flay
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.mind_flay) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_Debuff_ExpiringNextGCDOrExpired
                                                ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Mind Sear")
                                                                    
                                        elseif CastSpellUnits(
                                            _spell.pain_suppression
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.pain_suppression) < 0.5 and combat and have_pain_suppression_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow30
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Pain suppression")

                                    

                                        --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                                        elseif CastSpellUnits(
                                            _spell.flash_heal
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and not combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Shadow Mend")
                
                                            --+++++++++++PVP START+++++++++++

                                        elseif CastSpellUnits(
                                            _spell.archangel
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 3 and have_archangel_pvp_talent and combat
                                            ,{
                                                --SpellUnit_MyBuffExpiringUnder5
                                            }
                                            ) then --print("Evangelism")

                                        elseif CastSpellUnits(
                                            _spell.dark_archangel
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.archangel) < 0.5 and _unit.player.buff["Atonement"].remaining_or_high < 8 and have_dark_archangel_pvp_talent and combat
                                            ,{
                                                --SpellUnit_MyBuffExpiringUnder5
                                            }
                                            ) then --print("Evangelism")

                                        elseif CastSpellUnits(
                                            _spell.inner_light
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.inner_light) < 0.5 and not combat and have_inner_light_and_shadow_talent
                                            ,{
                                                Botchuloz_Inner_Light_Shadow_Missing
                                            }
                                            ) then --print("Inner Light")
                                        
                                        elseif CastSpellUnits(
                                            _spell.inner_shadow
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.inner_shadow) < 0.5 and not combat and have_inner_light_and_shadow_talent
                                            ,{
                                                SpellUnit_MyBuffExpired
                                                --Botchuloz_Inner_Light_Shadow_Missing
                                            }
                                            ) then --print("Inner Shadow")
                                    
                        
                                        --+++++++++++PVP END+++++++++++
                                                            
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
-- dP                dP          
-- 88                88          
-- 88d888b. .d8888b. 88 dP    dP 
-- 88'  `88 88'  `88 88 88    88 
-- 88    88 88.  .88 88 88.  .88 
-- dP    dP `88888P' dP `8888P88 
--                           .88 
--                       d8888P  
--
    elseif holy_spec       == delphi.spec then
        --Spec Spells START
        BindSpellToUnits(_spell.premonition,                    _unitids.player)
        BindSpellToUnits(_spell.divine_hymn,                    _unitids.player)
        BindSpellToUnits(_spell.symbol_of_hope,                 _unitids.player)
        BindSpellToUnits(_spell.holy_nova,                      _unitids.player)
        BindSpellToUnits(_spell.mass_res,                       _unitids.player)
--        BindSpellToUnits(_spell.shining_force,                  _unitids.player)
        BindSpellToUnits(_spell.angelic_feather,                _unitids.player)
        BindSpellToUnits(_spell.divine_star,                    _unitids.player)
        BindSpellToUnits(_spell.halo,                           _unitids.player)
        BindSpellToUnits(_spell.apotheosis,                     _unitids.player)
        BindSpellToUnits(_spell.holy_word_salvation,            _unitids.player)
        BindSpellToUnits(_spell.holy_word_sanctify,             _unitids.player,"/cast [@player] Holy Word: Sanctify","",1)
        BindSpellToUnits(_spell.holy_ward,                      _unitids.player)
        BindSpellToUnits(_spell.divine_ascension,               _unitids.player)
        BindSpellToUnits(_spell.spirit_of_the_redeemer,         _unitids.player)
        BindSpellToUnits(_spell.void_tendrils,                  _unitids.player)
        BindSpellToUnits(_spell.lightwell,                      _unitids.player)

        BindSpellToUnits(_spell.shield,                         _unitids.standard_friendly)
        BindSpellToUnits(_spell.flash_heal,                     _unitids.standard_friendly)
        BindSpellToUnits(_spell.circle_of_healing,              _unitids.standard_friendly)
        BindSpellToUnits(_spell.guardian_spirit,                _unitids.standard_friendly)
        BindSpellToUnits(_spell.heal,                           _unitids.standard_friendly)
        BindSpellToUnits(_spell.holy_word_serenity,             _unitids.standard_friendly)
        BindSpellToUnits(_spell.prayer_of_healing,              _unitids.standard_friendly)
        BindSpellToUnits(_spell.prayer_of_mending,              _unitids.standard_friendly)
--        BindSpellToUnits(_spell.cleanse,                        _unitids.standard_friendly)
        BindSpellToUnits(_spell.renew,                          _unitids.standard_friendly)
        BindSpellToUnits(_spell.greater_heal,                   _unitids.standard_friendly)
        BindSpellToUnits(_spell.ray_of_hope,                    _unitids.standard_friendly)
   
    
        BindSpellToUnits(_spell.smite,                          _unitids.target)
        BindSpellToUnits(_spell.holy_fire,                      _unitids.target)
        BindSpellToUnits(_spell.holy_word_chastise,             _unitids.target)
        -- BindSpellToUnits(_spell.thoughtsteal,                  _unitids.target)
        BindSpellToUnits(_spell.shadow_word_pain,              _unitids.standard_hostile)

        BindSpellToUnits(_spell.renew,                          _unitids.raid_friendly)
        BindSpellToUnits(_spell.power_word_life,                _unitids.raid_friendly)
        BindSpellToUnits(_spell.holy_word_serenity,             _unitids.raid_friendly)
        BindSpellToUnits(_spell.flash_heal,                     _unitids.raid_friendly)
        BindSpellToUnits(_spell.heal,                           _unitids.raid_friendly)



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
                                    _spell.power_word_life,_unitids.raid_friendly
                                        ,have_power_word_life_talent and combat 
                                        and RemainingCooldown(440678) < 0.5  and have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.50
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_NoRecasting  
                                            ,SpellUnit_HealthBelow50                                                                                            
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                    ) then --print("Power Word: Life 50%")

                    
                                elseif CastSpellUnits(
                                    _spell.power_word_life,_unitids.raid_friendly
                                        ,have_power_word_life_talent and combat 
                                        and RemainingCooldown(373481) < 0.5 and not have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.35
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_NoRecasting
                                            ,SpellUnit_HealthBelow35                                                                             
                                        }
                                        ,RankUnits_MaxHealthDeficitPercent
                                    ) then --print("Power Word: Life 35%")
    
                        --  elseif CastSpellUnits( 
                        --     _spell.power_word_life,_unitids.raid_friendly
                        --         ,RemainingCooldown(_spell.power_word_life) < 0.5 and have_power_word_life_talent and combat 
                        --         -- and ((SpellUnit_HealthBelow35 and not have_miraculous_recovery_talent) 
                        --         --   or (SpellUnit_HealthBelow50 and     have_miraculous_recovery_talent))
                        --         and ((_unit[unit].health.percent <= 0.35 and not have_miraculous_recovery_talent) 
                        --           or (_unit[unit].health.percent <= 0.50 and     have_miraculous_recovery_talent))
                        --         ,{
                        --             SpellUnit_AliveAndFriendly
                        --             ,SpellUnit_RangeCheck
                        --             --,SpellUnit_HealthBelow35                                                                                              
                        --         }
                        --     ) then --print("Power Word: Life")


            
                                elseif CastSpellUnits(
                                    _spell.heal
                                    ,_unitids.raid_friendly
                                    ,RemainingCooldown(_spell.heal) < 0.5 and _unit.player.buff["Waste No Time"].remaining > 0
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_NoRecasting
                                        ,SpellUnit_MediumHealth
                                        ,SpellUnit_RangeCheck
                                        
                                    }
                                        ,RankUnits_MaxHealthDeficitPercent
                                ) then  --print("Waste no time heal")
       

            
            
            

                            elseif CastSpellUnits(
                                _spell.flash_heal
                                ,_unitids.raid_friendly
                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    --,SpellUnit_NoRecasting
                                    ,SpellUnit_HealthBelow95
                                    ,SpellUnit_RangeCheck
                                    
                                }
                                    ,RankUnits_MaxHealthDeficitPercent
                            ) then  --print("Surge of Light flash heal")


                            elseif CastSpellUnits(
                                _spell.holy_word_serenity
                                ,_unitids.raid_friendly
                                ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_LowHealth
                                    ,SpellUnit_RangeCheck
                                    
                                }
                                    --,RankUnits_MaxHealthDeficitPercent
                            ) then  --print("Holy Word: Serenity")

                            elseif CastSpellUnits(
                                _spell.holy_word_sanctify
                                ,_unitids.player
                                ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and _unit.player.buff["Apotheosis"].remaining > 0 and have_holy_word_sanctify_talent
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    --,SpellUnit_NoRecasting
                                    
                                }
                                    --,RankUnits_MaxHealthDeficitPercent
                            ) then  --print("Holy Word: Sanctify")

                            elseif CastSpellUnits(
                                _spell.holy_word_serenity
                                ,_unitids.raid_friendly
                                ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat and _unit.player.buff["Apotheosis"].remaining > 0
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_HealthBelow70
                                    ,SpellUnit_RangeCheck
                                    
                                }
                                    ,RankUnits_MaxHealthDeficitPercent
                                ) then  --print("Holy Word: Serenity")


                            elseif CastSpellUnits(
                                _spell.prayer_of_mending
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.prayer_of_mending) < 0.5 and combat and have_prayer_of_mending_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_Expired
                                        ,SpellUnit_RangeCheck
                                        --,SpellUnit_NoRecasting
                                        --,OOC_Rank
                                    }
                                    ,RankUnits_PvETargets
                                ) then --print("Prayer of Mending")
                                

                            elseif CastSpellUnits(
                                _spell.circle_of_healing
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.circle_of_healing) < 0.5 and Botchuloz_Circle_of_Healing_Detail(400,2) and combat and have_circle_of_healing_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_RangeCheck
                                        --,SpellUnit_NoRecasting
                                    }
                                ) then --print("Circle of healing")


                                elseif CastSpellUnits(
                                    _spell.guardian_spirit
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and not have_guardian_angel_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_NoRecasting
                                        ,SpellUnit_AlmostEmpty
                                        ,SpellUnit_RangeCheck
                                        
                                    }
                                        --,RankUnits_MaxHealthDeficitPercent
                                ) then  --print("Guardian Spirit Normal")

                                elseif CastSpellUnits(
                                    _spell.guardian_spirit
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and have_guardian_angel_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_NoRecasting
                                        ,SpellUnit_VeryLowHealth
                                        ,SpellUnit_RangeCheck
                                        
                                    }
                                        --,RankUnits_MaxHealthDeficitPercent
                                ) then  --print("Guardian Spirit Talent")

                                        
                                elseif CastSpellUnits(
                                    _spell.greater_heal
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.greater_heal) < 0.5 and stationary and combat and have_greater_heal_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_NoRecasting
                                        ,SpellUnit_HealthBelow50
                                        ,SpellUnit_RangeCheck
                                        
                                    }
                                        --,RankUnits_MaxHealthDeficitPercent
                                ) then  --print("greater heal")

                                elseif CastSpellUnits(
                                    _spell.apotheosis
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.apotheosis) < 0.5 and combat and GroupHealthDeficit() > 5000 and have_apotheosis_talent
                                    ) then --print("Apotheosis")

                                elseif CastSpellUnits(
                                    _spell.symbol_of_hope
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.symbol_of_hope) < 0.5 and combat and mana_percent <0.75 and stationary_for > 5.0 and have_symbol_of_hope_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_BreakingBuffsExpired
                                        }
                                        ) then --print("Symbol of Hope")
           
                                        elseif CastSpellUnits(
                                            _spell.halo
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Halo")
                    
                    
                                            elseif CastSpellUnits(
                                                _spell.divine_star
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                    }
                                                ) then --print("Divine Star")
 
                                                    
                                                elseif CastSpellUnits(
                                                    _spell.premonition
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            ,SpellUnit_PremonitionExpired
                                                        }
                                                    ) then --print("Premonition")
        
                                                    elseif CastSpellUnits(
                                                        _spell.lightwell,_unitids.player
                                                            ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                            }
                                                        ) then --print("Lightwell")
    

        
                                elseif CastSpellUnits(
                                    _spell.renew
                                    ,_unitids.raid_friendly
                                    ,RemainingCooldown(_spell.renew) < 0.5
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                        ,SpellUnit_HealthBelow95
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Renew")        


                                elseif CastSpellUnits(
                                    _spell.shield
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                            --,SpellUnit_WeakenedSoulExpired
                                            ,SpellUnit_RangeCheck
                                            --,Botchuloz_SpellUnit_Help_Rank_Shield
                                        }
                                        ,RankUnits_PvETargets
                                    ) then print("Power Word: Shield Normal line 6580")



        

           
                        elseif CastSpellUnits(
                            _spell.holy_nova
                                ,_unitids.player
                                ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                ,{
                                    SpellUnit_AliveAndFriendly
                                }
                            ) then --print("Halo")
    

                                elseif CastSpellUnits(
                                    _spell.heal,_unitids.raid_friendly
                                    ,RemainingCooldown(_spell.heal) < 0.5 and stationary and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_NoRecasting
                                        ,SpellUnit_LowHealth
                                        ,SpellUnit_RangeCheck
                                    }
                                        ,RankUnits_MaxHealthDeficitPercent
                                ) then  --print("heal")

                                elseif CastSpellUnits(
                                    _spell.heal,_unitids.raid_friendly
                                    ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_NoRecasting
                                        ,SpellUnit_HealthBelow95
                                        ,SpellUnit_RangeCheck
                                    }
                                        ,RankUnits_MaxHealthDeficitPercent
                                ) then  --print("heal")


                                --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                                --+++++++++++PVP START+++++++++++
                                        elseif CastSpellUnits(
                                            _spell.holy_ward
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired                                                                
                                                }
                                            ) then --print("Holy Ward")



                                        elseif CastSpellUnits(
                                            _spell.divine_ascension
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.divine_ascension) < 0.5 and have_divine_ascension_talent and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired  
                                                    ,SpellUnit_HealthBelow60                                                             
                                                }
                                            ) then --print("Divine Ascension")

                                        elseif CastSpellUnits(
                                            _spell.spirit_of_the_redeemer
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.spirit_of_the_redeemer) < 0.5 and have_spirit_of_the_redeemer_talent and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired  
                                                    ,SpellUnit_HealthBelow30                                                           
                                                }
                                            ) then --print("Spirit of Redemption")


                                        elseif CastSpellUnits(
                                            _spell.ray_of_hope
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.ray_of_hope) < 0.5 and have_ray_of_hope_talent and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_NoRecasting
                                                ,SpellUnit_HealthBelow50
                                                ,SpellUnit_RangeCheck
                                                
                                            }
                                                --,RankUnits_MaxHealthDeficitPercent
                                        ) then  --print("ray of hope")


                                --+++++++++++PVP END+++++++++++




                            else _global.Off()
                            end   

                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)

                                            if 1 == 0 then


                        
                                            elseif CastSpellUnits(
                                                _spell.power_word_life,_unitids.raid_friendly
                                                    ,have_power_word_life_talent and combat and RemainingCooldown(440678) < 0.5  and have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.50
                                                    ,{SpellUnit_AliveAndFriendly,SpellUnit_RangeCheck,SpellUnit_NoRecasting,SpellUnit_HealthBelow50}
                                                    ,RankUnits_MaxHealthDeficitPercent
                                                ) then --print("Power Word: Life 50%")
            
                                
                                            elseif CastSpellUnits(
                                                _spell.power_word_life,_unitids.raid_friendly
                                                    ,have_power_word_life_talent and combat and RemainingCooldown(373481) < 0.5 and not have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.35
                                                    ,{SpellUnit_AliveAndFriendly,SpellUnit_RangeCheck,SpellUnit_NoRecasting,SpellUnit_HealthBelow35}
                                                    ,RankUnits_MaxHealthDeficitPercent
                                                ) then --print("Power Word: Life 35%")
                                                                            
                
                                                elseif CastSpellUnits(
                                                    _spell.heal
                                                    ,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.heal) < 0.5 and _unit.player.buff["Waste No Time"].remaining > 0
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_MediumHealth
                                                        ,SpellUnit_RangeCheck
                                                        
                                                    }
                                                        ,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("Waste no time heal")
                       
    

                                            elseif CastSpellUnits(
                                                _spell.flash_heal
                                                ,_unitids.raid_friendly
                                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("Surge of Light flash heal")
                

                            elseif CastSpellUnits(
                                _spell.holy_word_serenity
                                ,_unitids.raid_friendly
                                ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_LowHealth
                                    ,SpellUnit_RangeCheck
                                    
                                }
                                    --,RankUnits_MaxHealthDeficitPercent
                            ) then  --print("Holy Word: Serenity")

                            elseif CastSpellUnits(
                                _spell.holy_word_sanctify
                                ,_unitids.player
                                ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and _unit.player.buff["Apotheosis"].remaining > 0 and have_holy_word_sanctify_talent
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    --,SpellUnit_NoRecasting
                                    
                                }
                                    --,RankUnits_MaxHealthDeficitPercent
                            ) then  --print("Holy Word: Sanctify")

                            elseif CastSpellUnits(
                                _spell.holy_word_serenity
                                ,_unitids.raid_friendly
                                ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat and _unit.player.buff["Apotheosis"].remaining > 0
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_HealthBelow70
                                    ,SpellUnit_RangeCheck
                                    
                                }
                                    ,RankUnits_MaxHealthDeficitPercent
                                ) then  --print("Holy Word: Serenity")

                
                                elseif CastSpellUnits(
                                    _spell.prayer_of_mending
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.prayer_of_mending) < 0.5 and combat and have_prayer_of_mending_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            --,SpellUnit_Expired
                                            ,SpellUnit_RangeCheck
                                            --,SpellUnit_NoRecasting
                                            --,OOC_Rank
                                        }
                                        ,RankUnits_PvETargets
                                    ) then --print("Prayer of Mending")
                
                                            elseif CastSpellUnits(
                                                _spell.circle_of_healing
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.circle_of_healing) < 0.5 and Botchuloz_Circle_of_Healing_Detail(400,2) and combat and have_circle_of_healing_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_RangeCheck
                                                        --,SpellUnit_NoRecasting
                                                    }
                                                ) then --print("circle of healing")
                
                
                                                elseif CastSpellUnits(
                                                    _spell.guardian_spirit
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and not have_guardian_angel_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_AlmostEmpty
                                                        ,SpellUnit_RangeCheck
                                                        
                                                    }
                                                        --,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("Guardian Spirit Normal")
                
                                                elseif CastSpellUnits(
                                                    _spell.guardian_spirit
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and have_guardian_angel_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_VeryLowHealth
                                                        ,SpellUnit_RangeCheck
                                                        
                                                    }
                                                        --,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("Guardian Spirit Talent")
                
                                                        
                                                elseif CastSpellUnits(
                                                    _spell.greater_heal
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.greater_heal) < 0.5 and stationary and combat and have_greater_heal_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow50
                                                        ,SpellUnit_RangeCheck
                                                        
                                                    }
                                                        --,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("greater heal")
                
                                                elseif CastSpellUnits(
                                                    _spell.apotheosis
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.apotheosis) < 0.5 and combat and GroupHealthDeficit() > 5000 and have_apotheosis_talent
                                                    ) then --print("Apotheosis")
 
                                                        
                                                elseif CastSpellUnits(
                                                    _spell.symbol_of_hope
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.symbol_of_hope) < 0.5 and combat and mana_percent <0.75 and stationary_for > 5.0 and have_symbol_of_hope_talent
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            ,SpellUnit_BreakingBuffsExpired
                                                        }
                                                        ) then --print("Symbol of Hope")
           

                
                                                        elseif CastSpellUnits(
                                                            _spell.halo
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                }
                                                            ) then --print("Halo")
                                    
                                    
                                                            elseif CastSpellUnits(
                                                                _spell.divine_star
                                                                    ,_unitids.player
                                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                                    ,{
                                                                        SpellUnit_AliveAndFriendly
                                                                    }
                                                                ) then --print("Divine Star")
                                                                                        
                                                                elseif CastSpellUnits(
                                                                    _spell.premonition
                                                                        ,_unitids.player
                                                                        ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                                        ,{
                                                                            SpellUnit_AliveAndFriendly
                                                                            ,SpellUnit_PremonitionExpired
                                                                        }
                                                                    ) then --print("Premonition")
                        
                                                                    elseif CastSpellUnits(
                                                                        _spell.lightwell,_unitids.player
                                                                            ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                                            ,{
                                                                                SpellUnit_AliveAndFriendly
                                                                            }
                                                                        ) then --print("Lightwell")
                
                        
                                                elseif CastSpellUnits(
                                                    _spell.renew
                                                    ,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.renew) < 0.5
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_ExpiringOrExpired
                                                        ,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Renew")        
                
                
                 
                
                
                                                elseif CastSpellUnits(
                                                    _spell.shield
                                                        ,_unitids.standard_friendly
                                                        ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            ,SpellUnit_ExpiringOrExpired
                                                            --,SpellUnit_WeakenedSoulExpired
                                                            ,SpellUnit_RangeCheck
                                                            --,Botchuloz_SpellUnit_Help_Rank_Shield
                                                        }
                                                        ,RankUnits_PvETargets
                                                    ) then print("Power Word: Shield Normal line 6933")
                


           
                                            elseif CastSpellUnits(
                                                _spell.holy_nova
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                    }
                                                ) then --print("Halo")
                        
                            
            
                
                                                elseif CastSpellUnits(
                                                    _spell.heal,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.heal) < 0.5 and stationary and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_LowHealth
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                        ,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("heal")
                
                                                elseif CastSpellUnits(
                                                    _spell.heal,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                        ,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("heal")
                                
                
                                                --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  
                
                                                --+++++++++++PVP START+++++++++++
                                                        elseif CastSpellUnits(
                                                            _spell.holy_ward
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                    ,SpellUnit_ExpiringOrExpired                                                                
                                                                }
                                                            ) then --print("Holy Ward")
                
                
                
                                                        elseif CastSpellUnits(
                                                            _spell.divine_ascension
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.divine_ascension) < 0.5 and have_divine_ascension_talent and combat
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                    ,SpellUnit_ExpiringOrExpired  
                                                                    ,SpellUnit_HealthBelow60                                                             
                                                                }
                                                            ) then --print("Divine Ascension")
                
                                                        elseif CastSpellUnits(
                                                            _spell.spirit_of_the_redeemer
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.spirit_of_the_redeemer) < 0.5 and have_spirit_of_the_redeemer_talent and combat
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                    ,SpellUnit_ExpiringOrExpired  
                                                                    ,SpellUnit_HealthBelow30                                                           
                                                                }
                                                            ) then --print("Spirit of Redemption")
                
                
                                                        elseif CastSpellUnits(
                                                            _spell.ray_of_hope
                                                            ,_unitids.standard_friendly
                                                            ,RemainingCooldown(_spell.ray_of_hope) < 0.5 and have_ray_of_hope_talent and combat
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                                --,SpellUnit_NoRecasting
                                                                ,SpellUnit_HealthBelow50
                                                                ,SpellUnit_RangeCheck
                                                                
                                                            }
                                                                --,RankUnits_MaxHealthDeficitPercent
                                                        ) then  --print("ray of hope")
                
                               
                                                --+++++++++++PVP END+++++++++++
                
                

                                        --++++++++++++START ATTACK+++++++++++++++++++++++++

                                            elseif CastSpellUnits(
                                                _spell.holy_fire
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.holy_fire) < 0.5 and stationary
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Smite")


                                            elseif CastSpellUnits(
                                            _spell.shadow_word_death
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                    ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                ) then --print("Shadow Word: Death")

                                            elseif CastSpellUnits(
                                                _spell.shadow_word_pain
                                                    ,_unitids.standard_hostile
                                                    ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                    ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_MyDebuffExpired
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Shadow Word: Pain")   
                        

                                            elseif CastSpellUnits(
                                                _spell.shadow_word_pain
                                                        ,_unitids.standard_hostile
                                                        ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                        ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                        }
                                                        ) then --print("shadow word: pain refresh") 

                                            elseif CastSpellUnits(
                                                _spell.holy_word_chastise
                                                    ,_unitids.standard_hostile
                                                    ,RemainingCooldown(_spell.holy_word_chastise) < 0.5
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Smite")

                                                    elseif CastSpellUnits(
                                                        _spell.divine_star
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                            }
                                                        ) then --print("Divine Star")
                            
                                    

                                            elseif CastSpellUnits(
                                                _spell.smite
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Smite")
                                                                        


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
                                                    _spell.holy_fire
                                                        ,_unitids.target
                                                        ,RemainingCooldown(_spell.holy_fire) < 0.5 and stationary
                                                        ,{
                                                            SpellUnit_UnitAliveAndHostile
                                                            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                            ,SpellUnit_ValidHarm
                                                        }
                                                        ) then --print("Smite")


                                                elseif CastSpellUnits(
                                                _spell.shadow_word_death
                                                        ,_unitids.standard_hostile
                                                        ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                        ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                        }
                                                    ) then --print("Shadow Word: Death")

                                                elseif CastSpellUnits(
                                                    _spell.shadow_word_pain
                                                        ,_unitids.standard_hostile
                                                        ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                        ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_MyDebuffExpired
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                        }
                                                        ) then --print("Shadow Word: Pain")   
                            

                                                elseif CastSpellUnits(
                                                    _spell.shadow_word_pain
                                                            ,_unitids.standard_hostile
                                                            ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                            ,{
                                                            SpellUnit_UnitAliveAndHostile
                                                            ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                                            ,SpellUnit_RangeCheck
                                                            ,SpellUnit_ValidHarm
                                                            }
                                                            ) then --print("shadow word: pain refresh") 

                                                elseif CastSpellUnits(
                                                    _spell.holy_word_chastise
                                                        ,_unitids.standard_hostile
                                                        ,RemainingCooldown(_spell.holy_word_chastise) < 0.5
                                                        ,{
                                                            SpellUnit_UnitAliveAndHostile
                                                            ,SpellUnit_RangeCheck
                                                            ,SpellUnit_ValidHarm
                                                        }
                                                        ) then --print("Smite")

                                                        elseif CastSpellUnits(
                                                            _spell.divine_star
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                }
                                                            ) then --print("Divine Star")
                                
                                        

                                                elseif CastSpellUnits(
                                                    _spell.smite
                                                        ,_unitids.target
                                                        ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                                        ,{
                                                            SpellUnit_UnitAliveAndHostile
                                                            ,SpellUnit_RangeCheck
                                                            ,SpellUnit_ValidHarm
                                                        }
                                                        ) then --print("Smite")
                                                                            

                                                        elseif CastSpellUnits(
                                                            _spell.halo
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                }
                                                            ) then --print("Halo")
                                    
                                    
                                                            elseif CastSpellUnits(
                                                                _spell.divine_star
                                                                    ,_unitids.player
                                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                                    ,{
                                                                        SpellUnit_AliveAndFriendly
                                                                    }
                                                                ) then --print("Divine Star")
                                                                                        
                                                                elseif CastSpellUnits(
                                                                    _spell.premonition
                                                                        ,_unitids.player
                                                                        ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                                        ,{
                                                                            SpellUnit_AliveAndFriendly
                                                                            ,SpellUnit_PremonitionExpired
                                                                        }
                                                                    ) then --print("Premonition")
                        
                                                                    elseif CastSpellUnits(
                                                                        _spell.lightwell,_unitids.player
                                                                            ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                                            ,{
                                                                                SpellUnit_AliveAndFriendly
                                                                            }
                                                                        ) then --print("Lightwell")
                
                        
                                                elseif CastSpellUnits(
                                                    _spell.renew
                                                    ,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.renew) < 0.5
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_ExpiringOrExpired
                                                        ,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Renew")        
                
                

           
                                        elseif CastSpellUnits(
                                            _spell.holy_nova
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Halo")
                    
                                        
            

                                            elseif CastSpellUnits(
                                                _spell.shield
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_ExpiringOrExpired
                                                        --,SpellUnit_WeakenedSoulExpired
                                                    }
                                                ) then print("Power Word: Shield Normal line 7287")

                
                                                elseif CastSpellUnits(
                                                    _spell.heal,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                        ,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("heal")
                


                                            --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  
                                            --+++++++++++PVP START+++++++++++
                                            elseif CastSpellUnits(
                                                _spell.holy_ward
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_ExpiringOrExpired                                                                
                                                    }
                                                ) then --print("Holy Ward")

                                            --+++++++++++PVP END+++++++++++



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
                            _spell.power_word_life,_unitids.raid_friendly
                                ,have_power_word_life_talent and combat 
                                and RemainingCooldown(440678) < 0.5  and have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.50
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_NoRecasting  
                                    ,SpellUnit_HealthBelow50                                                                                            
                                }
                                ,RankUnits_MaxHealthDeficitPercent
                            ) then --print("Power Word: Life 50%")

            
                        elseif CastSpellUnits(
                            _spell.power_word_life,_unitids.raid_friendly
                                ,have_power_word_life_talent and combat 
                                and RemainingCooldown(373481) < 0.5 and not have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.35
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_HealthBelow35                                                                             
                                }
                                ,RankUnits_MaxHealthDeficitPercent
                            ) then --print("Power Word: Life 35%")


                            elseif CastSpellUnits(
                                _spell.heal
                                ,_unitids.raid_friendly
                                ,RemainingCooldown(_spell.heal) < 0.5 and _unit.player.buff["Waste No Time"].remaining > 0
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    --,SpellUnit_NoRecasting
                                    ,SpellUnit_MediumHealth
                                    ,SpellUnit_RangeCheck
                                    
                                }
                                    ,RankUnits_MaxHealthDeficitPercent
                            ) then  --print("Waste no time heal")
   

                         elseif CastSpellUnits(
                             _spell.flash_heal
                             ,_unitids.raid_friendly
                             ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                             ,{
                                 SpellUnit_AliveAndFriendly
                                 --,SpellUnit_NoRecasting
                                 ,SpellUnit_HealthBelow95
                                 ,SpellUnit_RangeCheck
                                 
                             }
                                 ,RankUnits_MaxHealthDeficitPercent
                         ) then  --print("Surge of Light flash heal")


                         elseif CastSpellUnits(
                             _spell.holy_word_serenity
                             ,_unitids.standard_friendly
                             ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat
                             ,{
                                 SpellUnit_AliveAndFriendly
                                 --,SpellUnit_NoRecasting
                                 ,SpellUnit_LowHealth
                                 ,SpellUnit_RangeCheck
                                 
                             }
                                 --,RankUnits_MaxHealthDeficitPercent
                         ) then  --print("Holy Word: Serenity")

                         elseif CastSpellUnits(
                             _spell.holy_word_sanctify
                             ,_unitids.player
                             ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and GroupHealthDeficit() > 5000 and have_holy_word_sanctify_talent
                             ,{
                                 SpellUnit_AliveAndFriendly
                                 --,SpellUnit_NoRecasting
                                 
                             }
                                 --,RankUnits_MaxHealthDeficitPercent
                         ) then  --print("Holy Word: Sanctify")

                         elseif CastSpellUnits(
                             _spell.holy_word_serenity
                             ,_unitids.standard_friendly
                             ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat and have_apotheosis_talent and _unit.player.buff["Apotheosis"].remaining > 0
                             ,{
                                 SpellUnit_AliveAndFriendly
                                 --,SpellUnit_NoRecasting
                                 ,SpellUnit_HealthBelow80
                                 ,SpellUnit_RangeCheck
                                 
                             }
                                 ,RankUnits_MaxHealthDeficitPercent
                             ) then  --print("Holy Word: Serenity")


                            elseif CastSpellUnits(
                                _spell.prayer_of_mending
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.prayer_of_mending) < 0.5 and combat and have_prayer_of_mending_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_Expired
                                        ,SpellUnit_RangeCheck
                                        --,SpellUnit_NoRecasting
                                        --,OOC_Rank
                                    }
                                    ,RankUnits_PvETargets
                                ) then --print("Prayer of Mending")

                         elseif CastSpellUnits(
                             _spell.circle_of_healing
                                 ,_unitids.standard_friendly
                                 ,RemainingCooldown(_spell.circle_of_healing) < 0.5 and combat  and have_circle_of_healing_talent
                                 ,{
                                     SpellUnit_AliveAndFriendly
                                     ,SpellUnit_RangeCheck
                                     --,SpellUnit_NoRecasting
                                     ,SpellUnit_HealthBelow90
                                 }
                             ) then --print("circle of healing")


                             elseif CastSpellUnits(
                                 _spell.guardian_spirit
                                 ,_unitids.standard_friendly
                                 ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and not have_guardian_angel_talent
                                 ,{
                                     SpellUnit_AliveAndFriendly
                                     --,SpellUnit_NoRecasting
                                     ,SpellUnit_AlmostEmpty
                                     ,SpellUnit_RangeCheck
                                     
                                 }
                                     --,RankUnits_MaxHealthDeficitPercent
                             ) then  --print("Guardian Spirit Normal")

                             elseif CastSpellUnits(
                                 _spell.guardian_spirit
                                 ,_unitids.standard_friendly
                                 ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and have_guardian_angel_talent
                                 ,{
                                     SpellUnit_AliveAndFriendly
                                     --,SpellUnit_NoRecasting
                                     ,SpellUnit_VeryLowHealth
                                     ,SpellUnit_RangeCheck
                                     
                                 }
                                     --,RankUnits_MaxHealthDeficitPercent
                             ) then  --print("Guardian Spirit Talent")

                                     
                             elseif CastSpellUnits(
                                 _spell.greater_heal
                                 ,_unitids.standard_friendly
                                 ,RemainingCooldown(_spell.greater_heal) < 0.5 and stationary and combat and have_greater_heal_talent
                                 ,{
                                     SpellUnit_AliveAndFriendly
                                     --,SpellUnit_NoRecasting
                                     ,SpellUnit_HealthBelow50
                                     ,SpellUnit_RangeCheck
                                     
                                 }
                                     --,RankUnits_MaxHealthDeficitPercent
                             ) then  --print("greater heal")

                             elseif CastSpellUnits(
                                 _spell.apotheosis
                                 ,_unitids.player
                                 ,RemainingCooldown(_spell.apotheosis) < 0.5 and combat and GroupHealthDeficit() > 5000 and have_apotheosis_talent
                                 ) then --print("Apotheosis")

                                    
                                elseif CastSpellUnits(
                                    _spell.symbol_of_hope
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.symbol_of_hope) < 0.5 and combat and mana_percent <0.75 and stationary_for > 5.0 and have_symbol_of_hope_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_BreakingBuffsExpired
                                        }
                                        ) then --print("Symbol of Hope")
           
 

                                        elseif CastSpellUnits(
                                            _spell.halo
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Halo")
                    
                    
                                            elseif CastSpellUnits(
                                                _spell.divine_star
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                    }
                                                ) then --print("Divine Star")
                    
                                                            
                                                elseif CastSpellUnits(
                                                    _spell.premonition
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            ,SpellUnit_PremonitionExpired
                                                        }
                                                    ) then --print("Premonition")
        
                                                    elseif CastSpellUnits(
                                                        _spell.lightwell,_unitids.player
                                                            ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                            }
                                                        ) then --print("Lightwell")

                                elseif CastSpellUnits(
                                    _spell.renew
                                    ,_unitids.raid_friendly
                                    ,RemainingCooldown(_spell.renew) < 0.5
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                        ,SpellUnit_HealthBelow95
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Renew")        



                               
                                    elseif CastSpellUnits(
                                        _spell.holy_nova
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Halo")
                
            


                                elseif CastSpellUnits(
                                    _spell.shield
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                            --,SpellUnit_WeakenedSoulExpired
                                            ,SpellUnit_RangeCheck
                                            --,Botchuloz_SpellUnit_Help_Rank_Shield
                                        }
                                        ,RankUnits_PvETargets
                                    ) then print("Power Word: Shield Normal line 7608")



                             elseif CastSpellUnits(
                                 _spell.prayer_of_healing
                                 ,_unitids.standard_friendly
                                 ,RemainingCooldown(_spell.prayer_of_healing) < 0.5 and stationary and combat
                                 ,{
                                     SpellUnit_AliveAndFriendly
                                     --,SpellUnit_NoRecasting
                                     ,SpellUnit_HealthBelow90
                                     ,SpellUnit_RangeCheck
                                     
                                 }
                                     --,RankUnits_MaxHealthDeficitPercent
                             ) then  --print("heal")

                             elseif CastSpellUnits(
                                _spell.flash_heal
                                ,_unitids.standard_friendly
                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and combat
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    --,SpellUnit_NoRecasting
                                    ,SpellUnit_HealthBelow30
                                    ,SpellUnit_RangeCheck
                                    
                                }
                                    --,RankUnits_MaxHealthDeficitPercent
                            ) then  --print("heal")



                            elseif CastSpellUnits(
                                _spell.heal,_unitids.raid_friendly
                                ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_HealthBelow95
                                    ,SpellUnit_RangeCheck
                                }
                                    ,RankUnits_MaxHealthDeficitPercent
                            ) then  --print("heal")

                             --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                             --+++++++++++PVP START+++++++++++
                                     elseif CastSpellUnits(
                                         _spell.holy_ward
                                             ,_unitids.player
                                             ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                             ,{
                                                 SpellUnit_AliveAndFriendly
                                                 ,SpellUnit_ExpiringOrExpired                                                                
                                             }
                                         ) then --print("Holy Ward")



                                     elseif CastSpellUnits(
                                         _spell.divine_ascension
                                             ,_unitids.player
                                             ,RemainingCooldown(_spell.divine_ascension) < 0.5 and have_divine_ascension_talent and combat
                                             ,{
                                                 SpellUnit_AliveAndFriendly
                                                 ,SpellUnit_ExpiringOrExpired  
                                                 ,SpellUnit_HealthBelow60                                                             
                                             }
                                         ) then --print("Divine Ascension")

                                     elseif CastSpellUnits(
                                         _spell.spirit_of_the_redeemer
                                             ,_unitids.player
                                             ,RemainingCooldown(_spell.spirit_of_the_redeemer) < 0.5 and have_spirit_of_the_redeemer_talent and combat
                                             ,{
                                                 SpellUnit_AliveAndFriendly
                                                 ,SpellUnit_ExpiringOrExpired  
                                                 ,SpellUnit_HealthBelow30                                                           
                                             }
                                         ) then --print("Spirit of Redemption")


                                     elseif CastSpellUnits(
                                         _spell.ray_of_hope
                                         ,_unitids.standard_friendly
                                         ,RemainingCooldown(_spell.ray_of_hope) < 0.5 and have_ray_of_hope_talent and combat
                                         ,{
                                             SpellUnit_AliveAndFriendly
                                             --,SpellUnit_NoRecasting
                                             ,SpellUnit_HealthBelow50
                                             ,SpellUnit_RangeCheck
                                             
                                         }
                                             --,RankUnits_MaxHealthDeficitPercent
                                     ) then  --print("ray of hope")






                             --+++++++++++PVP END+++++++++++




                         else _global.Off()
                         end   




                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)



                                        if 1 == 0 then


                        
                                        elseif CastSpellUnits(
                                            _spell.power_word_life,_unitids.raid_friendly
                                                ,have_power_word_life_talent and combat 
                                                and RemainingCooldown(440678) < 0.5  and have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.50
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_NoRecasting  
                                                    ,SpellUnit_HealthBelow50                                                                                            
                                                }
                                                ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Power Word: Life 50%")
        
                            
                                        elseif CastSpellUnits(
                                            _spell.power_word_life,_unitids.raid_friendly
                                                ,have_power_word_life_talent and combat 
                                                and RemainingCooldown(373481) < 0.5 and not have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.35
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow35                                                                             
                                                }
                                                ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Power Word: Life 35%")
                                    
                                    
            
                                            elseif CastSpellUnits(
                                                _spell.heal
                                                ,_unitids.raid_friendly
                                                ,RemainingCooldown(_spell.heal) < 0.5 and _unit.player.buff["Waste No Time"].remaining > 0
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_MediumHealth
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("Waste no time heal")
                   

                                        elseif CastSpellUnits(
                                            _spell.flash_heal
                                            ,_unitids.raid_friendly
                                            ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_NoRecasting
                                                ,SpellUnit_HealthBelow90
                                                ,SpellUnit_RangeCheck
                                                
                                            }
                                                ,RankUnits_MaxHealthDeficitPercent
                                        ) then  --print("Surge of Light flash heal")
               
               
                                        elseif CastSpellUnits(
                                            _spell.holy_word_serenity
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_NoRecasting
                                                ,SpellUnit_LowHealth
                                                ,SpellUnit_RangeCheck
                                                
                                            }
                                                --,RankUnits_MaxHealthDeficitPercent
                                        ) then  --print("Holy Word: Serenity")
               
                                        elseif CastSpellUnits(
                                            _spell.holy_word_sanctify
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and GroupHealthDeficit() > 5000 and have_holy_word_sanctify_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_NoRecasting
                                                
                                            }
                                                --,RankUnits_MaxHealthDeficitPercent
                                        ) then  --print("Holy Word: Sanctify")
               
                                        elseif CastSpellUnits(
                                            _spell.holy_word_serenity
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat and have_apotheosis_talent and _unit.player.buff["Apotheosis"].remaining > 0
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_NoRecasting
                                                ,SpellUnit_HealthBelow80
                                                ,SpellUnit_RangeCheck
                                                
                                            }
                                                ,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("Holy Word: Serenity")
               
               
                            elseif CastSpellUnits(
                                _spell.prayer_of_mending
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.prayer_of_mending) < 0.5 and combat and have_prayer_of_mending_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_Expired
                                        ,SpellUnit_RangeCheck
                                        --,SpellUnit_NoRecasting
                                        --,OOC_Rank
                                    }
                                    ,RankUnits_PvETargets
                                ) then --print("Prayer of Mending")
               
                                        elseif CastSpellUnits(
                                            _spell.circle_of_healing
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.circle_of_healing) < 0.5 and combat and have_circle_of_healing_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow90
                                                }
                                            ) then --print("circle of healing")
               
               
                                            elseif CastSpellUnits(
                                                _spell.guardian_spirit
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and not have_guardian_angel_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_AlmostEmpty
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    --,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("Guardian Spirit Normal")
               
                                            elseif CastSpellUnits(
                                                _spell.guardian_spirit
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and have_guardian_angel_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_VeryLowHealth
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    --,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("Guardian Spirit Talent")
               
                                                    
                                            elseif CastSpellUnits(
                                                _spell.greater_heal
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.greater_heal) < 0.5 and stationary and combat and have_greater_heal_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow50
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    --,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("greater heal")
               
                                            elseif CastSpellUnits(
                                                _spell.apotheosis
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.apotheosis) < 0.5 and combat and GroupHealthDeficit() > 5000 and have_apotheosis_talent
                                                ) then --print("Apotheosis")
 

                                                elseif CastSpellUnits(
                                                    _spell.symbol_of_hope
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.symbol_of_hope) < 0.5 and combat and mana_percent <0.75 and stationary_for > 5.0 and have_symbol_of_hope_talent
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            ,SpellUnit_BreakingBuffsExpired
                                                        }
                                                        ) then --print("Symbol of Hope")
                           
                                                                    

                                                        elseif CastSpellUnits(
                                                            _spell.halo
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                }
                                                            ) then --print("Halo")
                                    
                                    
                                                            elseif CastSpellUnits(
                                                                _spell.divine_star
                                                                    ,_unitids.player
                                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                                    ,{
                                                                        SpellUnit_AliveAndFriendly
                                                                    }
                                                                ) then --print("Divine Star")
                                    
                                                                            
                                                                elseif CastSpellUnits(
                                                                    _spell.premonition
                                                                        ,_unitids.player
                                                                        ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                                        ,{
                                                                            SpellUnit_AliveAndFriendly
                                                                            ,SpellUnit_PremonitionExpired
                                                                        }
                                                                    ) then --print("Premonition")
                        
                                                                    elseif CastSpellUnits(
                                                                        _spell.lightwell,_unitids.player
                                                                            ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                                            ,{
                                                                                SpellUnit_AliveAndFriendly
                                                                            }
                                                                        ) then --print("Lightwell")
                
                                                elseif CastSpellUnits(
                                                    _spell.renew
                                                    ,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.renew) < 0.5
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_ExpiringOrExpired
                                                        ,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Renew")        
                
 
                                           
                        elseif CastSpellUnits(
                            _spell.holy_nova
                                ,_unitids.player
                                ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                ,{
                                    SpellUnit_AliveAndFriendly
                                }
                            ) then --print("Halo")
    

                           
               
                                elseif CastSpellUnits(
                                    _spell.shield
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                            --,SpellUnit_WeakenedSoulExpired
                                            ,SpellUnit_RangeCheck
                                            --,Botchuloz_SpellUnit_Help_Rank_Shield
                                        }
                                        ,RankUnits_PvETargets
                                    ) then print("Power Word: Shield Normal line 7997")
               
               
               
                                            elseif CastSpellUnits(
                                                _spell.prayer_of_healing
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.prayer_of_healing) < 0.5 and stationary and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow90
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    --,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("heal")
               
                                            elseif CastSpellUnits(
                                               _spell.flash_heal
                                               ,_unitids.standard_friendly
                                               ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and combat
                                               ,{
                                                   SpellUnit_AliveAndFriendly
                                                   --,SpellUnit_NoRecasting
                                                   ,SpellUnit_HealthBelow30
                                                   ,SpellUnit_RangeCheck
                                                   
                                               }
                                                   --,RankUnits_MaxHealthDeficitPercent
                                           ) then  --print("heal")
               

        
                                        elseif CastSpellUnits(
                                            _spell.heal,_unitids.raid_friendly
                                            ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_NoRecasting
                                                ,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                                ,RankUnits_MaxHealthDeficitPercent
                                        ) then  --print("heal")
        
               
               
                                            --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  
               
                                            --+++++++++++PVP START+++++++++++
                                                    elseif CastSpellUnits(
                                                        _spell.holy_ward
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                                ,SpellUnit_ExpiringOrExpired                                                                
                                                            }
                                                        ) then --print("Holy Ward")
               
               
                                                    elseif CastSpellUnits(
                                                        _spell.divine_ascension
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.divine_ascension) < 0.5 and have_divine_ascension_talent and combat
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                                ,SpellUnit_ExpiringOrExpired  
                                                                ,SpellUnit_HealthBelow60                                                             
                                                            }
                                                        ) then --print("Divine Ascension")
               
                                                    elseif CastSpellUnits(
                                                        _spell.spirit_of_the_redeemer
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.spirit_of_the_redeemer) < 0.5 and have_spirit_of_the_redeemer_talent and combat
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                                ,SpellUnit_ExpiringOrExpired  
                                                                ,SpellUnit_HealthBelow30                                                           
                                                            }
                                                        ) then --print("Spirit of Redemption")
               
               
                                                    elseif CastSpellUnits(
                                                        _spell.ray_of_hope
                                                        ,_unitids.standard_friendly
                                                        ,RemainingCooldown(_spell.ray_of_hope) < 0.5 and have_ray_of_hope_talent and combat
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            --,SpellUnit_NoRecasting
                                                            ,SpellUnit_HealthBelow50
                                                            ,SpellUnit_RangeCheck
                                                            
                                                        }
                                                            --,RankUnits_MaxHealthDeficitPercent
                                                    ) then  --print("ray of hope")
               
   
               
                                            --+++++++++++PVP END+++++++++++
               



                                            --+++++++++++++++++START ATTACK+++++++++++++++++++




                                        elseif CastSpellUnits(
                                            _spell.holy_fire
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.holy_fire) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Smite")


                                        elseif CastSpellUnits(
                                        _spell.shadow_word_death
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                            ) then --print("Shadow Word: Death")

                                        elseif CastSpellUnits(
                                            _spell.shadow_word_pain
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_MyDebuffExpired
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Shadow Word: Pain")   
                    

                                        elseif CastSpellUnits(
                                            _spell.shadow_word_pain
                                                    ,_unitids.standard_hostile
                                                    ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                    ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("shadow word: pain refresh") 

                                        elseif CastSpellUnits(
                                            _spell.holy_word_chastise
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.holy_word_chastise) < 0.5
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Smite")

                                                elseif CastSpellUnits(
                                                    _spell.divine_star
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                        }
                                                    ) then --print("Divine Star")
                        
                                

                                        elseif CastSpellUnits(
                                            _spell.smite
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Smite")
                                                                    




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
                                            _spell.holy_fire
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.holy_fire) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Smite")


                                        elseif CastSpellUnits(
                                        _spell.shadow_word_death
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                            ) then --print("Shadow Word: Death")

                                        elseif CastSpellUnits(
                                            _spell.shadow_word_pain
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_MyDebuffExpired
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Shadow Word: Pain")   
                    

                                        elseif CastSpellUnits(
                                            _spell.shadow_word_pain
                                                    ,_unitids.standard_hostile
                                                    ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                    ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("shadow word: pain refresh") 

                                        elseif CastSpellUnits(
                                            _spell.holy_word_chastise
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.holy_word_chastise) < 0.5
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Smite")

                                                elseif CastSpellUnits(
                                                    _spell.divine_star
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                        }
                                                    ) then --print("Divine Star")
                        
                                                                                    
                                                    elseif CastSpellUnits(
                                                        _spell.premonition
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                                ,SpellUnit_PremonitionExpired
                                                            }
                                                        ) then --print("Premonition")
            
                                                        elseif CastSpellUnits(
                                                            _spell.lightwell,_unitids.player
                                                                ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                }
                                                            ) then --print("Lightwell")
    

                                        elseif CastSpellUnits(
                                            _spell.smite
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Smite")
                                                                    

                                    elseif CastSpellUnits(
                                        _spell.renew
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.renew) < 0.5
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                            ,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Renew")        



                   
                                    elseif CastSpellUnits(
                                        _spell.holy_nova
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Halo")
                
            

                                    elseif CastSpellUnits(
                                        _spell.shield
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                --,SpellUnit_WeakenedSoulExpired
                                            }
                                        ) then print("Power Word: Shield Normal line 8351")

        
                                        elseif CastSpellUnits(
                                            _spell.heal,_unitids.raid_friendly
                                            ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_NoRecasting
                                                ,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                            }
                                                ,RankUnits_MaxHealthDeficitPercent
                                        ) then  --print("heal")
        


                                    --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  
                                    --+++++++++++PVP START+++++++++++
                                    elseif CastSpellUnits(
                                        _spell.holy_ward
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired                                                                
                                            }
                                        ) then --print("Holy Ward")

                                    --+++++++++++PVP END+++++++++++



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
                                                _spell.power_word_life,_unitids.raid_friendly
                                                    ,have_power_word_life_talent and combat 
                                                    and RemainingCooldown(440678) < 0.5  and have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.50
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_NoRecasting  
                                                        ,SpellUnit_HealthBelow50                                                                                            
                                                    }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                                ) then --print("Power Word: Life 50%")
            
                                
                                            elseif CastSpellUnits(
                                                _spell.power_word_life,_unitids.raid_friendly
                                                    ,have_power_word_life_talent and combat 
                                                    and RemainingCooldown(373481) < 0.5 and not have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.35
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow35                                                                             
                                                    }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                                ) then --print("Power Word: Life 35%")
                                                
                                                
                                                    
                                            elseif CastSpellUnits(
                                                _spell.heal
                                                ,_unitids.raid_friendly
                                                ,RemainingCooldown(_spell.heal) < 0.5 and _unit.player.buff["Waste No Time"].remaining > 0
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_MediumHealth
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("Waste no time heal")
                   

                
                                            elseif CastSpellUnits(
                                                _spell.flash_heal
                                                ,_unitids.raid_friendly
                                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("Surge of Light flash heal")


                                            elseif CastSpellUnits(
                                                _spell.holy_word_serenity
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow75
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("Holy Word: Serenity")

                                                elseif CastSpellUnits(
                                                    _spell.holy_word_sanctify
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and have_holy_word_sanctify_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow75

                                                    }
                                                        --,RankUnits_MaxHealthDeficitPercent
                                                    ) then  --print("Holy Word: Sanctify")

                                                elseif CastSpellUnits(
                                                    _spell.holy_word_serenity
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat and have_apotheosis_talent and _unit.player.buff["Apotheosis"].remaining > 0
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow80
                                                        ,SpellUnit_RangeCheck
                                                        
                                                    }
                                                        ,RankUnits_MaxHealthDeficitPercent
                                                    ) then  --print("Holy Word: Serenity")
        


                                                    elseif CastSpellUnits(
                                                _spell.holy_word_sanctify
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and have_apotheosis_talent and _unit.player.buff["Apotheosis"].remaining > 0 and have_holy_word_sanctify_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    
                                                }
                                                    --,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("Holy Word: Sanctify")
                
                    

                                            elseif CastSpellUnits(
                                                _spell.prayer_of_mending
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.prayer_of_mending) < 0.5 and combat and have_prayer_of_mending_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_Expired
                                                        ,SpellUnit_RangeCheck
                                                        --,SpellUnit_NoRecasting
                                                        --,OOC_Rank
                                                    }
                                                    ,RankUnits_PvETargets
                                                ) then --print("Prayer of Mending")
                                                

                                            elseif CastSpellUnits(
                                                _spell.circle_of_healing
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.circle_of_healing) < 0.5 and Botchuloz_Circle_of_Healing_Detail(400,2) and combat and have_circle_of_healing_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_RangeCheck
                                                        --,SpellUnit_NoRecasting
                                                    }
                                                ) then --print("cirlce of healing")

                                                elseif CastSpellUnits(
                                                    _spell.prayer_of_healing
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.prayer_of_healing) < 0.5 and stationary and combat and _unit.player.buff["Prayer Circle"].remaining > 0 and have_prayer_circle_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_HealthBelow75
                                                        ,SpellUnit_RangeCheck
                                                        
                                                    }
                                                        ,RankUnits_MaxHealthDeficitPercent
                                                    ) then  --print("Holy Word: Serenity")
    
                                                elseif CastSpellUnits(
                                                    _spell.guardian_spirit
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and not have_guardian_angel_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow50
                                                        ,SpellUnit_RangeCheck
                                                        
                                                    }
                                                        --,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("Guardian Spirit Normal")

                                                elseif CastSpellUnits(
                                                    _spell.guardian_spirit
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and have_guardian_angel_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow60
                                                        ,SpellUnit_RangeCheck
                                                        
                                                    }
                                                        --,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("Guardian Spirit Talent")

                                                        
                                                elseif CastSpellUnits(
                                                    _spell.greater_heal
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.greater_heal) < 0.5 and stationary and combat and have_greater_heal_talent
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow50
                                                        ,SpellUnit_RangeCheck
                                                        
                                                    }
                                                        --,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("greater heal")

                                                elseif CastSpellUnits(
                                                    _spell.apotheosis
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.apotheosis) < 0.5 and combat and GroupHealthDeficit() > 5000 and have_apotheosis_talent
                                                    ) then --print("Apotheosis")


                                                elseif CastSpellUnits(
                                                    _spell.symbol_of_hope
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.symbol_of_hope) < 0.5 and combat and mana_percent <0.60 and stationary_for > 5.0 and have_symbol_of_hope_talent
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            ,SpellUnit_BreakingBuffsExpired
                                                        }
                                                        ) then --print("Symbol of Hope")
                               
                    

                                                        elseif CastSpellUnits(
                                                            _spell.halo
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                }
                                                            ) then --print("Halo")
                                    
                                    
                                                            elseif CastSpellUnits(
                                                                _spell.divine_star
                                                                    ,_unitids.player
                                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                                    ,{
                                                                        SpellUnit_AliveAndFriendly
                                                                    }
                                                                ) then --print("Divine Star")
                                                                                        
                                                                elseif CastSpellUnits(
                                                                    _spell.premonition
                                                                        ,_unitids.player
                                                                        ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                                        ,{
                                                                            SpellUnit_AliveAndFriendly
                                                                            ,SpellUnit_PremonitionExpired
                                                                        }
                                                                    ) then --print("Premonition")

                                                                        elseif CastSpellUnits(
                                                                            _spell.lightwell,_unitids.player
                                                                                ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                                                ,{
                                                                                    SpellUnit_AliveAndFriendly
                                                                                }
                                                                            ) then --print("Lightwell")
                    
                
                        
                                                elseif CastSpellUnits(
                                                    _spell.renew
                                                    ,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.renew) < 0.5
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_ExpiringOrExpired
                                                        ,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Renew")        
                
                


                                           
                        elseif CastSpellUnits(
                            _spell.holy_nova
                                ,_unitids.player
                                ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                ,{
                                    SpellUnit_AliveAndFriendly
                                }
                            ) then --print("Halo")
    

                

                                                elseif CastSpellUnits(
                                                    _spell.shield
                                                        ,_unitids.standard_friendly
                                                        ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            ,SpellUnit_ExpiringOrExpired
                                                            --,SpellUnit_WeakenedSoulExpired
                                                            ,SpellUnit_RangeCheck
                                                            --,Botchuloz_SpellUnit_Help_Rank_Shield
                                                        }
                                                        ,RankUnits_PvETargets
                                                    ) then print("Power Word: Shield Normal line 8708")
    
    
                                                elseif CastSpellUnits(
                                                    _spell.flash_heal
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow40
                                                        ,SpellUnit_RangeCheck
                                                        
                                                    }
                                                        --,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("flash heal")


                                                elseif CastSpellUnits(
                                                    _spell.heal,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.heal) < 0.5 and stationary and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        --,SpellUnit_NoRecasting
                                                        ,SpellUnit_LowHealth
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                        ,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("heal")
                
                                                elseif CastSpellUnits(
                                                    _spell.heal,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                        ,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("heal")
                    

                                                --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                                                --+++++++++++PVP START+++++++++++
                                                        elseif CastSpellUnits(
                                                            _spell.holy_ward
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                    ,SpellUnit_ExpiringOrExpired                                                                
                                                                }
                                                            ) then --print("Holy Ward")

    

                                                        elseif CastSpellUnits(
                                                            _spell.divine_ascension
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.divine_ascension) < 0.5 and have_divine_ascension_talent and combat
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                    ,SpellUnit_ExpiringOrExpired  
                                                                    ,SpellUnit_HealthBelow60                                                             
                                                                }
                                                            ) then --print("Divine Ascension")

                                                        elseif CastSpellUnits(
                                                            _spell.spirit_of_the_redeemer
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.spirit_of_the_redeemer) < 0.5 and have_spirit_of_the_redeemer_talent and combat
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                    ,SpellUnit_ExpiringOrExpired  
                                                                    ,SpellUnit_HealthBelow30                                                           
                                                                }
                                                            ) then --print("Spirit of Redemption")
    

                                                        elseif CastSpellUnits(
                                                            _spell.ray_of_hope
                                                            ,_unitids.standard_friendly
                                                            ,RemainingCooldown(_spell.ray_of_hope) < 0.5 and have_ray_of_hope_talent and combat
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                                --,SpellUnit_NoRecasting
                                                                ,SpellUnit_HealthBelow50
                                                                ,SpellUnit_RangeCheck
                                                                
                                                            }
                                                                --,RankUnits_MaxHealthDeficitPercent
                                                        ) then  --print("ray of hope")
            
            




                                                --+++++++++++PVP END+++++++++++



                                else _global.Off()
                                end   





                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)


                                                                            if 1 == 0 then

                        
                                                                            elseif CastSpellUnits(
                                                                                _spell.power_word_life,_unitids.raid_friendly
                                                                                    ,have_power_word_life_talent and combat 
                                                                                    and RemainingCooldown(440678) < 0.5  and have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.50
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        ,SpellUnit_RangeCheck
                                                                                        ,SpellUnit_NoRecasting  
                                                                                        ,SpellUnit_HealthBelow50                                                                                            
                                                                                    }
                                                                                    ,RankUnits_MaxHealthDeficitPercent
                                                                                ) then --print("Power Word: Life 50%")
                                            
                                                                
                                                                            elseif CastSpellUnits(
                                                                                _spell.power_word_life,_unitids.raid_friendly
                                                                                    ,have_power_word_life_talent and combat 
                                                                                    and RemainingCooldown(373481) < 0.5 and not have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.35
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        ,SpellUnit_RangeCheck
                                                                                        ,SpellUnit_NoRecasting
                                                                                        ,SpellUnit_HealthBelow35                                                                             
                                                                                    }
                                                                                    ,RankUnits_MaxHealthDeficitPercent
                                                                                ) then --print("Power Word: Life 35%")
                                                                                                                                                
                                                                                                                                    

                                                                                elseif CastSpellUnits(
                                                                                    _spell.heal
                                                                                    ,_unitids.raid_friendly
                                                                                    ,RemainingCooldown(_spell.heal) < 0.5 and _unit.player.buff["Waste No Time"].remaining > 0
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        --,SpellUnit_NoRecasting
                                                                                        ,SpellUnit_MediumHealth
                                                                                        ,SpellUnit_RangeCheck
                                                                                        
                                                                                    }
                                                                                        ,RankUnits_MaxHealthDeficitPercent
                                                                                ) then  --print("Waste no time heal")
                                                       
                                    
                                                                            elseif CastSpellUnits(
                                                                                _spell.flash_heal
                                                                                ,_unitids.raid_friendly
                                                                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                                                                                ,{
                                                                                    SpellUnit_AliveAndFriendly
                                                                                    --,SpellUnit_NoRecasting
                                                                                    ,SpellUnit_HealthBelow95
                                                                                    ,SpellUnit_RangeCheck
                                                                                    
                                                                                }
                                                                                    ,RankUnits_MaxHealthDeficitPercent
                                                                            ) then  --print("Surge of Light flash heal")



                                                                            elseif CastSpellUnits(
                                                                                _spell.holy_word_serenity
                                                                                ,_unitids.raid_friendly
                                                                                ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat
                                                                                ,{
                                                                                    SpellUnit_AliveAndFriendly
                                                                                    ,SpellUnit_NoRecasting
                                                                                    ,SpellUnit_LowHealth
                                                                                    ,SpellUnit_RangeCheck
                                                                                    
                                                                                }
                                                                                    --,RankUnits_MaxHealthDeficitPercent
                                                                            ) then  --print("Holy Word: Serenity")
                                                
                                                                            elseif CastSpellUnits(
                                                                                _spell.holy_word_sanctify
                                                                                ,_unitids.player
                                                                                ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and _unit.player.buff["Apotheosis"].remaining > 0 and have_holy_word_sanctify_talent
                                                                                ,{
                                                                                    SpellUnit_AliveAndFriendly
                                                                                    --,SpellUnit_NoRecasting
                                                                                    
                                                                                }
                                                                                    --,RankUnits_MaxHealthDeficitPercent
                                                                            ) then  --print("Holy Word: Sanctify")
                                                
                                                                            elseif CastSpellUnits(
                                                                                _spell.holy_word_serenity
                                                                                ,_unitids.raid_friendly
                                                                                ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat and _unit.player.buff["Apotheosis"].remaining > 0
                                                                                ,{
                                                                                    SpellUnit_AliveAndFriendly
                                                                                    ,SpellUnit_NoRecasting
                                                                                    ,SpellUnit_HealthBelow70
                                                                                    ,SpellUnit_RangeCheck
                                                                                    
                                                                                }
                                                                                    ,RankUnits_MaxHealthDeficitPercent
                                                                                ) then  --print("Holy Word: Serenity")
                                                
                                                
                                                                                elseif CastSpellUnits(
                                                                                    _spell.holy_word_sanctify
                                                                                    ,_unitids.player
                                                                                    ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and have_holy_word_sanctify_talent
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        --,SpellUnit_NoRecasting
                                                                                        ,SpellUnit_HealthBelow75

                                                                                    }
                                                                                        --,RankUnits_MaxHealthDeficitPercent
                                                                                    ) then  --print("Holy Word: Sanctify")

                                                    

                                                                        elseif CastSpellUnits(
                                                                            _spell.prayer_of_mending
                                                                                ,_unitids.standard_friendly
                                                                                ,RemainingCooldown(_spell.prayer_of_mending) < 0.5 and combat and have_prayer_of_mending_talent
                                                                                ,{
                                                                                    SpellUnit_AliveAndFriendly
                                                                                    --,SpellUnit_Expired
                                                                                    ,SpellUnit_RangeCheck
                                                                                    --,SpellUnit_NoRecasting
                                                                                    --,OOC_Rank
                                                                                }
                                                                                ,RankUnits_PvETargets
                                                                            ) then --print("Prayer of Mending")
                                                                                

                                                                            elseif CastSpellUnits(
                                                                                _spell.circle_of_healing
                                                                                    ,_unitids.standard_friendly
                                                                                    ,RemainingCooldown(_spell.circle_of_healing) < 0.5 and Botchuloz_Circle_of_Healing_Detail(400,2) and combat and have_circle_of_healing_talent
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        ,SpellUnit_RangeCheck
                                                                                        --,SpellUnit_NoRecasting
                                                                                    }
                                                                                ) then --print("circle of healing")

                                                                                elseif CastSpellUnits(
                                                                                    _spell.prayer_of_healing
                                                                                    ,_unitids.standard_friendly
                                                                                    ,RemainingCooldown(_spell.prayer_of_healing) < 0.5 and stationary and combat and _unit.player.buff["Prayer Circle"].remaining > 0 and have_prayer_circle_talent
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        ,SpellUnit_HealthBelow75
                                                                                        ,SpellUnit_RangeCheck
                                                                                        
                                                                                    }
                                                                                        ,RankUnits_MaxHealthDeficitPercent
                                                                                    ) then  --print("Holy Word: Serenity")
                                    
                                                                                elseif CastSpellUnits(
                                                                                    _spell.guardian_spirit
                                                                                    ,_unitids.standard_friendly
                                                                                    ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and not have_guardian_angel_talent
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        --,SpellUnit_NoRecasting
                                                                                        ,SpellUnit_HealthBelow50
                                                                                        ,SpellUnit_RangeCheck
                                                                                        
                                                                                    }
                                                                                        --,RankUnits_MaxHealthDeficitPercent
                                                                                ) then  --print("Guardian Spirit Normal")

                                                                                elseif CastSpellUnits(
                                                                                    _spell.guardian_spirit
                                                                                    ,_unitids.standard_friendly
                                                                                    ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and have_guardian_angel_talent
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        --,SpellUnit_NoRecasting
                                                                                        ,SpellUnit_HealthBelow60
                                                                                        ,SpellUnit_RangeCheck
                                                                                        
                                                                                    }
                                                                                        --,RankUnits_MaxHealthDeficitPercent
                                                                                ) then  --print("Guardian Spirit Talent")

                                                                                        
                                                                                elseif CastSpellUnits(
                                                                                    _spell.greater_heal
                                                                                    ,_unitids.standard_friendly
                                                                                    ,RemainingCooldown(_spell.greater_heal) < 0.5 and stationary and combat and have_greater_heal_talent
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        --,SpellUnit_NoRecasting
                                                                                        ,SpellUnit_HealthBelow50
                                                                                        ,SpellUnit_RangeCheck
                                                                                        
                                                                                    }
                                                                                        --,RankUnits_MaxHealthDeficitPercent
                                                                                ) then  --print("greater heal")

                                                                                elseif CastSpellUnits(
                                                                                    _spell.apotheosis
                                                                                    ,_unitids.player
                                                                                    ,RemainingCooldown(_spell.apotheosis) < 0.5 and combat and GroupHealthDeficit() > 5000 and have_apotheosis_talent
                                                                                    ) then --print("Apotheosis")

                                                                                elseif CastSpellUnits(
                                                                                    _spell.symbol_of_hope
                                                                                        ,_unitids.player
                                                                                        ,RemainingCooldown(_spell.symbol_of_hope) < 0.5 and combat and mana_percent <0.60 and stationary_for > 5.0 and have_symbol_of_hope_talent
                                                                                        ,{
                                                                                            SpellUnit_AliveAndFriendly
                                                                                            ,SpellUnit_BreakingBuffsExpired
                                                                                        }
                                                                                        ) then --print("Symbol of Hope")
                                                                   
                                                                                        elseif CastSpellUnits(
                                                                                            _spell.halo
                                                                                                ,_unitids.player
                                                                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                                                                                ,{
                                                                                                    SpellUnit_AliveAndFriendly
                                                                                                }
                                                                                            ) then --print("Halo")
                                                                    
                                                                    
                                                                                            elseif CastSpellUnits(
                                                                                                _spell.divine_star
                                                                                                    ,_unitids.player
                                                                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                                                                    ,{
                                                                                                        SpellUnit_AliveAndFriendly
                                                                                                    }
                                                                                                ) then --print("Divine Star")
                                                                                                                                                                        
                                                                                                elseif CastSpellUnits(
                                                                                                    _spell.premonition
                                                                                                        ,_unitids.player
                                                                                                        ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                                                                        ,{
                                                                                                            SpellUnit_AliveAndFriendly
                                                                                                            ,SpellUnit_PremonitionExpired
                                                                                                        }
                                                                                                    ) then --print("Premonition")
                                                        
                                                                                                    elseif CastSpellUnits(
                                                                                                        _spell.lightwell,_unitids.player
                                                                                                            ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                                                                            ,{
                                                                                                                SpellUnit_AliveAndFriendly
                                                                                                            }
                                                                                                        ) then --print("Lightwell")
                                                

                                                        
                                                                                elseif CastSpellUnits(
                                                                                    _spell.renew
                                                                                    ,_unitids.raid_friendly
                                                                                    ,RemainingCooldown(_spell.renew) < 0.5
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        ,SpellUnit_ExpiringOrExpired
                                                                                        ,SpellUnit_HealthBelow95
                                                                                        ,SpellUnit_RangeCheck
                                                                                    }
                                                                                ) then --print("Renew")        
                                                

                   
                                                                        elseif CastSpellUnits(
                                                                            _spell.holy_nova
                                                                                ,_unitids.player
                                                                                ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                                                                ,{
                                                                                    SpellUnit_AliveAndFriendly
                                                                                }
                                                                            ) then --print("Halo")
                                                    
                                                
                                            
                                                                                    

                                                                        elseif CastSpellUnits(
                                                                            _spell.shield
                                                                                ,_unitids.standard_friendly
                                                                                ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                                                                ,{
                                                                                    SpellUnit_AliveAndFriendly
                                                                                    ,SpellUnit_ExpiringOrExpired
                                                                                    --,SpellUnit_WeakenedSoulExpired
                                                                                    ,SpellUnit_RangeCheck
                                                                                    --,Botchuloz_SpellUnit_Help_Rank_Shield
                                                                                }
                                                                                ,RankUnits_PvETargets
                                                                            ) then print("Power Word: Shield Normal line 9119")
                                    
                                    
                                                                                elseif CastSpellUnits(
                                                                                    _spell.flash_heal
                                                                                    ,_unitids.standard_friendly
                                                                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and combat
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        --,SpellUnit_NoRecasting
                                                                                        ,SpellUnit_HealthBelow40
                                                                                        ,SpellUnit_RangeCheck
                                                                                        
                                                                                    }
                                                                                        --,RankUnits_MaxHealthDeficitPercent
                                                                                ) then  --print("flash heal")


                                                                                elseif CastSpellUnits(
                                                                                    _spell.heal,_unitids.raid_friendly
                                                                                    ,RemainingCooldown(_spell.heal) < 0.5 and stationary and combat
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        --,SpellUnit_NoRecasting
                                                                                        ,SpellUnit_LowHealth
                                                                                        ,SpellUnit_RangeCheck
                                                                                    }
                                                                                        ,RankUnits_MaxHealthDeficitPercent
                                                                                ) then  --print("heal")
                                                
                                                                                elseif CastSpellUnits(
                                                                                    _spell.heal,_unitids.raid_friendly
                                                                                    ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                                                                    ,{
                                                                                        SpellUnit_AliveAndFriendly
                                                                                        ,SpellUnit_NoRecasting
                                                                                        ,SpellUnit_HealthBelow95
                                                                                        ,SpellUnit_RangeCheck
                                                                                    }
                                                                                        ,RankUnits_MaxHealthDeficitPercent
                                                                                ) then  --print("heal")
                                                
                                                                                --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                                                                                --+++++++++++PVP START+++++++++++
                                                                                        elseif CastSpellUnits(
                                                                                            _spell.holy_ward
                                                                                                ,_unitids.player
                                                                                                ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                                                                                ,{
                                                                                                    SpellUnit_AliveAndFriendly
                                                                                                    ,SpellUnit_ExpiringOrExpired                                                                
                                                                                                }
                                                                                            ) then --print("Holy Ward")


                                                                                        elseif CastSpellUnits(
                                                                                            _spell.divine_ascension
                                                                                                ,_unitids.player
                                                                                                ,RemainingCooldown(_spell.divine_ascension) < 0.5 and have_divine_ascension_talent and combat
                                                                                                ,{
                                                                                                    SpellUnit_AliveAndFriendly
                                                                                                    ,SpellUnit_ExpiringOrExpired  
                                                                                                    ,SpellUnit_HealthBelow60                                                             
                                                                                                }
                                                                                            ) then --print("Divine Ascension")

                                                                                        elseif CastSpellUnits(
                                                                                            _spell.spirit_of_the_redeemer
                                                                                                ,_unitids.player
                                                                                                ,RemainingCooldown(_spell.spirit_of_the_redeemer) < 0.5 and have_spirit_of_the_redeemer_talent and combat
                                                                                                ,{
                                                                                                    SpellUnit_AliveAndFriendly
                                                                                                    ,SpellUnit_ExpiringOrExpired  
                                                                                                    ,SpellUnit_HealthBelow30                                                           
                                                                                                }
                                                                                            ) then --print("Spirit of Redemption")
                                    

                                                                                        elseif CastSpellUnits(
                                                                                            _spell.ray_of_hope
                                                                                            ,_unitids.standard_friendly
                                                                                            ,RemainingCooldown(_spell.ray_of_hope) < 0.5 and have_ray_of_hope_talent and combat
                                                                                            ,{
                                                                                                SpellUnit_AliveAndFriendly
                                                                                                --,SpellUnit_NoRecasting
                                                                                                ,SpellUnit_HealthBelow50
                                                                                                ,SpellUnit_RangeCheck
                                                                                                
                                                                                            }
                                                                                                --,RankUnits_MaxHealthDeficitPercent
                                                                                        ) then  --print("ray of hope")
                                            
                                        

                                                                                --+++++++++++PVP END+++++++++++

                                                                                --++++++++++++++++++++++++++++START ATTACK++++++++++++++++++++++++
                                                                            elseif CastSpellUnits(
                                                                                _spell.holy_fire
                                                                                    ,_unitids.target
                                                                                    ,RemainingCooldown(_spell.holy_fire) < 0.5 and stationary
                                                                                    ,{
                                                                                        SpellUnit_UnitAliveAndHostile
                                                                                        ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                                                        ,SpellUnit_ValidHarm
                                                                                    }
                                                                                    ) then --print("Smite")


                                                                            elseif CastSpellUnits(
                                                                            _spell.shadow_word_death
                                                                                    ,_unitids.standard_hostile
                                                                                    ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                                                    ,{
                                                                                    SpellUnit_UnitAliveAndHostile
                                                                                    ,SpellUnit_RangeCheck
                                                                                    ,SpellUnit_ValidHarm
                                                                                    }
                                                                                ) then --print("Shadow Word: Death")

                                                                            elseif CastSpellUnits(
                                                                                _spell.shadow_word_pain
                                                                                    ,_unitids.standard_hostile
                                                                                    ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                                                    ,{
                                                                                    SpellUnit_UnitAliveAndHostile
                                                                                    ,SpellUnit_MyDebuffExpired
                                                                                    ,SpellUnit_RangeCheck
                                                                                    ,SpellUnit_ValidHarm
                                                                                    }
                                                                                    ) then --print("Shadow Word: Pain")   
                                                        

                                                                            elseif CastSpellUnits(
                                                                                _spell.shadow_word_pain
                                                                                        ,_unitids.standard_hostile
                                                                                        ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                                                        ,{
                                                                                        SpellUnit_UnitAliveAndHostile
                                                                                        ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                                                                        ,SpellUnit_RangeCheck
                                                                                        ,SpellUnit_ValidHarm
                                                                                        }
                                                                                        ) then --print("shadow word: pain refresh") 

                                                                            elseif CastSpellUnits(
                                                                                _spell.holy_word_chastise
                                                                                    ,_unitids.standard_hostile
                                                                                    ,RemainingCooldown(_spell.holy_word_chastise) < 0.5
                                                                                    ,{
                                                                                        SpellUnit_UnitAliveAndHostile
                                                                                        ,SpellUnit_RangeCheck
                                                                                        ,SpellUnit_ValidHarm
                                                                                    }
                                                                                    ) then --print("Smite")

                                                                                    elseif CastSpellUnits(
                                                                                        _spell.divine_star
                                                                                            ,_unitids.player
                                                                                            ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                                                            ,{
                                                                                                SpellUnit_AliveAndFriendly
                                                                                            }
                                                                                        ) then --print("Divine Star")
                                                            
                                                                    

                                                                            elseif CastSpellUnits(
                                                                                _spell.smite
                                                                                    ,_unitids.target
                                                                                    ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                                                                    ,{
                                                                                        SpellUnit_UnitAliveAndHostile
                                                                                        ,SpellUnit_RangeCheck
                                                                                        ,SpellUnit_ValidHarm
                                                                                    }
                                                                                    ) then --print("Smite")
                                                                                                        



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
                                        _spell.holy_fire
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.holy_fire) < 0.5 and stationary
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Smite")


                                    elseif CastSpellUnits(
                                    _spell.shadow_word_death
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                            ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                            }
                                        ) then --print("Shadow Word: Death")

                                    elseif CastSpellUnits(
                                        _spell.shadow_word_pain
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                            ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_MyDebuffExpired
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Shadow Word: Pain")   
                

                                    elseif CastSpellUnits(
                                        _spell.shadow_word_pain
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("shadow word: pain refresh") 

                                    elseif CastSpellUnits(
                                        _spell.holy_word_chastise
                                            ,_unitids.standard_hostile
                                            ,RemainingCooldown(_spell.holy_word_chastise) < 0.5
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Smite")

                                            elseif CastSpellUnits(
                                                _spell.divine_star
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                    }
                                                ) then --print("Divine Star")
                    
                            

                                    elseif CastSpellUnits(
                                        _spell.smite
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Smite")
                                                                

                                            elseif CastSpellUnits(
                                                _spell.halo
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                    }
                                                ) then --print("Halo")
                        
                        
                                                elseif CastSpellUnits(
                                                    _spell.divine_star
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                        }
                                                    ) then --print("Divine Star")
                                                                            
                                                    elseif CastSpellUnits(
                                                        _spell.premonition
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                                ,SpellUnit_PremonitionExpired
                                                            }
                                                        ) then --print("Premonition")
            
                                                        elseif CastSpellUnits(
                                                            _spell.lightwell,_unitids.player
                                                                ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                }
                                                            ) then --print("Lightwell")
    
            
                                    elseif CastSpellUnits(
                                        _spell.renew
                                        ,_unitids.raid_friendly
                                        ,RemainingCooldown(_spell.renew) < 0.5
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                            ,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Renew")        
    
    

                               
                                    elseif CastSpellUnits(
                                        _spell.holy_nova
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Halo")
                
            


                                elseif CastSpellUnits(
                                    _spell.shield
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                            --,SpellUnit_WeakenedSoulExpired
                                        }
                                    ) then print("Power Word: Shield Normal line 9473")

    
                                    elseif CastSpellUnits(
                                        _spell.heal,_unitids.raid_friendly
                                        ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_NoRecasting
                                            ,SpellUnit_HealthBelow95
                                            ,SpellUnit_RangeCheck
                                        }
                                            ,RankUnits_MaxHealthDeficitPercent
                                    ) then  --print("heal")
    


                                --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  
                                --+++++++++++PVP START+++++++++++
                                elseif CastSpellUnits(
                                    _spell.holy_ward
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired                                                                
                                        }
                                    ) then --print("Holy Ward")

                                --+++++++++++PVP END+++++++++++



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
                            _spell.power_word_life,_unitids.raid_friendly
                                ,have_power_word_life_talent and combat 
                                and RemainingCooldown(440678) < 0.5  and have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.50
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_NoRecasting  
                                    ,SpellUnit_HealthBelow50                                                                                            
                                }
                                ,RankUnits_MaxHealthDeficitPercent
                            ) then --print("Power Word: Life 50%")

            
                        elseif CastSpellUnits(
                            _spell.power_word_life,_unitids.raid_friendly
                                ,have_power_word_life_talent and combat 
                                and RemainingCooldown(373481) < 0.5 and not have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.35
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_HealthBelow35                                                                             
                                }
                                ,RankUnits_MaxHealthDeficitPercent
                            ) then --print("Power Word: Life 35%")

                            elseif CastSpellUnits(
                                _spell.heal
                                ,_unitids.raid_friendly
                                ,RemainingCooldown(_spell.heal) < 0.5 and _unit.player.buff["Waste No Time"].remaining > 0
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    --,SpellUnit_NoRecasting
                                    ,SpellUnit_MediumHealth
                                    ,SpellUnit_RangeCheck
                                    
                                }
                                    ,RankUnits_MaxHealthDeficitPercent
                            ) then  --print("Waste no time heal")
   


                         elseif CastSpellUnits(
                             _spell.flash_heal
                             ,_unitids.raid_friendly
                             ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                             ,{
                                 SpellUnit_AliveAndFriendly
                                 --,SpellUnit_NoRecasting
                                 ,SpellUnit_HealthBelow95
                                 ,SpellUnit_RangeCheck
                                 
                             }
                                 ,RankUnits_MaxHealthDeficitPercent
                         ) then  --print("Surge of Light flash heal")


                         elseif CastSpellUnits(
                            _spell.holy_word_serenity
                            ,_unitids.raid_friendly
                            ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat
                            ,{
                                SpellUnit_AliveAndFriendly
                                ,SpellUnit_NoRecasting
                                ,SpellUnit_LowHealth
                                ,SpellUnit_RangeCheck
                                
                            }
                                --,RankUnits_MaxHealthDeficitPercent
                        ) then  --print("Holy Word: Serenity")

                        elseif CastSpellUnits(
                            _spell.holy_word_sanctify
                            ,_unitids.player
                            ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and _unit.player.buff["Apotheosis"].remaining > 0 and have_holy_word_sanctify_talent
                            ,{
                                SpellUnit_AliveAndFriendly
                                --,SpellUnit_NoRecasting
                                
                            }
                                --,RankUnits_MaxHealthDeficitPercent
                        ) then  --print("Holy Word: Sanctify")

                        elseif CastSpellUnits(
                            _spell.holy_word_serenity
                            ,_unitids.raid_friendly
                            ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat and _unit.player.buff["Apotheosis"].remaining > 0
                            ,{
                                SpellUnit_AliveAndFriendly
                                ,SpellUnit_NoRecasting
                                ,SpellUnit_HealthBelow70
                                ,SpellUnit_RangeCheck
                                
                            }
                                ,RankUnits_MaxHealthDeficitPercent
                            ) then  --print("Holy Word: Serenity")


                             elseif CastSpellUnits(
                                 _spell.holy_word_sanctify
                                 ,_unitids.player
                                 ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and have_holy_word_sanctify_talent
                                 ,{
                                     SpellUnit_AliveAndFriendly
                                     --,SpellUnit_NoRecasting
                                     ,SpellUnit_HealthBelow75

                                 }
                                     --,RankUnits_MaxHealthDeficitPercent
                                 ) then  --print("Holy Word: Sanctify")



                            elseif CastSpellUnits(
                                _spell.prayer_of_mending
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.prayer_of_mending) < 0.5 and combat and have_prayer_of_mending_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_Expired
                                        ,SpellUnit_RangeCheck
                                        --,SpellUnit_NoRecasting
                                        --,OOC_Rank
                                    }
                                    ,RankUnits_PvETargets
                                ) then --print("Prayer of Mending")
                             

                         elseif CastSpellUnits(
                             _spell.circle_of_healing
                                 ,_unitids.standard_friendly
                                 ,RemainingCooldown(_spell.circle_of_healing) < 0.5 and combat and have_circle_of_healing_talent
                                 ,{
                                     SpellUnit_AliveAndFriendly
                                     ,SpellUnit_RangeCheck
                                     --,SpellUnit_NoRecasting
                                     ,SpellUnit_HealthBelow90
                                 }
                             ) then --print("circle of healing")


                             elseif CastSpellUnits(
                                 _spell.guardian_spirit
                                 ,_unitids.standard_friendly
                                 ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and not have_guardian_angel_talent
                                 ,{
                                     SpellUnit_AliveAndFriendly
                                     --,SpellUnit_NoRecasting
                                     ,SpellUnit_HealthBelow50
                                     ,SpellUnit_RangeCheck
                                     
                                 }
                                     --,RankUnits_MaxHealthDeficitPercent
                             ) then  --print("Guardian Spirit Normal")

                             elseif CastSpellUnits(
                                 _spell.guardian_spirit
                                 ,_unitids.standard_friendly
                                 ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and have_guardian_angel_talent
                                 ,{
                                     SpellUnit_AliveAndFriendly
                                     --,SpellUnit_NoRecasting
                                     ,SpellUnit_HealthBelow60
                                     ,SpellUnit_RangeCheck
                                     
                                 }
                                     --,RankUnits_MaxHealthDeficitPercent
                             ) then  --print("Guardian Spirit Talent")

                                     
                                elseif CastSpellUnits(
                                    _spell.greater_heal
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.greater_heal) < 0.5 and stationary and combat and have_greater_heal_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_NoRecasting
                                        ,SpellUnit_HealthBelow50
                                        ,SpellUnit_RangeCheck
                                        
                                    }
                                        --,RankUnits_MaxHealthDeficitPercent
                                ) then  --print("greater heal")

                             elseif CastSpellUnits(
                                 _spell.apotheosis
                                 ,_unitids.player
                                 ,RemainingCooldown(_spell.apotheosis) < 0.5 and combat and GroupHealthDeficit() > 5000 and have_apotheosis_talent
                                 ) then --print("Apotheosis")


                                 elseif CastSpellUnits(
                                    _spell.symbol_of_hope
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.symbol_of_hope) < 0.5 and combat and mana_percent <0.60 and stationary_for > 5.0 and have_symbol_of_hope_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_BreakingBuffsExpired
                                        }
                                        ) then --print("Symbol of Hope")
               

                                        elseif CastSpellUnits(
                                            _spell.halo
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Halo")
                    
                    
                                            elseif CastSpellUnits(
                                                _spell.divine_star
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                    }
                                                ) then --print("Divine Star")
                                                                        
                                                elseif CastSpellUnits(
                                                    _spell.premonition
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            ,SpellUnit_PremonitionExpired
                                                        }
                                                    ) then --print("Premonition")
        
                                                    elseif CastSpellUnits(
                                                        _spell.lightwell,_unitids.player
                                                            ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                            }
                                                        ) then --print("Lightwell")

        
                                elseif CastSpellUnits(
                                    _spell.renew
                                    ,_unitids.raid_friendly
                                    ,RemainingCooldown(_spell.renew) < 0.5
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                        ,SpellUnit_HealthBelow95
                                        ,SpellUnit_RangeCheck
                                    }
                                ) then --print("Renew")        



                                elseif CastSpellUnits(
                                    _spell.shield
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                            --,SpellUnit_WeakenedSoulExpired
                                            ,SpellUnit_RangeCheck
                                            --,Botchuloz_SpellUnit_Help_Rank_Shield
                                        }
                                        ,RankUnits_PvETargets
                                    ) then print("Power Word: Shield Normal line 9793")


                             elseif CastSpellUnits(
                                 _spell.flash_heal
                                 ,_unitids.standard_friendly
                                 ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and combat
                                 ,{
                                     SpellUnit_AliveAndFriendly
                                     --,SpellUnit_NoRecasting
                                     ,SpellUnit_HealthBelow40
                                     ,SpellUnit_RangeCheck
                                     
                                 }
                                     --,RankUnits_MaxHealthDeficitPercent
                             ) then  --print("flash heal")



           
                                elseif CastSpellUnits(
                                    _spell.holy_nova
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                        }
                                    ) then --print("Halo")
            
        
                             elseif CastSpellUnits(
                                 _spell.prayer_of_healing
                                 ,_unitids.standard_friendly
                                 ,RemainingCooldown(_spell.prayer_of_healing) < 0.5 and stationary and combat
                                 ,{
                                     SpellUnit_AliveAndFriendly
                                     --,SpellUnit_NoRecasting
                                     ,SpellUnit_HealthBelow90
                                     ,SpellUnit_RangeCheck
                                     
                                 }
                                     --,RankUnits_MaxHealthDeficitPercent
                             ) then  --print("heal")


        
                            elseif CastSpellUnits(
                                _spell.heal,_unitids.raid_friendly
                                ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_HealthBelow95
                                    ,SpellUnit_RangeCheck
                                }
                                    ,RankUnits_MaxHealthDeficitPercent
                            ) then  --print("heal")

                             --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                             --+++++++++++PVP START+++++++++++
                                     elseif CastSpellUnits(
                                         _spell.holy_ward
                                             ,_unitids.player
                                             ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                             ,{
                                                 SpellUnit_AliveAndFriendly
                                                 ,SpellUnit_ExpiringOrExpired                                                                
                                             }
                                         ) then --print("Holy Ward")



                                     elseif CastSpellUnits(
                                         _spell.divine_ascension
                                             ,_unitids.player
                                             ,RemainingCooldown(_spell.divine_ascension) < 0.5 and have_divine_ascension_talent and combat
                                             ,{
                                                 SpellUnit_AliveAndFriendly
                                                 ,SpellUnit_ExpiringOrExpired  
                                                 ,SpellUnit_HealthBelow60                                                             
                                             }
                                         ) then --print("Divine Ascension")

                                     elseif CastSpellUnits(
                                         _spell.spirit_of_the_redeemer
                                             ,_unitids.player
                                             ,RemainingCooldown(_spell.spirit_of_the_redeemer) < 0.5 and have_spirit_of_the_redeemer_talent and combat
                                             ,{
                                                 SpellUnit_AliveAndFriendly
                                                 ,SpellUnit_ExpiringOrExpired  
                                                 ,SpellUnit_HealthBelow30                                                           
                                             }
                                         ) then --print("Spirit of Redemption")


                                     elseif CastSpellUnits(
                                         _spell.ray_of_hope
                                         ,_unitids.standard_friendly
                                         ,RemainingCooldown(_spell.ray_of_hope) < 0.5 and have_ray_of_hope_talent and combat
                                         ,{
                                             SpellUnit_AliveAndFriendly
                                             --,SpellUnit_NoRecasting
                                             ,SpellUnit_HealthBelow50
                                             ,SpellUnit_RangeCheck
                                             
                                         }
                                             --,RankUnits_MaxHealthDeficitPercent
                                     ) then  --print("ray of hope")






                             --+++++++++++PVP END+++++++++++



             else _global.Off()
             end   



                    elseif attack_healer then
                        spam_string = spam_string .. "attack_"
                         --print(spam_string)

                                        if 1 == 0 then


                        
                                        elseif CastSpellUnits(
                                            _spell.power_word_life,_unitids.raid_friendly
                                                ,have_power_word_life_talent and combat 
                                                and RemainingCooldown(440678) < 0.5  and have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.50
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_NoRecasting  
                                                    ,SpellUnit_HealthBelow50                                                                                            
                                                }
                                                ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Power Word: Life 50%")
        
                            
                                        elseif CastSpellUnits(
                                            _spell.power_word_life,_unitids.raid_friendly
                                                ,have_power_word_life_talent and combat 
                                                and RemainingCooldown(373481) < 0.5 and not have_miraculous_recovery_talent --and _unit.raid_friendly.health.percent < 0.35
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow35                                                                             
                                                }
                                                ,RankUnits_MaxHealthDeficitPercent
                                            ) then --print("Power Word: Life 35%")
                                    
            

                                            elseif CastSpellUnits(
                                                _spell.heal
                                                ,_unitids.raid_friendly
                                                ,RemainingCooldown(_spell.heal) < 0.5 and _unit.player.buff["Waste No Time"].remaining > 0
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_MediumHealth
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("Waste no time heal")
                   
    
                                        elseif CastSpellUnits(
                                            _spell.flash_heal
                                            ,_unitids.raid_friendly
                                            ,RemainingCooldown(_spell.flash_heal) < 0.5 and _unit.player.buff["Surge of Light"].remaining > 0
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_NoRecasting
                                                ,SpellUnit_HealthBelow95
                                                ,SpellUnit_RangeCheck
                                                
                                            }
                                                ,RankUnits_MaxHealthDeficitPercent
                                        ) then  --print("Surge of Light flash heal")
               
               

                                        elseif CastSpellUnits(
                                            _spell.holy_word_serenity
                                            ,_unitids.raid_friendly
                                            ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_NoRecasting
                                                ,SpellUnit_LowHealth
                                                ,SpellUnit_RangeCheck
                                                
                                            }
                                                --,RankUnits_MaxHealthDeficitPercent
                                        ) then  --print("Holy Word: Serenity")
            
                                        elseif CastSpellUnits(
                                            _spell.holy_word_sanctify
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and _unit.player.buff["Apotheosis"].remaining > 0 and have_holy_word_sanctify_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                --,SpellUnit_NoRecasting
                                                
                                            }
                                                --,RankUnits_MaxHealthDeficitPercent
                                        ) then  --print("Holy Word: Sanctify")
            
                                        elseif CastSpellUnits(
                                            _spell.holy_word_serenity
                                            ,_unitids.raid_friendly
                                            ,RemainingCooldown(_spell.holy_word_serenity) < 0.5 and combat and _unit.player.buff["Apotheosis"].remaining > 0
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_NoRecasting
                                                ,SpellUnit_HealthBelow70
                                                ,SpellUnit_RangeCheck
                                                
                                            }
                                                ,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("Holy Word: Serenity")
            
                           
                                            elseif CastSpellUnits(
                                                _spell.holy_word_sanctify
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.holy_word_sanctify) < 0.5 and combat and have_holy_word_sanctify_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow75
               
                                                }
                                                    --,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("Holy Word: Sanctify")
               
               
                
               
                            elseif CastSpellUnits(
                                _spell.prayer_of_mending
                                    ,_unitids.standard_friendly
                                    ,RemainingCooldown(_spell.prayer_of_mending) < 0.5 and combat and have_prayer_of_mending_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        --,SpellUnit_Expired
                                        ,SpellUnit_RangeCheck
                                        --,SpellUnit_NoRecasting
                                        --,OOC_Rank
                                    }
                                    ,RankUnits_PvETargets
                                ) then --print("Prayer of Mending")
                                            
               
                                        elseif CastSpellUnits(
                                            _spell.circle_of_healing
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.circle_of_healing) < 0.5 and combat and have_circle_of_healing_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_RangeCheck
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow90
                                                }
                                            ) then --print("circle of healing")
               
               
                                            elseif CastSpellUnits(
                                                _spell.guardian_spirit
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and not have_guardian_angel_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow50
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    --,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("Guardian Spirit Normal")
               
                                            elseif CastSpellUnits(
                                                _spell.guardian_spirit
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.guardian_spirit) < 0.5 and combat and have_guardian_spirit_talent and have_guardian_angel_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow60
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    --,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("Guardian Spirit Talent")
               
                                                    
                                               elseif CastSpellUnits(
                                                   _spell.greater_heal
                                                   ,_unitids.standard_friendly
                                                   ,RemainingCooldown(_spell.greater_heal) < 0.5 and stationary and combat and have_greater_heal_talent
                                                   ,{
                                                       SpellUnit_AliveAndFriendly
                                                       --,SpellUnit_NoRecasting
                                                       ,SpellUnit_HealthBelow50
                                                       ,SpellUnit_RangeCheck
                                                       
                                                   }
                                                       --,RankUnits_MaxHealthDeficitPercent
                                               ) then  --print("greater heal")
               
                                            elseif CastSpellUnits(
                                                _spell.apotheosis
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.apotheosis) < 0.5 and combat and GroupHealthDeficit() > 5000 and have_apotheosis_talent
                                                ) then --print("Apotheosis")
               
 
                                                elseif CastSpellUnits(
                                                    _spell.symbol_of_hope
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.symbol_of_hope) < 0.5 and combat and mana_percent <0.60 and stationary_for > 5.0 and have_symbol_of_hope_talent
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            ,SpellUnit_BreakingBuffsExpired
                                                        }
                                                        ) then --print("Symbol of Hope")
                               
              
                                                        elseif CastSpellUnits(
                                                            _spell.halo
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                }
                                                            ) then --print("Halo")
                                    
                                    
                                                            elseif CastSpellUnits(
                                                                _spell.divine_star
                                                                    ,_unitids.player
                                                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                                    ,{
                                                                        SpellUnit_AliveAndFriendly
                                                                    }
                                                                ) then --print("Divine Star")
                                                                                        
                                                                elseif CastSpellUnits(
                                                                    _spell.premonition
                                                                        ,_unitids.player
                                                                        ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                                        ,{
                                                                            SpellUnit_AliveAndFriendly
                                                                            ,SpellUnit_PremonitionExpired
                                                                        }
                                                                    ) then --print("Premonition")
                        
                                                                    elseif CastSpellUnits(
                                                                        _spell.lightwell,_unitids.player
                                                                            ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                                            ,{
                                                                                SpellUnit_AliveAndFriendly
                                                                            }
                                                                        ) then --print("Lightwell")
                
                
                        
                                                elseif CastSpellUnits(
                                                    _spell.renew
                                                    ,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.renew) < 0.5
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_ExpiringOrExpired
                                                        ,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                ) then --print("Renew")        
                
                
                               
               
                                            elseif CastSpellUnits(
                                                _spell.shield
                                                    ,_unitids.standard_friendly
                                                    ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_ExpiringOrExpired
                                                        --,SpellUnit_WeakenedSoulExpired
                                                        ,SpellUnit_RangeCheck
                                                        --,Botchuloz_SpellUnit_Help_Rank_Shield
                                                    }
                                                    ,RankUnits_PvETargets
                                                ) then print("Power Word: Shield Normal line 10197")
               
               
                                            elseif CastSpellUnits(
                                                _spell.flash_heal
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow40
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    --,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("flash heal")
               

                                            --shared speed spells END
                                   
                                        elseif CastSpellUnits(
                                            _spell.holy_nova
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Halo")
                    
                
           
                                            elseif CastSpellUnits(
                                                _spell.prayer_of_healing
                                                ,_unitids.standard_friendly
                                                ,RemainingCooldown(_spell.prayer_of_healing) < 0.5 and stationary and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    --,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow90
                                                    ,SpellUnit_RangeCheck
                                                    
                                                }
                                                    --,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("heal")
               
               
                                            elseif CastSpellUnits(
                                                _spell.heal,_unitids.raid_friendly
                                                ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_NoRecasting
                                                    ,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                }
                                                    ,RankUnits_MaxHealthDeficitPercent
                                            ) then  --print("heal")
                           
               
                                            --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  
               
                                            --+++++++++++PVP START+++++++++++
                                                    elseif CastSpellUnits(
                                                        _spell.holy_ward
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                                ,SpellUnit_ExpiringOrExpired                                                                
                                                            }
                                                        ) then --print("Holy Ward")
               
               
                                                    elseif CastSpellUnits(
                                                        _spell.divine_ascension
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.divine_ascension) < 0.5 and have_divine_ascension_talent and combat
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                                ,SpellUnit_ExpiringOrExpired  
                                                                ,SpellUnit_HealthBelow60                                                             
                                                            }
                                                        ) then --print("Divine Ascension")
               
                                                    elseif CastSpellUnits(
                                                        _spell.spirit_of_the_redeemer
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.spirit_of_the_redeemer) < 0.5 and have_spirit_of_the_redeemer_talent and combat
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                                ,SpellUnit_ExpiringOrExpired  
                                                                ,SpellUnit_HealthBelow30                                                           
                                                            }
                                                        ) then --print("Spirit of Redemption")
               
               
                                                    elseif CastSpellUnits(
                                                        _spell.ray_of_hope
                                                        ,_unitids.standard_friendly
                                                        ,RemainingCooldown(_spell.ray_of_hope) < 0.5 and have_ray_of_hope_talent and combat
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                            --,SpellUnit_NoRecasting
                                                            ,SpellUnit_HealthBelow50
                                                            ,SpellUnit_RangeCheck
                                                            
                                                        }
                                                            --,RankUnits_MaxHealthDeficitPercent
                                                    ) then  --print("ray of hope")
               
               
               
               
               
               
                                            --+++++++++++PVP END+++++++++++
               
               



                                            --++++++++++++++++++++++START ATTACK++++++++++++++++++++++++++
                                        elseif CastSpellUnits(
                                            _spell.holy_fire
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.holy_fire) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Smite")


                                        elseif CastSpellUnits(
                                        _spell.shadow_word_death
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                            ) then --print("Shadow Word: Death")

                                        elseif CastSpellUnits(
                                            _spell.shadow_word_pain
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_MyDebuffExpired
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Shadow Word: Pain")   
                    

                                        elseif CastSpellUnits(
                                            _spell.shadow_word_pain
                                                    ,_unitids.standard_hostile
                                                    ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                    ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("shadow word: pain refresh") 

                                        elseif CastSpellUnits(
                                            _spell.holy_word_chastise
                                                ,_unitids.standard_hostile
                                                ,RemainingCooldown(_spell.holy_word_chastise) < 0.5
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Smite")

                                                elseif CastSpellUnits(
                                                    _spell.divine_star
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                        }
                                                    ) then --print("Divine Star")
                        
                                

                                        elseif CastSpellUnits(
                                            _spell.smite
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Smite")
                                                                    



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
                                                _spell.holy_fire
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.holy_fire) < 0.5 and stationary
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Smite")


                                            elseif CastSpellUnits(
                                            _spell.shadow_word_death
                                                    ,_unitids.standard_hostile
                                                    ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.45
                                                    ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                ) then --print("Shadow Word: Death")

                                            elseif CastSpellUnits(
                                                _spell.shadow_word_pain
                                                    ,_unitids.standard_hostile
                                                    ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                    ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_MyDebuffExpired
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Shadow Word: Pain")   
                        
                   
                                            elseif CastSpellUnits(
                                                _spell.shadow_word_pain
                                                        ,_unitids.standard_hostile
                                                        ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                                        ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                        }
                                                        ) then --print("shadow word: pain refresh") 

                                            elseif CastSpellUnits(
                                                _spell.holy_word_chastise
                                                    ,_unitids.standard_hostile
                                                    ,RemainingCooldown(_spell.holy_word_chastise) < 0.5
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Smite")

                                                    elseif CastSpellUnits(
                                                        _spell.divine_star
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                            }
                                                        ) then --print("Divine Star")
                           
                                      

                                            elseif CastSpellUnits(
                                                _spell.smite
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.smite) < 0.5 and stationary
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Smite")
                                                                       

                                                    elseif CastSpellUnits(
                                                        _spell.halo
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_holy_disc_talent and combat and stationary
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                            }
                                                        ) then --print("Halo")
                                
                                
                                                        elseif CastSpellUnits(
                                                            _spell.divine_star
                                                                ,_unitids.player
                                                                ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_holy_disc_talent and combat
                                                                ,{
                                                                    SpellUnit_AliveAndFriendly
                                                                }
                                                            ) then --print("Divine Star")
                                
                                                                        
                                                            elseif CastSpellUnits(
                                                                _spell.premonition
                                                                    ,_unitids.player
                                                                    ,RemainingCooldown(_spell.premonition) < 0.5 and have_premonition_talent and combat and time_in_combat >= 10 
                                                                    ,{
                                                                        SpellUnit_AliveAndFriendly
                                                                        ,SpellUnit_PremonitionExpired
                                                                    }
                                                                ) then --print("Premonition")
                    
            
                                                                elseif CastSpellUnits(
                                                                    _spell.lightwell,_unitids.player
                                                                        ,RemainingCooldown(_spell.lightwell) < 0.5 and have_lightwell_talent and combat and time_in_combat >= 15 
                                                                        ,{
                                                                            SpellUnit_AliveAndFriendly
                                                                        }
                                                                    ) then --print("Lightwell")
            

                                            elseif CastSpellUnits(
                                                _spell.renew
                                                ,_unitids.raid_friendly
                                                ,RemainingCooldown(_spell.renew) < 0.5
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    ,SpellUnit_HealthBelow95
                                                    ,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Renew")        
                            

                                   
                                        elseif CastSpellUnits(
                                            _spell.holy_nova
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Halo")
                    
                
        
            
                                            
                                            elseif CastSpellUnits(
                                                _spell.shield
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.shield) < 0.5 and combat or (have_body_and_soul_talent and not stationary)
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_ExpiringOrExpired
                                                        --,SpellUnit_WeakenedSoulExpired
                                                        ,SpellUnit_SpeedBuffExpired
                                                    }
                                                ) then print("Power Word: Shield Sprint 10580")
                
                                                                
                
                                                elseif CastSpellUnits(
                                                    _spell.heal,_unitids.raid_friendly
                                                    ,RemainingCooldown(_spell.heal) < 0.5 and stationary and not combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_NoRecasting
                                                        ,SpellUnit_HealthBelow95
                                                        ,SpellUnit_RangeCheck
                                                    }
                                                        ,RankUnits_MaxHealthDeficitPercent
                                                ) then  --print("heal")
                

                                        --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  
                                        --+++++++++++PVP START+++++++++++
                                        elseif CastSpellUnits(
                                            _spell.holy_ward
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.holy_ward) < 0.5 and have_holy_ward_talent and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired                                                                
                                                }
                                            ) then --print("Holy Ward")

                                        --+++++++++++PVP END+++++++++++


           
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
--         dP                      dP                     
--         88                      88                     
-- .d8888b. 88d888b. .d8888b. .d888b88 .d8888b. dP  dP  dP 
-- Y8ooooo. 88'  `88 88'  `88 88'  `88 88'  `88 88  88  88 
--      88 88    88 88.  .88 88.  .88 88.  .88 88.88b.88' 
-- `88888P' dP    dP `88888P8 `88888P8 `88888P' 8888P Y8P  
--                                                                                                        
    elseif shadow_spec     == delphi.spec then    
        --Spec Spells START
        BindSpellToUnits(_spell.dispersion,                 _unitids.player)
        BindSpellToUnits(_spell.shadow_crash,               _unitids.player)
        BindSpellToUnits(_spell.vampiric_embrace,           _unitids.player)
        BindSpellToUnits(_spell.shadowform,                 _unitids.player)--,"/cast [noform:1]Shadowform","",1)
        BindSpellToUnits(_spell.flash_heal,                 _unitids.player)
        BindSpellToUnits(_spell.power_infusion,             _unitids.player)
        BindSpellToUnits(_spell.angelic_feather,            _unitids.player)--,"/cast [@player]Angelic Feather","",1)
        BindSpellToUnits(_spell.void_tendrils,              _unitids.player)
        BindSpellToUnits(_spell.dark_ascension,             _unitids.player)

        BindSpellToUnits(_spell.mindblast,                  _unitids.target)
        BindSpellToUnits(_spell.mindbender,                 _unitids.target)
        BindSpellToUnits(_spell.shadowfiend,                _unitids.target)
        BindSpellToUnits(_spell.void_bolt,                  _unitids.target)
        BindSpellToUnits(_spell.void_eruption,              _unitids.target)
        BindSpellToUnits(_spell.void_torrent,               _unitids.target)
        BindSpellToUnits(_spell.mind_flay,                  _unitids.target)
        BindSpellToUnits(_spell.psychic_horror,             _unitids.target)
        BindSpellToUnits(_spell.psyfiend,                   _unitids.target)
--        BindSpellToUnits(_spell.thoughtsteal,               _unitids.target)
        BindSpellToUnits(_spell.devouring_plague,           _unitids.target)
        BindSpellToUnits(_spell.mindgames,                  _unitids.target)  --talent
        BindSpellToUnits(_spell.silence,                  _unitids.target)  --talent

        BindSpellToUnits(_spell.void_shift,                 _unitids.standard_friendly)
        BindSpellToUnits(_spell.flash_heal,                 _unitids.standard_friendly)
        BindSpellToUnits(_spell.power_infusion,             _unitids.standard_friendly)
--      BindSpellToUnits(_spell.purify_disease,             _unitids.standard_friendly)


        BindSpellToUnits(_spell.vampiric_touch,             _unitids.standard_hostile)
        BindSpellToUnits(_spell.shadow_word_pain,           _unitids.standard_hostile,   "","/targetenemy")

        BindSpellToUnits(_spell.vampiric_touch,             _unitids.raid_hostile)
        BindSpellToUnits(_spell.shadow_word_pain,            _unitids.raid_hostile,   "","/targetenemy")
--REMOVED
        -- BindSpellToUnits(_spell.searing_nightmare,          _unitids.target)
        -- BindSpellToUnits(_spell.mind_bomb,                  _unitids.target)
        -- BindSpellToUnits(_spell.searing_nightmare,          _unitids.raid_hostile)
        --BindSpellToUnits(_spell.mind_bomb,                  _unitids.raid_hostile)
        -- BindSpellToUnits(_spell.searing_nightmare,          _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.mind_bomb,                  _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.madness,                    _unitids.target)
        --BindSpellToUnits(_spell.damnation,                  _unitids.target)
        -- BindSpellToUnits(_spell.damnation,                  _unitids.standard_hostile)
        -- BindSpellToUnits(_spell.damnation,                  _unitids.raid_hostile)

    
        --Spec Spells END
        
        spam_string = "shadow_"
        if 1 == 0 then
        -----    
        elseif CastSpellUnits(
            _spell.shadowform
            ,_unitids.player
            ,RemainingCooldown(_spell.shadowform) < 0.5 and _unit.player.buff[_spell.shadowform].remaining == 0 and _unit.player.buff["Voidform"].remaining == 0
        ) then --print("Shadowform")

        elseif have_silence_talent and combat and delphi.spell[_spell.silence].ready and delphi.unit.target.interruptable and CheckInterruptRule("target",delphi.unit.target.cast_name)  then _global.SetSpellUnit(_spell.silence,"target")
        --elseif kick_smart and delphi.spell[_spell.interrupt].ready and delphi.unit.target.interruptable and CheckInterruptRule("target",delphi.unit.target.cast_name) and not interrupt_icd and delphi.spell[_spell.stun].ready  then _global.SetSpellUnit(_spell.stun,"target") -- base for tank, 3rd tier talent for unholy
    
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
                                _spell.vampiric_embrace,_unitids.player
                                    ,RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent 
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                    }
                                ) then --print("Vampiric Embrace")

                                elseif CastSpellUnits(
                                    _spell.dispersion,_unitids.player
                                        ,RemainingCooldown(_spell.dispersion) < 0.5 and combat and player_health_perc < 0.425 and have_dispersion_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                        }
                                    ) then --print("Dispersion")
 



                                    elseif CastSpellUnits(
                                        _spell.flash_heal
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_HealthBelow80
                                                ,SpellUnit_RangeCheck
                                            }
                                        ) then --print("Shadow Mend")
                                            
                                            
                                        elseif CastSpellUnits(
                                            _spell.shield
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    --,SpellUnit_WeakenedSoulExpired
                                                }
                                            ) then print("Power Word: Shield row 10759")
                   
                
                
            
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
                            _spell.vampiric_embrace,_unitids.player
                                ,RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent 
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_ExpiringOrExpired
                                }
                            ) then --print("Vampiric Embrace")

                            elseif CastSpellUnits(
                                _spell.dispersion,_unitids.player
                                    ,RemainingCooldown(_spell.dispersion) < 0.5 and combat and player_health_perc < 0.425 and have_dispersion_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Dispersion")





                            elseif CastSpellUnits(
                            _spell.void_bolt
                                ,_unitids.target
                                ,RemainingCooldown(_spell.void_bolt) < 0.5 and _unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dissonant Echoes"].remaining > 0
                                ,{SpellUnit_RangeCheck,	SpellUnit_UnitAliveAndHostile,SpellUnit_ValidHarm,SpellUnit_SafeToAttack					}

                                ) then --print("Void Bolt")



                                elseif CastSpellUnits(
                                    _spell.void_eruption
                                        ,_unitids.target
                                        ,RemainingCooldown(_spell.void_eruption) < 0.5 and stationary and have_void_eruption_talent and combat and time_in_combat > 10
                                        ,{SpellUnit_RangeCheck,	SpellUnit_UnitAliveAndHostile,SpellUnit_ValidHarm,SpellUnit_SafeToAttack					}
                                        ) then --print("Void Eruption")
        

                                elseif CastSpellUnits(
                                    _spell.dark_ascension
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.dark_ascension) < 0.5 and combat and stationary and have_dark_ascension_talent and time_in_combat > 10
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                        }
                                        ) then --print("Dark Ascension")   
        
                    

                                elseif CastSpellUnits(
                                    _spell.shadow_word_death
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and player_health_perc > 0.40 and _unit.player.buff["Deathspeaker"].remaining > 0
                                            ,{SpellUnit_RangeCheck,	SpellUnit_UnitAliveAndHostile,SpellUnit_ValidHarm,SpellUnit_SafeToAttack					}
                                        ) then --print("Shadow Word: Death Proc")
                
                
                            elseif CastSpellUnits(
                            _spell.shadow_word_death
                                    ,_unitids.target
                                    ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.40
                                    ,{SpellUnit_RangeCheck,	SpellUnit_UnitAliveAndHostile,SpellUnit_ValidHarm,SpellUnit_SafeToAttack					}
                                ) then --print("Shadow Word: Death")

                                    

                            elseif CastSpellUnits(
                                _spell.devouring_plague
                                    ,_unitids.target
                                    ,RemainingCooldown(_spell.devouring_plague) < 0.5 and _unit.player.buff["Mind Devourer"].remaining > 0
                                    ,{SpellUnit_RangeCheck,	SpellUnit_UnitAliveAndHostile,SpellUnit_ValidHarm,SpellUnit_SafeToAttack					}
                                ) then --print("Devouring Plague")   
                                        


                            elseif CastSpellUnits(
                            _spell.devouring_plague
                                ,_unitids.target
                                ,RemainingCooldown(_spell.devouring_plague) < 0.5 and not (_unit.player.buff["Mind Devourer"].remaining > 0) and ((not have_minds_eye_talent and not have_distorted_reality_talent and (insanity > 50)) or (have_minds_eye_talent and (insanity > 45)) or (have_distorted_reality_talent and (insanity > 55)))
                                ,{SpellUnit_RangeCheck,	SpellUnit_UnitAliveAndHostile,SpellUnit_ValidHarm,SpellUnit_SafeToAttack					}
                            ) then --print("Devouring Plague")   



                            -- elseif CastSpellUnits(
                            -- _spell.damnation
                            --     ,_unitids.standard_hostile
                            --     ,RemainingCooldown(_spell.damnation) < 0.5 and have_damnation_talent and combat
                            --         ,{
                            --             SpellUnit_UnitAliveAndHostile
                            --             ,Botchuloz_VT_or_SWP_Missing
                            --             ,SpellUnit_RangeCheck
                            --             ,SpellUnit_ValidHarm
                            --         }
                            --     ) then --print("Damnation")




                            elseif CastSpellUnits(
                            _spell.vampiric_touch
                                ,_unitids.raid_hostile
                                ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and have_misery_talent and not RecentCasting(_spell.vampiric_touch,0.095)
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,Botchuloz_VT_or_SWP_Missing
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_SafeToAttack
                                }
                                ) then --print("Vampiric Touch Misery")
                        
        
        
                            elseif CastSpellUnits(
                            _spell.vampiric_touch
                                ,_unitids.raid_hostile
                                ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and not have_misery_talent
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_MyDebuffExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_SafeToAttack
                                }
                                ) then --print("Vampiric Touch")   

                            elseif CastSpellUnits(
                            _spell.shadow_word_pain
                                ,_unitids.raid_hostile
                                ,RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_misery_talent or (have_misery_talent and not stationary and combat)
                                ,{
                                SpellUnit_UnitAliveAndHostile
                                ,SpellUnit_MyDebuffExpired
                                ,SpellUnit_RangeCheck
                                ,SpellUnit_ValidHarm
                                ,SpellUnit_SafeToAttack
                                }
                                ) then --print("Shadow Word: Pain")   

                            elseif CastSpellUnits(
                            _spell.vampiric_touch
                                ,_unitids.raid_hostile
                                ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and _unit.player.buff["Unfurling Darkness"].remaining_or_high < 5
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                    --,SpellUnit_MyDebuffExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_SafeToAttack
                                }
                                ) then --print("Vampiric Touch Unfurling Darkness")   
        
                            elseif CastSpellUnits(
                                _spell.mindblast
                                    ,_unitids.target
                                    ,RemainingCooldown(_spell.mindblast) < 0.5 and _unit.player.buff["Shadowy Insights"].remaining > 0
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        ,SpellUnit_SafeToAttack
                                    }
                                        ) then --print("Mind Blast Instant")
    
                                    elseif CastSpellUnits(
                                        _spell.mindgames
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.mindgames) < 0.5 and have_mindgames_talent and stationary and combat
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                ,SpellUnit_ValidHarm 
                                                ,SpellUnit_SafeToAttack
                                            }
                                                        ) then --print("Mindgames")
                            
                                
                            elseif CastSpellUnits(
                            _spell.void_torrent
                                ,_unitids.target
                                ,RemainingCooldown(_spell.void_torrent) < 0.5 and (stationary or have_dark_energy_talent) and have_void_torrent_talent
                                ,{
                                SpellUnit_UnitAliveAndHostile
                                ,SpellUnit_Debuff_ExpiringNextGCDOrExpired
                                ,SpellUnit_RangeCheck
                                ,SpellUnit_ValidHarm
                                ,SpellUnit_SafeToAttack
                                }
                                ) then --print("Void Torrent")

                            elseif CastSpellUnits(
                            _spell.mindblast
                                ,_unitids.target
                                ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    ,SpellUnit_SafeToAttack
                                }
                                ) then --print("Mind Blast")

                                elseif CastSpellUnits(
                                    _spell.power_infusion
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.power_infusion) < 0.5 and combat and (_unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dark Ascension"].remaining > 0) and (not in_group or not have_twins_of_the_sun_priestess_talent)
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                        }
                                        ) then --print("Power Infusion Player")   
        

                                elseif CastSpellUnits(
                                    _spell.power_infusion
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.power_infusion) < 0.5 and combat and (_unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dark Ascension"].remaining > 0) and in_group and have_twins_of_the_sun_priestess_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,Botchuloz_SpellUnit_Help_Power_Infusion_Rank
                                        }
                                        ) then --print("Power Infusion Friendly")   
        

                                        elseif CastSpellUnits(
                                            _spell.shadowfiend,_unitids.target
                                                ,((RemainingCooldown(_spell.voidwraith) < 0.5 and have_voidwraith_talent) or 
                                                 (RemainingCooldown(_spell.mindbender ) < 0.5 and not have_voidwraith_talent and have_mindbender_shadow_talent) or 
                                                 (RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_voidwraith_talent and not have_mindbender_shadow_talent)) and 
                                                 insanity <30 and time_in_combat >= 10 
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    ,SpellUnit_SafeToAttack
                                                }
                                                                ) then --print("Shadowfiend")
                

                            -- elseif CastSpellUnits(
                            -- _spell.shadowfiend
                            --     ,_unitids.target
                            --     ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_shadow_talent and insanity <30 and combat
                            --     ,{
                            --         SpellUnit_UnitAliveAndHostile
                            --         ,SpellUnit_RangeCheck
                            --         ,SpellUnit_ValidHarm
                            --     }
                            --     ) then --print("Shadowfiend")

                            -- elseif CastSpellUnits(
                            -- _spell.mindbender
                            --     ,_unitids.target
                            --     ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_shadow_talent and insanity <30 and combat
                            --     ,{
                            --         SpellUnit_UnitAliveAndHostile
                            --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                            --         ,SpellUnit_ValidHarm
                            --     }
                            --     ) then --print("Mindbender")
                            
        
                            elseif CastSpellUnits(
                            _spell.vampiric_touch
                                ,_unitids.raid_hostile
                                ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and have_misery_talent
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,Botchuloz_VT_or_SWP_ExpiringUnder5_ButIsntExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    ,SpellUnit_NoRecasting
                                    ,SpellUnit_SafeToAttack
                                }
                                ) then --print("Vampiric Touch Misery Refresh")
    
                            -- elseif CastSpellUnits(
                            -- _spell.damnation
                            --     ,_unitids.standard_hostile
                            --     ,RemainingCooldown(_spell.damnation) < 0.5 and have_damnation_talent and combat
                            --         ,{
                            --             SpellUnit_UnitAliveAndHostile
                            --             ,Botchuloz_VT_or_SWP_ExpiringUnder5_ButIsntExpired
                            --             ,SpellUnit_RangeCheck
                            --             ,SpellUnit_ValidHarm
                            --         }
                            --     ) then --print("Damnation refresh") 

                            elseif CastSpellUnits(
                            _spell.shadow_word_pain
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_misery_talent or (have_misery_talent and not stationary and combat)
                                    ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    ,SpellUnit_SafeToAttack
                                }
                                    ) then --print("shadow word: pain refresh")   
 

                            -- elseif CastSpellUnits(
                            --     _spell.mind_bomb
                            --             ,_unitids.standard_hostile
                            --             ,RemainingCooldown(_spell.mind_bomb) < 0.5 and player_health_perc < 0.6 and have_mind_bomb_talent and combat
                            --             ,{
                            --             SpellUnit_UnitAliveAndHostile
                            --             ,Botchuloz_RangeCheckHarm_30Yard
                            --             ,SpellUnit_ValidHarm
                            --             }
                            --             ) then --print("Mind Bomb")   
                            
        

                        elseif CastSpellUnits(
                            _spell.halo
                                ,_unitids.player
                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_shadow_talent and combat and stationary
                                ,{
                                    SpellUnit_AliveAndFriendly
                                }
                            ) then --print("Halo")
    
    
                            elseif CastSpellUnits(
                                _spell.divine_star
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_shadow_talent and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Divine Star")
    
                   

                            elseif CastSpellUnits(
                                _spell.flash_heal
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow70
                                        --,SpellUnit_RangeCheck
                                    }
                                ) then --print("Shadow Mend")

        


                            elseif CastSpellUnits(
                            _spell.mind_flay
                                ,_unitids.target
                                ,RemainingCooldown(_spell.mind_flay) < 0.5 and stationary
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                ,SpellUnit_Debuff_ExpiringNextGCDOrExpired
                                ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                ,SpellUnit_ValidHarm
                                ,SpellUnit_SafeToAttack
                                }
                                ) then --print("Mind Flay")


                       
                            elseif CastSpellUnits(
                                _spell.holy_nova
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Holy Nova")
        
    
                                            
                                            
                                        elseif CastSpellUnits(
                                            _spell.shield
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_ExpiringOrExpired
                                                    --,SpellUnit_WeakenedSoulExpired
                                                }
                                            ) then print("Power Word: Shield row 11173")
                
                
                                                

                            --elseif RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent then _global.SetSpellUnit(_spell.vampiric_embrace,"player")  
                            --elseif RemainingCooldown(_spell.dispersion) < 0.5       and player_health_perc < 0.4 then _global.SetSpellUnit(_spell.dispersion,"player")  

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
                                        _spell.vampiric_embrace,_unitids.player
                                            ,RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent 
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                            }
                                        ) then --print("Vampiric Embrace")
        
                                        elseif CastSpellUnits(
                                            _spell.dispersion,_unitids.player
                                                ,RemainingCooldown(_spell.dispersion) < 0.5 and combat and player_health_perc < 0.425 and have_dispersion_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Dispersion")
         
        
                                        
                                    elseif CastSpellUnits(
                                    _spell.flash_heal
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_HealthBelow80
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Shadow Mend")
                                            
                                            
                                    elseif CastSpellUnits(
                                        _spell.shield
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                --,SpellUnit_WeakenedSoulExpired
                                            }
                                        ) then print("Power Word: Shield row 11242")
        
                                            
                                        -- elseif CastSpellUnits(
                                        --     _spell.angelic_feather
                                        --         ,_unitids.player
                                        --         ,RemainingCooldown(_spell.angelic_feather) < 0.5 and not stationary and have_angelic_feather_talent and angelic_feather_check()
                                        --         ,{
                                        --             SpellUnit_MyBuffExpired
                                        --             ,SpellUnit_SpeedBuffExpired
                                        --         }
                                        --         ) then --print("Angelic Feather")
    
                                                
                                        -- elseif CastSpellUnits(
                                        --     _spell.shield
                                        --         ,_unitids.player
                                        --         ,RemainingCooldown(_spell.shield) < 0.5 and not combat and have_body_and_soul_talent and not stationary
                                        --         ,{
                                        --             SpellUnit_AliveAndFriendly
                                        --             ,SpellUnit_SpeedBuffExpired
                                        --             --,SpellUnit_ExpiringOrExpired
                                        --             --,SpellUnit_WeakenedSoulExpired
                                        --         }
                                        --     ) then --print("Power Word: Shield Sprint")            
            
        
        

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
                                    _spell.vampiric_embrace,_unitids.player
                                        ,RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent 
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_ExpiringOrExpired
                                        }
                                    ) then --print("Vampiric Embrace")
    
                                    elseif CastSpellUnits(
                                        _spell.dispersion,_unitids.player
                                            ,RemainingCooldown(_spell.dispersion) < 0.5 and combat and player_health_perc < 0.425 and have_dispersion_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                        ) then --print("Dispersion")
     
    

                                elseif CastSpellUnits(
                                    _spell.void_bolt
                                        ,_unitids.target
                                        ,RemainingCooldown(_spell.void_bolt) < 0.5 and _unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dissonant Echoes"].remaining > 0
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Void Bolt")
        
        
        
                                        elseif CastSpellUnits(
                                            _spell.void_eruption
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.void_eruption) < 0.5 and stationary and have_void_eruption_talent and combat and time_in_combat > 10
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Void Eruption")
                        

                                                elseif CastSpellUnits(
                                                    _spell.dark_ascension
                                                        ,_unitids.player
                                                        ,RemainingCooldown(_spell.dark_ascension) < 0.5 and combat and stationary and have_dark_ascension_talent and time_in_combat > 10
                                                        ,{
                                                            SpellUnit_AliveAndFriendly
                                                        }
                                                        ) then --print("Dark Ascension")   
                        
                        


                                                elseif CastSpellUnits(
                                                    _spell.shadow_word_death
                                                            ,_unitids.target
                                                            ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and player_health_perc > 0.40 and _unit.player.buff["Deathspeaker"].remaining > 0
                                                            ,{
                                                                SpellUnit_UnitAliveAndHostile
                                                            ,SpellUnit_RangeCheck
                                                            ,SpellUnit_ValidHarm
                                                            }
                                                        ) then --print("Shadow Word: Death Proc")
                                
                                
                                            elseif CastSpellUnits(
                                            _spell.shadow_word_death
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.40
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                ) then --print("Shadow Word: Death")
                
                  

                                                elseif CastSpellUnits(
                                                    _spell.devouring_plague
                                                        ,_unitids.target
                                                        ,RemainingCooldown(_spell.devouring_plague) < 0.5 and _unit.player.buff["Mind Devourer"].remaining > 0
                                                        ,{
                                                            SpellUnit_UnitAliveAndHostile
                                                            ,SpellUnit_RangeCheck
                                                            ,SpellUnit_ValidHarm
                                                        }
                                                        ) then --print("Devouring Plague")   
                                                            
                    
                    
                                                elseif CastSpellUnits(
                                                _spell.devouring_plague
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.devouring_plague) < 0.5 and not (_unit.player.buff["Mind Devourer"].remaining > 0) and ((not have_minds_eye_talent and not have_distorted_reality_talent and (insanity > 50)) or (have_minds_eye_talent and (insanity > 45)) or (have_distorted_reality_talent and (insanity > 55)))
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Devouring Plague")   
                                


                                -- elseif CastSpellUnits(
                                -- _spell.damnation
                                --     ,_unitids.standard_hostile
                                --     ,RemainingCooldown(_spell.damnation) < 0.5 and have_damnation_talent and combat
                                --         ,{
                                --             SpellUnit_UnitAliveAndHostile
                                --             ,Botchuloz_VT_or_SWP_Missing
                                --             ,SpellUnit_RangeCheck
                                --             ,SpellUnit_ValidHarm
                                --         }
                                --     ) then --print("Damnation")




                                elseif CastSpellUnits(
                                _spell.vampiric_touch
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and have_misery_talent and not RecentCasting(_spell.vampiric_touch,0.095)
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,Botchuloz_VT_or_SWP_Missing
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        ,SpellUnit_NoRecasting
                                    }
                                    ) then --print("Vampiric Touch Misery")



                                elseif CastSpellUnits(
                                _spell.vampiric_touch
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and not have_misery_talent
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_MyDebuffExpired
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        ,SpellUnit_NoRecasting
                                    }
                                    ) then --print("Vampiric Touch")   

                                elseif CastSpellUnits(
                                _spell.shadow_word_pain
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_misery_talent or (have_misery_talent and not stationary and combat)
                                    ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_MyDebuffExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Shadow Word: Pain")   

                                elseif CastSpellUnits(
                                _spell.vampiric_touch
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and _unit.player.buff["Unfurling Darkness"].remaining_or_high < 5
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        --,SpellUnit_MyDebuffExpired
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        ,SpellUnit_NoRecasting
                                    }
                                    ) then --print("Vampiric Touch Unfurling Darkness")   


                                elseif CastSpellUnits(
                                _spell.void_torrent
                                    ,_unitids.target
                                    ,RemainingCooldown(_spell.void_torrent) < 0.5 and (stationary or have_dark_energy_talent) and have_void_torrent_talent
                                    ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_Debuff_ExpiringNextGCDOrExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Void Torrent")

                                    elseif CastSpellUnits(
                                        _spell.power_infusion
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.power_infusion) < 0.5 and combat and (_unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dark Ascension"].remaining > 0) and (not in_group or not have_twins_of_the_sun_priestess_talent)
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                            ) then --print("Power Infusion Player")   
            
    
                                    elseif CastSpellUnits(
                                        _spell.power_infusion
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.power_infusion) < 0.5 and combat and (_unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dark Ascension"].remaining > 0) and in_group and have_twins_of_the_sun_priestess_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,Botchuloz_SpellUnit_Help_Power_Infusion_Rank
                                            }
                                            ) then --print("Power Infusion Friendly")   
            
    

                                        elseif CastSpellUnits(
                                            _spell.shadowfiend,_unitids.target
                                                ,((RemainingCooldown(_spell.voidwraith ) < 0.5 and have_voidwraith_talent) or 
                                                 (RemainingCooldown(_spell.mindbender ) < 0.5 and not have_voidwraith_talent and have_mindbender_shadow_talent) or 
                                                 (RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_voidwraith_talent and not have_mindbender_shadow_talent)) and 
                                                 insanity <30 and time_in_combat >= 10 
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Shadowfiend")
                

                            -- elseif CastSpellUnits(
                            -- _spell.shadowfiend
                            --     ,_unitids.target
                            --     ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_shadow_talent and insanity <30 and combat
                            --     ,{
                            --         SpellUnit_UnitAliveAndHostile
                            --         ,SpellUnit_RangeCheck
                            --         ,SpellUnit_ValidHarm
                            --     }
                            --     ) then --print("Shadowfiend")

                            -- elseif CastSpellUnits(
                            -- _spell.mindbender
                            --     ,_unitids.target
                            --     ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_shadow_talent and insanity <30 and combat
                            --     ,{
                            --         SpellUnit_UnitAliveAndHostile
                            --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                            --         ,SpellUnit_ValidHarm
                            --     }
                            --     ) then --print("Mindbender")

                                elseif CastSpellUnits(
                                _spell.vampiric_touch
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and have_misery_talent
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,Botchuloz_VT_or_SWP_ExpiringUnder5_ButIsntExpired
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        ,SpellUnit_NoRecasting
                                    }
                                    ) then --print("Vampiric Touch Misery Refresh")

                                -- elseif CastSpellUnits(
                                -- _spell.damnation
                                --     ,_unitids.standard_hostile
                                --     ,RemainingCooldown(_spell.damnation) < 0.5 and have_damnation_talent and combat
                                --         ,{
                                --             SpellUnit_UnitAliveAndHostile
                                --             ,Botchuloz_VT_or_SWP_ExpiringUnder5_ButIsntExpired
                                --             ,SpellUnit_RangeCheck
                                --             ,SpellUnit_ValidHarm
                                --         }
                                --     ) then --print("Damnation refresh") 

                                elseif CastSpellUnits(
                                _spell.shadow_word_pain
                                        ,_unitids.raid_hostile
                                        ,RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_misery_talent or (have_misery_talent and not stationary and combat)
                                        ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("shadow word: pain refresh")   


                                -- elseif CastSpellUnits(
                                --     _spell.mind_bomb
                                --             ,_unitids.standard_hostile
                                --             ,RemainingCooldown(_spell.mind_bomb) < 0.5 and player_health_perc < 0.6 and have_mind_bomb_talent and combat
                                --             ,{
                                --             SpellUnit_UnitAliveAndHostile
                                --             ,Botchuloz_RangeCheckHarm_30Yard
                                --             ,SpellUnit_ValidHarm
                                --             }
                                --             ) then --print("Mind Bomb")   
                                
    

                            elseif CastSpellUnits(
                                _spell.halo
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_shadow_talent and combat and stationary
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Halo")
        
        
                                elseif CastSpellUnits(
                                    _spell.divine_star
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_shadow_talent and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                        }
                                    ) then --print("Divine Star")
        


                                elseif CastSpellUnits(
                                    _spell.flash_heal
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_HealthBelow70
                                            --,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Shadow Mend")


                   
                        elseif CastSpellUnits(
                            _spell.holy_nova
                                ,_unitids.player
                                ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                ,{
                                    SpellUnit_AliveAndFriendly
                                }
                            ) then --print("Halo")
    


                                            
                                elseif CastSpellUnits(
                                _spell.mind_flay
                                    ,_unitids.target
                                    ,RemainingCooldown(_spell.mind_flay) < 0.5 and stationary
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_Debuff_ExpiringNextGCDOrExpired
                                    ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Mind Sear")



                                            
                                            
                                            elseif CastSpellUnits(
                                                _spell.shield
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                        ,SpellUnit_ExpiringOrExpired
                                                        --,SpellUnit_WeakenedSoulExpired
                                                    }
                                                ) then print("Power Word: Shield 11660")
                
                        
                                                            

                                -- elseif RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent
                                --         then _global.SetSpellUnit(_spell.vampiric_embrace,"player")  

                                --elseif RemainingCooldown(_spell.desperate_prayer) < 0.5 and combat and player_health_perc < 0.6 then _global.SetSpellUnit(_spell.desperate_prayer,"player")  
                                --elseif RemainingCooldown(_spell.dispersion) < 0.5       and player_health_perc < 0.4 then _global.SetSpellUnit(_spell.dispersion,"player")  
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
                                _spell.vampiric_embrace,_unitids.player
                                    ,RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent 
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                    }
                                ) then --print("Vampiric Embrace")

                                elseif CastSpellUnits(
                                    _spell.dispersion,_unitids.player
                                        ,RemainingCooldown(_spell.dispersion) < 0.5 and combat and player_health_perc < 0.425 and have_dispersion_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                        }
                                    ) then --print("Dispersion")
 


                                    elseif CastSpellUnits(
                                    _spell.flash_heal
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_HealthBelow80
                                            ,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Shadow Mend")
                                            
                                            
                                    elseif CastSpellUnits(
                                        _spell.shield
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                --,SpellUnit_WeakenedSoulExpired
                                            }
                                        ) then print("Power Word: Shield 11744")
        
                                            
                                        -- elseif CastSpellUnits(
                                        --     _spell.angelic_feather
                                        --         ,_unitids.player
                                        --         ,RemainingCooldown(_spell.angelic_feather) < 0.5 and not stationary and have_angelic_feather_talent and angelic_feather_check()
                                        --         ,{
                                        --             SpellUnit_MyBuffExpired
                                        --             ,SpellUnit_SpeedBuffExpired
                                        --         }
                                        --         ) then --print("Angelic Feather")
    
                                                
                                        -- elseif CastSpellUnits(
                                        --     _spell.shield
                                        --         ,_unitids.player
                                        --         ,RemainingCooldown(_spell.shield) < 0.5 and not combat and have_body_and_soul_talent and not stationary
                                        --         ,{
                                        --             SpellUnit_AliveAndFriendly
                                        --             ,SpellUnit_SpeedBuffExpired
                                        --             --,SpellUnit_ExpiringOrExpired
                                        --             --,SpellUnit_WeakenedSoulExpired
                                        --         }
                                        --     ) then --print("Power Word: Shield Sprint")            
            
        

                                else _global.Off()
                                end            
        
                        elseif attack_healer then spam_string = spam_string .. "attack_"     --print(spam_string)
                        else spam_string = spam_string .. "wtf?"                             --print(spam_string)
                        end
                    elseif dps_on then
                        spam_string = spam_string .. "dps_"                                  --print(spam_string)
                        if 1 == 0 then

                                               
                        elseif CastSpellUnits(
                            _spell.vampiric_embrace,_unitids.player
                                ,RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent 
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_ExpiringOrExpired
                                }
                            ) then --print("Vampiric Embrace")

                            elseif CastSpellUnits(
                                _spell.dispersion,_unitids.player
                                    ,RemainingCooldown(_spell.dispersion) < 0.5 and combat and player_health_perc < 0.425 and have_dispersion_talent
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Dispersion")


                        elseif CastSpellUnits(
                            _spell.void_bolt
                                ,_unitids.target
                                ,RemainingCooldown(_spell.void_bolt) < 0.5 and _unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dissonant Echoes"].remaining > 0
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                    ,SpellUnit_ValidHarm
                                }
                                ) then --print("Void Bolt")



                                elseif CastSpellUnits(
                                    _spell.void_eruption
                                        ,_unitids.target
                                        ,RemainingCooldown(_spell.void_eruption) < 0.5 and stationary and have_void_eruption_talent and combat and time_in_combat > 10
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Void Eruption")
        

                                        elseif CastSpellUnits(
                                            _spell.dark_ascension
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.dark_ascension) < 0.5 and combat and stationary and have_dark_ascension_talent and time_in_combat > 10
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                                ) then --print("Dark Ascension")   
                
                

                                        elseif CastSpellUnits(
                                            _spell.shadow_word_death
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and player_health_perc > 0.40 and _unit.player.buff["Deathspeaker"].remaining > 0
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                    }
                                                ) then --print("Shadow Word: Death Proc")
                        
                        
                                    elseif CastSpellUnits(
                                    _spell.shadow_word_death
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.40
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                            }
                                        ) then --print("Shadow Word: Death")
        
          

                                    
                                        elseif CastSpellUnits(
                                            _spell.devouring_plague
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.devouring_plague) < 0.5 and _unit.player.buff["Mind Devourer"].remaining > 0
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Devouring Plague")   
                                                    
            
            
                                        elseif CastSpellUnits(
                                        _spell.devouring_plague
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.devouring_plague) < 0.5 and not (_unit.player.buff["Mind Devourer"].remaining > 0) and ((not have_minds_eye_talent and not have_distorted_reality_talent and (insanity > 50)) or (have_minds_eye_talent and (insanity > 45)) or (have_distorted_reality_talent and (insanity > 55)))
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Devouring Plague")   
                    


                            -- elseif CastSpellUnits(
                            -- _spell.damnation
                            --     ,_unitids.raid_hostile
                            --     ,RemainingCooldown(_spell.damnation) < 0.5 and have_damnation_talent and combat
                            --         ,{
                            --             SpellUnit_UnitAliveAndHostile
                            --             ,Botchuloz_VT_or_SWP_Missing
                            --             ,SpellUnit_RangeCheck
                            --             ,SpellUnit_ValidHarm
                            --         }
                            --     ) then --print("Damnation")




                            elseif CastSpellUnits(
                            _spell.vampiric_touch
                                ,_unitids.raid_hostile
                                ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and have_misery_talent and not RecentCasting(_spell.vampiric_touch,0.095)
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,Botchuloz_VT_or_SWP_Missing
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    ,SpellUnit_NoRecasting
                                }
                                ) then --print("Vampiric Touch Misery")
                        
        
        
                            elseif CastSpellUnits(
                            _spell.vampiric_touch
                                ,_unitids.raid_hostile
                                ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and not have_misery_talent
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_MyDebuffExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    ,SpellUnit_NoRecasting
                                }
                                ) then --print("Vampiric Touch")   

                            elseif CastSpellUnits(
                            _spell.shadow_word_pain
                                ,_unitids.raid_hostile
                                ,RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_misery_talent or (have_misery_talent and not stationary and combat)
                                ,{
                                SpellUnit_UnitAliveAndHostile
                                ,SpellUnit_MyDebuffExpired
                                ,SpellUnit_RangeCheck
                                ,SpellUnit_ValidHarm
                                }
                                ) then --print("Shadow Word: Pain")   

                            elseif CastSpellUnits(
                            _spell.vampiric_touch
                                ,_unitids.raid_hostile
                                ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and _unit.player.buff["Unfurling Darkness"].remaining_or_high < 5
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                    --,SpellUnit_MyDebuffExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    ,SpellUnit_NoRecasting
                                }
                                ) then --print("Vampiric Touch Unfurling Darkness")   
        
                            elseif CastSpellUnits(
                                _spell.mindblast
                                    ,_unitids.target
                                    ,RemainingCooldown(_spell.mindblast) < 0.5 and _unit.player.buff["Shadowy Insights"].remaining > 0
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Mind Blast Instant")

    
                                    elseif CastSpellUnits(
                                        _spell.mindgames
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.mindgames) < 0.5 and have_mindgames_talent and stationary and combat
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                ,SpellUnit_ValidHarm 
                                            }
                                            ) then --print("Mindgames")
                            
                            

                            elseif CastSpellUnits(
                            _spell.void_torrent
                                ,_unitids.target
                                ,RemainingCooldown(_spell.void_torrent) < 0.5 and (stationary or have_dark_energy_talent) and have_void_torrent_talent
                                ,{
                                SpellUnit_UnitAliveAndHostile
                                ,SpellUnit_Debuff_ExpiringNextGCDOrExpired
                                ,SpellUnit_RangeCheck
                                ,SpellUnit_ValidHarm
                                }
                                ) then --print("Void Torrent")

                            elseif CastSpellUnits(
                            _spell.mindblast
                                ,_unitids.target
                                ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                }
                                ) then --print("Mind Blast")

                                elseif CastSpellUnits(
                                    _spell.power_infusion
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.power_infusion) < 0.5 and combat and (_unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dark Ascension"].remaining > 0) and (not in_group or not have_twins_of_the_sun_priestess_talent)
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                        }
                                        ) then --print("Power Infusion Player")   
        

                                elseif CastSpellUnits(
                                    _spell.power_infusion
                                        ,_unitids.standard_friendly
                                        ,RemainingCooldown(_spell.power_infusion) < 0.5 and combat and (_unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dark Ascension"].remaining > 0) and in_group and have_twins_of_the_sun_priestess_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,Botchuloz_SpellUnit_Help_Power_Infusion_Rank
                                        }
                                        ) then --print("Power Infusion Friendly")   
        


                                        elseif CastSpellUnits(
                                            _spell.shadowfiend,_unitids.target
                                                ,((RemainingCooldown(_spell.voidwraith ) < 0.5 and have_voidwraith_talent) or 
                                                  (RemainingCooldown(_spell.mindbender ) < 0.5 and not have_voidwraith_talent and have_mindbender_shadow_talent) or 
                                                  (RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_voidwraith_talent and not have_mindbender_shadow_talent)) and 
                                                  insanity <30 and time_in_combat >= 10 
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Shadowfiend")
                

                            -- elseif CastSpellUnits(
                            -- _spell.shadowfiend
                            --     ,_unitids.target
                            --     ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_shadow_talent and insanity <30 and combat
                            --     ,{
                            --         SpellUnit_UnitAliveAndHostile
                            --         ,SpellUnit_RangeCheck
                            --         ,SpellUnit_ValidHarm
                            --     }
                            --     ) then --print("Shadowfiend")

                            -- elseif CastSpellUnits(
                            -- _spell.mindbender
                            --     ,_unitids.target
                            --     ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_shadow_talent and insanity <30 and combat
                            --     ,{
                            --         SpellUnit_UnitAliveAndHostile
                            --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                            --         ,SpellUnit_ValidHarm
                            --     }
                            --     ) then --print("Mindbender")
                            
        
                            elseif CastSpellUnits(
                            _spell.vampiric_touch
                                ,_unitids.raid_hostile
                                ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and have_misery_talent
                                ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,Botchuloz_VT_or_SWP_ExpiringUnder5_ButIsntExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    ,SpellUnit_NoRecasting
                                }
                                ) then --print("Vampiric Touch Misery Refresh")
    
                            -- elseif CastSpellUnits(
                            -- _spell.damnation
                            --     ,_unitids.raid_hostile
                            --     ,RemainingCooldown(_spell.damnation) < 0.5 and have_damnation_talent and combat
                            --         ,{
                            --             SpellUnit_UnitAliveAndHostile
                            --             ,Botchuloz_VT_or_SWP_ExpiringUnder5_ButIsntExpired
                            --             ,SpellUnit_RangeCheck
                            --             ,SpellUnit_ValidHarm
                            --         }
                            --     ) then --print("Damnation refresh") 

                            elseif CastSpellUnits(
                            _spell.shadow_word_pain
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_misery_talent or (have_misery_talent and not stationary and combat)
                                    ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("shadow word: pain refresh")   
                            
                            --mindflay was here
                                    

                            -- elseif RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent
                            --         then _global.SetSpellUnit(_spell.vampiric_embrace,"player")  
    
                            -- elseif RemainingCooldown(
                            --     _spell.desperate_prayer) < 0.5 and player_health_perc < 0.6
                            --             then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                            -- elseif RemainingCooldown(
                            --     _spell.dispersion) < 0.5 and player_health_perc < 0.4
                            --             then _global.SetSpellUnit(_spell.dispersion,"player")  


                            --PvP Addons-- mindflay moved to the end

                        -- elseif CastSpellUnits(
                        --     _spell.mind_bomb
                        --             ,_unitids.standard_hostile
                        --             ,RemainingCooldown(_spell.mind_bomb) < 0.5 and player_health_perc < 0.6 and have_mind_bomb_talent and combat
                        --             ,{
                        --             SpellUnit_UnitAliveAndHostile
                        --             ,Botchuloz_RangeCheckHarm_30Yard
                        --             ,SpellUnit_ValidHarm
                        --             }
                        --             ) then --print("Mind Bomb")   
                        
                                            
                    elseif CastSpellUnits(
                        _spell.shield
                            ,_unitids.player
                            ,RemainingCooldown(_spell.shield) < 0.5 and combat
                            ,{
                                SpellUnit_AliveAndFriendly
                                ,SpellUnit_ExpiringOrExpired
                                --,SpellUnit_WeakenedSoulExpired
                            }
                        ) then print("Power Word: Shield 12139")

                            



                            elseif CastSpellUnits(
                            _spell.psyfiend
                                    ,_unitids.target
                                    ,RemainingCooldown(_spell.psyfiend) < 0.5
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Psyfiend")

                            -- elseif CastSpellUnits(
                            -- _spell.madness
                            --         ,_unitids.target
                            --         ,RemainingCooldown(_spell.madness) < 0.5
                            --         ,{
                            --             SpellUnit_UnitAliveAndHostile
                            --             ,SpellUnit_RangeCheck
                            --             ,SpellUnit_ValidHarm
                            --         }
                            --         ) then --print("Surrender to madness")




                        elseif CastSpellUnits(
                            _spell.halo
                                ,_unitids.player
                                ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_shadow_talent and combat and stationary
                                ,{
                                    SpellUnit_AliveAndFriendly
                                }
                            ) then --print("Halo")
    
    
                            elseif CastSpellUnits(
                                _spell.divine_star
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_shadow_talent and combat
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Divine Star")
    


                            elseif CastSpellUnits(
                                _spell.flash_heal
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_HealthBelow70
                                        --,SpellUnit_RangeCheck
                                    }
                                ) then --print("Shadow Mend")

            
                            elseif CastSpellUnits(
                                _spell.mind_flay
                                    ,_unitids.target
                                    ,RemainingCooldown(_spell.mind_flay) < 0.5 and stationary
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_Debuff_ExpiringNextGCDOrExpired
                                    ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Mind Flay")
            


                               
                                                    elseif CastSpellUnits(
                                                        _spell.holy_nova
                                                            ,_unitids.player
                                                            ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                                            ,{
                                                                SpellUnit_AliveAndFriendly
                                                            }
                                                        ) then --print("Halo")
                                
                            
                        
                            
                


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
                                        _spell.vampiric_embrace,_unitids.player
                                            ,RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent 
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                            }
                                        ) then --print("Vampiric Embrace")
        
                                        elseif CastSpellUnits(
                                            _spell.dispersion,_unitids.player
                                                ,RemainingCooldown(_spell.dispersion) < 0.5 and combat and player_health_perc < 0.425 and have_dispersion_talent
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                }
                                            ) then --print("Dispersion")
         
        

                                    elseif CastSpellUnits(
                                    _spell.flash_heal
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                            ,SpellUnit_HealthBelow80
                                            --,SpellUnit_RangeCheck
                                        }
                                    ) then --print("Shadow Mend")
                                            
                                    elseif CastSpellUnits(
                                        _spell.shield
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,SpellUnit_ExpiringOrExpired
                                                --,SpellUnit_WeakenedSoulExpired
                                            }
                                        ) then print("Power Word: Shield 12292")
        
                                            
                                        -- elseif CastSpellUnits(
                                        --     _spell.angelic_feather
                                        --         ,_unitids.player
                                        --         ,RemainingCooldown(_spell.angelic_feather) < 0.5 and not stationary and have_angelic_feather_talent and angelic_feather_check()
                                        --         ,{
                                        --             SpellUnit_MyBuffExpired
                                        --             ,SpellUnit_SpeedBuffExpired
                                        --         }
                                        --         ) then --print("Angelic Feather")
    
                                                
                                        -- elseif CastSpellUnits(
                                        --     _spell.shield
                                        --         ,_unitids.player
                                        --         ,RemainingCooldown(_spell.shield) < 0.5 and not combat and have_body_and_soul_talent and not stationary
                                        --         ,{
                                        --             SpellUnit_AliveAndFriendly
                                        --             ,SpellUnit_SpeedBuffExpired
                                        --             --,SpellUnit_ExpiringOrExpired
                                        --             --,SpellUnit_WeakenedSoulExpired
                                        --         }
                                        --     ) then --print("Power Word: Shield Sprint")
            
            

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
                                _spell.shadow_word_pain
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.shadow_word_pain) < 0.5
                                    ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_MyDebuffExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Shadow Word: Pain")   

                                

                            elseif CastSpellUnits(
                                _spell.vampiric_embrace,_unitids.player
                                    ,RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent 
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                        ,SpellUnit_ExpiringOrExpired
                                    }
                                ) then --print("Vampiric Embrace")

                                elseif CastSpellUnits(
                                    _spell.dispersion,_unitids.player
                                        ,RemainingCooldown(_spell.dispersion) < 0.5 and combat and player_health_perc < 0.425 and have_dispersion_talent
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                        }
                                    ) then --print("Dispersion")
 

                            elseif CastSpellUnits(
                                _spell.void_bolt
                                    ,_unitids.target
                                    ,RemainingCooldown(_spell.void_bolt) < 0.5 and _unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dissonant Echoes"].remaining > 0
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                        ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Void Bolt")
    
    
    
                                    elseif CastSpellUnits(
                                        _spell.void_eruption
                                            ,_unitids.target
                                            ,RemainingCooldown(_spell.void_eruption) < 0.5 and stationary and have_void_eruption_talent and combat and time_in_combat > 10
                                            ,{
                                                SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                                ,SpellUnit_ValidHarm
                                            }
                                            ) then --print("Void Eruption")
                

                                            elseif CastSpellUnits(
                                                _spell.dark_ascension
                                                    ,_unitids.player
                                                    ,RemainingCooldown(_spell.dark_ascension) < 0.5 and combat and stationary and have_dark_ascension_talent and time_in_combat > 10
                                                    ,{
                                                        SpellUnit_AliveAndFriendly
                                                    }
                                                    ) then --print("Dark Ascension")   
                    
                    

                                            elseif CastSpellUnits(
                                                _spell.shadow_word_death
                                                        ,_unitids.target
                                                        ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and player_health_perc > 0.40 and _unit.player.buff["Deathspeaker"].remaining > 0
                                                        ,{
                                                            SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                        }
                                                    ) then --print("Shadow Word: Death Proc")
                            
                            
                                        elseif CastSpellUnits(
                                        _spell.shadow_word_death
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.shadow_word_death) < 0.5 and _unit.target.health.percent < 0.2 and player_health_perc > 0.40
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                ,SpellUnit_RangeCheck
                                                ,SpellUnit_ValidHarm
                                                }
                                            ) then --print("Shadow Word: Death")
            
              

                                            elseif CastSpellUnits(
                                                _spell.devouring_plague
                                                    ,_unitids.target
                                                    ,RemainingCooldown(_spell.devouring_plague) < 0.5 and _unit.player.buff["Mind Devourer"].remaining > 0
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Devouring Plague")   
                                                        
                
                
                                            elseif CastSpellUnits(
                                            _spell.devouring_plague
                                                ,_unitids.target
                                                ,RemainingCooldown(_spell.devouring_plague) < 0.5 and not (_unit.player.buff["Mind Devourer"].remaining > 0) and ((not have_minds_eye_talent and not have_distorted_reality_talent and (insanity > 50)) or (have_minds_eye_talent and (insanity > 45)) or (have_distorted_reality_talent and (insanity > 55)))
                                                ,{
                                                    SpellUnit_UnitAliveAndHostile
                                                    ,SpellUnit_RangeCheck
                                                    ,SpellUnit_ValidHarm
                                                }
                                                ) then --print("Devouring Plague")   
                            

                                -- elseif CastSpellUnits(
                                -- _spell.damnation
                                --     ,_unitids.raid_hostile
                                --     ,RemainingCooldown(_spell.damnation) < 0.5 and have_damnation_talent and combat
                                --         ,{
                                --             SpellUnit_UnitAliveAndHostile
                                --             ,Botchuloz_VT_or_SWP_Missing
                                --             ,SpellUnit_RangeCheck
                                --             ,SpellUnit_ValidHarm
                                --         }
                                --     ) then --print("Damnation")




                                elseif CastSpellUnits(
                                _spell.vampiric_touch
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and have_misery_talent and not RecentCasting(_spell.vampiric_touch,0.095)
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,Botchuloz_VT_or_SWP_Missing
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        ,SpellUnit_NoRecasting
                                    }
                                    ) then --print("Vampiric Touch Misery")



                                elseif CastSpellUnits(
                                _spell.vampiric_touch
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and not have_misery_talent
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_MyDebuffExpired
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        ,SpellUnit_NoRecasting
                                    }
                                    ) then --print("Vampiric Touch")   

                                elseif CastSpellUnits(
                                _spell.shadow_word_pain
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_misery_talent or (have_misery_talent and not stationary and combat)
                                    ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_MyDebuffExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Shadow Word: Pain")   

                                elseif CastSpellUnits(
                                _spell.vampiric_touch
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and _unit.player.buff["Unfurling Darkness"].remaining_or_high < 5
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        --,SpellUnit_MyDebuffExpired
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        ,SpellUnit_NoRecasting
                                    }
                                    ) then --print("Vampiric Touch Unfurling Darkness")   


                                elseif CastSpellUnits(
                                _spell.void_torrent
                                    ,_unitids.target
                                    ,RemainingCooldown(_spell.void_torrent) < 0.5 and (stationary or have_dark_energy_talent) and have_void_torrent_talent
                                    ,{
                                    SpellUnit_UnitAliveAndHostile
                                    ,SpellUnit_Debuff_ExpiringNextGCDOrExpired
                                    ,SpellUnit_RangeCheck
                                    ,SpellUnit_ValidHarm
                                    }
                                    ) then --print("Void Torrent")

                                    elseif CastSpellUnits(
                                        _spell.power_infusion
                                            ,_unitids.player
                                            ,RemainingCooldown(_spell.power_infusion) < 0.5 and combat and (_unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dark Ascension"].remaining > 0) and (not in_group or not have_twins_of_the_sun_priestess_talent)
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                            }
                                            ) then --print("Power Infusion Player")   
            
    
                                    elseif CastSpellUnits(
                                        _spell.power_infusion
                                            ,_unitids.standard_friendly
                                            ,RemainingCooldown(_spell.power_infusion) < 0.5 and combat and (_unit.player.buff["Voidform"].remaining > 0 or _unit.player.buff["Dark Ascension"].remaining > 0) and in_group and have_twins_of_the_sun_priestess_talent
                                            ,{
                                                SpellUnit_AliveAndFriendly
                                                ,Botchuloz_SpellUnit_Help_Power_Infusion_Rank
                                            }
                                            ) then --print("Power Infusion Friendly")   
            
    


                                            elseif CastSpellUnits(
                                                _spell.shadowfiend,_unitids.target
                                                    ,((RemainingCooldown(_spell.voidwraith ) < 0.5 and have_voidwraith_talent) or 
                                                      (RemainingCooldown(_spell.mindbender ) < 0.5 and not have_voidwraith_talent and have_mindbender_shadow_talent) or 
                                                      (RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_voidwraith_talent and not have_mindbender_shadow_talent)) and 
                                                      insanity <30 and time_in_combat >= 10 
                                                    ,{
                                                        SpellUnit_UnitAliveAndHostile
                                                        ,SpellUnit_RangeCheck
                                                        ,SpellUnit_ValidHarm
                                                    }
                                                    ) then --print("Shadowfiend")
                    
    
                                -- elseif CastSpellUnits(
                                -- _spell.shadowfiend
                                --     ,_unitids.target
                                --     ,RemainingCooldown(_spell.shadowfiend) < 0.5 and not have_mindbender_shadow_talent and insanity <30 and combat
                                --     ,{
                                --         SpellUnit_UnitAliveAndHostile
                                --         ,SpellUnit_RangeCheck
                                --         ,SpellUnit_ValidHarm
                                --     }
                                --     ) then --print("Shadowfiend")
    
                                -- elseif CastSpellUnits(
                                -- _spell.mindbender
                                --     ,_unitids.target
                                --     ,RemainingCooldown(_spell.mindbender) < 0.5 and have_mindbender_shadow_talent and insanity <30 and combat
                                --     ,{
                                --         SpellUnit_UnitAliveAndHostile
                                --         ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                --         ,SpellUnit_ValidHarm
                                --     }
                                --     ) then --print("Mindbender")
                                    

                                elseif CastSpellUnits(
                                _spell.vampiric_touch
                                    ,_unitids.raid_hostile
                                    ,RemainingCooldown(_spell.vampiric_touch) < 0.5 and stationary and have_misery_talent
                                    ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,Botchuloz_VT_or_SWP_ExpiringUnder5_ButIsntExpired
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        ,SpellUnit_NoRecasting
                                    }
                                    ) then --print("Vampiric Touch Misery Refresh")

                                -- elseif CastSpellUnits(
                                -- _spell.damnation
                                --     ,_unitids.raid_hostile
                                --     ,RemainingCooldown(_spell.damnation) < 0.5 and have_damnation_talent and combat
                                --         ,{
                                --             SpellUnit_UnitAliveAndHostile
                                --             ,Botchuloz_VT_or_SWP_ExpiringUnder5_ButIsntExpired
                                --             ,SpellUnit_RangeCheck
                                --             ,SpellUnit_ValidHarm
                                --         }
                                --     ) then --print("Damnation refresh") 

                                elseif CastSpellUnits(
                                _spell.shadow_word_pain
                                        ,_unitids.raid_hostile
                                        ,RemainingCooldown(_spell.shadow_word_pain) < 0.5 and not have_misery_talent or (have_misery_talent and not stationary and combat)
                                        ,{
                                        SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_MyDebuffExpiringUnder5_ButIsntExpired
                                        ,SpellUnit_RangeCheck
                                        ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("shadow word: pain refresh")   
                                
                                --mindflay was here
                                        

                                -- elseif RemainingCooldown(_spell.vampiric_embrace) < 0.5 and combat and player_health_perc < 0.75 and have_vampiric_embrace_talent
                                --         then _global.SetSpellUnit(_spell.vampiric_embrace,"player")  

                                -- elseif RemainingCooldown(
                                --     _spell.desperate_prayer) < 0.5 and player_health_perc < 0.6
                                --             then _global.SetSpellUnit(_spell.desperate_prayer,"player")  

                                -- elseif RemainingCooldown(
                                --     _spell.dispersion) < 0.5 and player_health_perc < 0.4
                                --             then _global.SetSpellUnit(_spell.dispersion,"player")  


                                --PvP Addons-- mindflay moved to the end

                            -- elseif CastSpellUnits(
                            --     _spell.mind_bomb
                            --             ,_unitids.standard_hostile
                            --             ,RemainingCooldown(_spell.mind_bomb) < 0.5 and player_health_perc < 0.6 and have_mind_bomb_talent and combat
                            --             ,{
                            --             SpellUnit_UnitAliveAndHostile
                            --             ,Botchuloz_RangeCheckHarm_30Yard
                            --             ,SpellUnit_ValidHarm
                            --             }
                            --             ) then --print("Mind Bomb")   
                            

                                            
                        elseif CastSpellUnits(
                            _spell.shield
                                ,_unitids.player
                                ,RemainingCooldown(_spell.shield) < 0.5 and combat
                                ,{
                                    SpellUnit_AliveAndFriendly
                                    ,SpellUnit_ExpiringOrExpired
                                    --,SpellUnit_WeakenedSoulExpired
                                }
                            ) then print("Power Word: Shield line 12674")

                                
                            -- elseif CastSpellUnits(
                            --     _spell.angelic_feather
                            --         ,_unitids.player
                            --         ,RemainingCooldown(_spell.angelic_feather) < 0.5 and not stationary and have_angelic_feather_talent and angelic_feather_check()
                            --         ,{
                            --             SpellUnit_MyBuffExpired
                            --             ,SpellUnit_SpeedBuffExpired
                            --         }
                            --         ) then --print("Angelic Feather")

                                    
                            -- elseif CastSpellUnits(
                            --     _spell.shield
                            --         ,_unitids.player
                            --         ,RemainingCooldown(_spell.shield) < 0.5 and not combat and have_body_and_soul_talent and not stationary
                            --         ,{
                            --             SpellUnit_AliveAndFriendly
                            --             ,SpellUnit_SpeedBuffExpired
                            --             --,SpellUnit_ExpiringOrExpired
                            --             --,SpellUnit_WeakenedSoulExpired
                            --         }
                            --     ) then --print("Power Word: Shield Sprint")

                                elseif CastSpellUnits(
                                _spell.psyfiend
                                        ,_unitids.target
                                        ,RemainingCooldown(_spell.psyfiend) < 0.5 and have_psyfiend_talent and combat
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                            ,SpellUnit_RangeCheck
                                            ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Psyfiend")

                                -- elseif CastSpellUnits(
                                -- _spell.madness
                                --         ,_unitids.target
                                --         ,RemainingCooldown(_spell.madness) < 0.5
                                --         ,{
                                --             SpellUnit_UnitAliveAndHostile
                                --             ,SpellUnit_RangeCheck
                                --             ,SpellUnit_ValidHarm
                                --         }
                                --         ) then --print("Surrender to madness")




                            elseif CastSpellUnits(
                                _spell.halo
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.halo) < 0.5 and have_halo_shadow_talent and combat and stationary
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Halo")
        
        
                                elseif CastSpellUnits(
                                    _spell.divine_star
                                        ,_unitids.player
                                        ,RemainingCooldown(_spell.divine_star) < 0.5 and have_divine_star_shadow_talent and combat
                                        ,{
                                            SpellUnit_AliveAndFriendly
                                        }
                                    ) then --print("Divine Star")
        



                                        elseif CastSpellUnits(
                                            _spell.flash_heal
                                                ,_unitids.player
                                                ,RemainingCooldown(_spell.flash_heal) < 0.5 and stationary
                                                ,{
                                                    SpellUnit_AliveAndFriendly
                                                    ,SpellUnit_HealthBelow70
                                                    --,SpellUnit_RangeCheck
                                                }
                                            ) then --print("Shadow Mend")
    

                                                
                                --shared speed spells START
                            -- elseif CastSpellUnits(
                            --     _spell.angelic_feather
                            --         ,_unitids.player
                            --         ,RemainingCooldown(_spell.angelic_feather) < 0.5 and not stationary and have_angelic_feather_talent and angelic_feather_check()
                            --         ,{
                            --             SpellUnit_MyBuffExpired
                            --             ,SpellUnit_SpeedBuffExpired
                            --         }
                            --         ) then --print("Angelic Feather")

                                        
                                -- elseif CastSpellUnits(
                                --     _spell.shield
                                --         ,_unitids.player
                                --         ,RemainingCooldown(_spell.shield) < 0.5 and not combat and have_body_and_soul_talent and not stationary
                                --         ,{
                                --             SpellUnit_AliveAndFriendly
                                --             ,SpellUnit_SpeedBuffExpired
                                --             --,SpellUnit_ExpiringOrExpired
                                --             --,SpellUnit_WeakenedSoulExpired
                                --         }
                                --     ) then --print("Power Word: Shield Sprint")


                       
                            elseif CastSpellUnits(
                                _spell.holy_nova
                                    ,_unitids.player
                                    ,RemainingCooldown(_spell.holy_nova) < 0.5 and combat and have_holy_nova_talent and Botchuloz_Circle_of_Healing_Detail(400,2) and _unit.player.buff["Rhapsody"].stacks == 20
                                    ,{
                                        SpellUnit_AliveAndFriendly
                                    }
                                ) then --print("Halo")
        
    

                                                
                                elseif CastSpellUnits(
                                    _spell.mind_flay
                                        ,_unitids.target
                                        ,RemainingCooldown(_spell.mind_flay) < 0.5 and stationary
                                        ,{
                                            SpellUnit_UnitAliveAndHostile
                                        ,SpellUnit_Debuff_ExpiringNextGCDOrExpired
                                        ,SpellUnit_RangeCheck--Botchuloz_RangeCheckHarm_40Yard
                                        ,SpellUnit_ValidHarm
                                        }
                                        ) then --print("Mind Sear")


                        
                            
                                


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
_priest.spell = _spell
delphi.class.Priest = _priest

 --print("Class_Priest.lua")




-- print("START Lee's talent code")

-- for i=1,3 do
--     for j=1,7 do
--         local talentID, talentName, , , , spellId, , ,, haveTalent, haveFakeTalent = GetTalentInfo(j, i,1)

-- print("END Lee's talent code")
