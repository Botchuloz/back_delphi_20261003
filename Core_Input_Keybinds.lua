--[[
▀█████████▄        ▄█       ███▄▄▄▄        ████████▄          ▄████████ 
  ███    ███      ███       ███▀▀▀██▄      ███   ▀███        ███    ███ 
  ███    ███      ███▌      ███   ███      ███    ███        ███    █▀  
 ▄███▄▄▄██▀       ███▌      ███   ███      ███    ███        ███        
▀▀███▀▀▀██▄       ███▌      ███   ███      ███    ███      ▀███████████ 
  ███    ██▄      ███       ███   ███      ███    ███               ███ 
  ███    ███      ███       ███   ███      ███   ▄███         ▄█    ███ 
▄█████████▀       █▀         ▀█   █▀       ████████▀        ▄████████▀  
                                                                        
--]]

--raw keybinds available to godly
local _bindable_keys   = delphi.keyboard.key_ascii
local _bindable_mods   = delphi.keyboard.mod_ascii

--merged keybinds that we can actually use (eg, 'shift-a', rather than 'a')
local _combo_status    = delphi.keycombo.status
local _combo_key_ascii = delphi.keycombo.key_ascii
local _combo_mod_ascii = delphi.keycombo.mod_ascii

local _spellunit_to_combo_map = delphi.bind.spellunit_to_keycombo
local _button                 = delphi.bind.button

-- FUNCTION KEYS
_bindable_keys["F1"]=112
_bindable_keys["F2"]=113
_bindable_keys["F3"]=114
--[[,{"F4"]=115}]]
--_bindable_keys["F5"]=116
_bindable_keys["F6"]=117
_bindable_keys["F7"]=118
_bindable_keys["F8"]=119
_bindable_keys["F9"]=120
_bindable_keys["F10"]=121
_bindable_keys["F11"]=122
_bindable_keys["F12"]=123

-- NUMBERS
_bindable_keys["0"]=48
_bindable_keys["1"]=49
_bindable_keys["2"]=50
_bindable_keys["3"]=51
_bindable_keys["4"]=52
_bindable_keys["5"]=53
_bindable_keys["6"]=54
_bindable_keys["7"]=55
_bindable_keys["8"]=56
_bindable_keys["9"]=57

-- LETTERS
_bindable_keys["A"]=65
_bindable_keys["B"]=66
_bindable_keys["C"]=67
_bindable_keys["D"]=68
_bindable_keys["E"]=69
_bindable_keys["F"]=70
_bindable_keys["G"]=71
_bindable_keys["H"]=72
_bindable_keys["I"]=73
_bindable_keys["J"]=74
_bindable_keys["K"]=75
_bindable_keys["L"]=76
_bindable_keys["M"]=77
_bindable_keys["N"]=78
_bindable_keys["O"]=79
_bindable_keys["P"]=80
_bindable_keys["Q"]=81
_bindable_keys["R"]=82
_bindable_keys["S"]=83
_bindable_keys["T"]=84
_bindable_keys["U"]=85
_bindable_keys["V"]=86
_bindable_keys["W"]=87
_bindable_keys["X"]=88
_bindable_keys["Y"]=89
_bindable_keys["Z"]=90

-- SYMBOLS
_bindable_keys["`"]=192
_bindable_keys["["]=219
_bindable_keys["]"]=221
--_bindable_keys["'"]=222
--_bindable_keys[","]=188
--_bindable_keys["."]=190
_bindable_keys["/"]=191
_bindable_keys["="]=187
--_bindable_keys["\\"]=220
_bindable_keys["-"]=189
_bindable_keys[";"]=186

-- NAVIGATION KEYS (INCLUDING ARROW KEYS)
_bindable_keys["INSERT"]=45
_bindable_keys["DELETE"]=46
_bindable_keys["HOME"]=36
_bindable_keys["END"]=35
_bindable_keys["PAGEUP"]=33
_bindable_keys["PAGEDOWN"]=34
_bindable_keys["UP"]=38        -- Arrow Up
_bindable_keys["DOWN"]=40      -- Arrow Down
_bindable_keys["LEFT"]=37      -- Arrow Left
_bindable_keys["RIGHT"]=39     -- Arrow Right

-- MOUSE BUTTONS (RESTORED FOR TESTING)
-- Note: BUTTON3 (middle mouse) excluded due to ASCII conflict with value 4
-- _bindable_keys["BUTTON4"]=5   -- Mouse button 4 (back)
-- _bindable_keys["BUTTON5"]=6   -- Mouse button 5 (forward)

-- SPECIAL KEYS
_bindable_keys["TAB"]=9
_bindable_keys["SPACE"]=32
--_bindable_keys["ENTER"]=13
--_bindable_keys["ESCAPE"]=27   -- COMMENTED OUT

--these are done "array[int]=string" to avoid sorting issues when we generate the mod-strings later on. String arrays aren't stable, int arrays are.
 --[[VKEY values: {"LCTRL"]=162,_bindable_keys["RCTRL"]=163,_bindable_keys["LSHIFT"]=160,_bindable_keys["RSHIFT"]=161,_bindable_keys["LALT"]=164,_bindable_keys["RALT"]=165}]]

-- there were some issues with alt vk_ralt and vk_lalt, so I just disabled left/right binds completely and disabled alt.
--_bindable_mods["ALT-"] = 1 
--_bindable_mods[""] = 0

-- _bindable_mods["CTRL-"] = 4
-- _bindable_mods["SHIFT-"] = 16
-- _bindable_mods["CTRL-SHIFT-"] = 20

-----PROBLEMATIC
-- _bindable_mods["LALT-"] = 1
-- _bindable_mods["RALT-"] = 2

----STANDARD
-- _bindable_mods["LCTRL-"] = 4
-- _bindable_mods["RCTRL-"] = 8
-- _bindable_mods["LSHIFT-"] = 16
-- _bindable_mods["RSHIFT-"] = 32

---EXPLORATORY [MANDATORY ORDER : ALT-CTRL-SHIFT] -- note, we don't support L + R alts because fuck me.

-- _bindable_mods["ALT-RSHIFT-"]=33
-- _bindable_mods["ALT-LSHIFT-"]=17
-- _bindable_mods["ALT-RCTRL-"]=9
-- _bindable_mods["ALT-RCTRL-RSHIFT-"]=41
-- _bindable_mods["ALT-RCTRL-LSHIFT-"]=25
-- _bindable_mods["ALT-LCTRL-"]=5
-- _bindable_mods["ALT-LCTRL-RSHIFT-"]=37
-- _bindable_mods["ALT-LCTRL-LSHIFT-"]=21

-- ADD EMPTY MODIFIER FOR BARE KEYS
_bindable_mods[""] = 0                    -- Empty modifier for bare keys
_bindable_mods["ALT-"] = 1 
_bindable_mods["RSHIFT-"]=32
_bindable_mods["LSHIFT-"]=16
_bindable_mods["RCTRL-"]=8
_bindable_mods["RCTRL-RSHIFT-"]=40
_bindable_mods["RCTRL-LSHIFT-"]=24
_bindable_mods["LCTRL-"]=4
_bindable_mods["LCTRL-RSHIFT-"]=36
_bindable_mods["LCTRL-LSHIFT-"]=20

-- Generate all combinations
for keyname,keyascii in pairs (_bindable_keys) do
    for modname,modascii in pairs(_bindable_mods) do
        --print(modname,keyname)
        _combo_status[modname..keyname] = false
        _combo_key_ascii[modname..keyname] = keyascii
        _combo_mod_ascii[modname..keyname] = modascii
    end   
end

-- POST-GENERATION FILTERING
-- Define keys that should NOT be used as bare keys (without modifiers)
local bare_key_blacklist = {
    -- Movement and action bar keys
    ["W"] = true,        -- Movement
    ["A"] = true,        -- Movement
    ["S"] = true,        -- Movement
    ["D"] = true,        -- Movement
    ["1"] = true,        -- Action bar
    ["2"] = true,        -- Action bar
    ["3"] = true,        -- Action bar
    ["4"] = true,        -- Action bar
    
    -- Symbol keys
    ["="] = true,        -- Don't allow bare "=" key
    ["`"] = true,        -- Don't allow bare "`" key  
    ["["] = true,        -- Don't allow bare "[" key
    ["]"] = true,        -- Don't allow bare "]" key
    ["/"] = true,        -- Don't allow bare "/" key
    ["-"] = true,        -- Don't allow bare "-" key
    [";"] = true,        -- Don't allow bare ";" key
    ["0"] = true,        -- Don't allow bare "0" key
    
    -- Common WoW keys that should require modifiers
    ["M"] = true,        -- Map key - don't allow bare "M"
    ["I"] = true,        -- Inventory key - don't allow bare "I"
    ["N"] = true,        -- Don't allow bare "N"
    ["E"] = true,        -- Don't allow bare "E"
    ["Q"] = true,        -- Don't allow bare "Q" 
    ["B"] = true,        -- NEWLY ADDED - don't allow bare "B"


    -- Default UI panel keys
    ["C"] = true,        -- Character pane
    ["J"] = true,        -- Guild
    ["K"] = true,        -- Talents
    ["P"] = true,        -- Spellbook & Abilities
    ["L"] = true,        -- Quest Log
    ["O"] = true,        -- Social
    ["U"] = true,        -- Reputation pane
    ["H"] = true,        -- PvP / Honor pane (Classic-era default, carried into Forever)


    -- WoW Forever-specific combat rebinds (differ from retail defaults)
    ["T"] = true,        -- ATTACKTARGET on Forever (was "Chat" on retail)
    ["F"] = true,        -- ASSISTTARGET on Forever (was "Interact with Target" on retail)
    ["G"] = true,        -- TARGETLASTHOSTILE on Forever (was "ping" on retail)


    -- Chat
    ["R"] = true,        -- Reply to last whisper

    -- Remaining alpha keys (V, W, X, Y, Z) - no confirmed default action,
    -- reserved defensively so every bare A-Z key is off-limits
    ["V"] = true,        -- Reserved, unconfirmed default
    ["X"] = true,        -- Reserved, unconfirmed default
    ["Y"] = true,        -- Achievements (legacy default) / reserved
    ["Z"] = true,        -- Reserved, unconfirmed default
    
    -- Navigation keys require modifiers (including arrow keys)
    ["INSERT"] = true,
    ["DELETE"] = true,
    ["HOME"] = true,
    ["END"] = true,
    ["PAGEUP"] = true,
    ["PAGEDOWN"] = true,
    ["UP"] = true,       -- Arrow keys require modifiers for safety
    ["DOWN"] = true,
    ["LEFT"] = true,
    ["RIGHT"] = true,
    
    -- MOUSE BUTTONS require modifiers (RESTORED FOR TESTING)
    ["BUTTON4"] = true,  -- Mouse button 4 (back) - requires modifiers
    ["BUTTON5"] = true,  -- Mouse button 5 (forward) - requires modifiers
    
    -- Special keys that should require modifiers
    ["TAB"] = true,
    ["SPACE"] = true,
    ["ENTER"] = true,
    --["ESCAPE"] = true,   -- COMMENTED OUT - ESCAPE now available as bare key
}

-- FIXED: Remove bare key combinations from blacklist (keeps modified versions like "ALT-D")
for keyname, _ in pairs(bare_key_blacklist) do
    if _combo_status[keyname] ~= nil then  -- FIXED: Check if key exists, not if it's true
        _combo_status[keyname] = nil
        _combo_key_ascii[keyname] = nil
        _combo_mod_ascii[keyname] = nil
        print("Removed bare key binding for: " .. keyname)
    end
end

function GetNextFreeBind(spellunit)
    for k,v in pairs(_combo_status) do
        if(not(v))then
            --print("Bind:",k,"allocated to "..spellunit)
            _combo_status[k] = true
            return k
        end
    end
    print("ERROR : NO FREE BINDS LEFT")
end

function FreeBindCount()
    local free_binds = 0
    for k,v in pairs(_combo_status) do
        if(not(v))then
            free_binds = free_binds + 1
        end
    end
    return free_binds
end

--[[dragonflight zero day]]
shh_binding_announcements = true
--[[/dragonflight zero day]]
function BindSpellToUnit(spell,unit,prefix,suffix,skipcontents,DelegateMacroCreation)
    spellunit = spell..unit
    if(_spellunit_to_combo_map[spellunit] ~= nil) then
        --print(spellunit.." is already bound")
    else
        nextbind = GetNextFreeBind(spellunit)
        macrotext = ""
        local macro_generation_function = DelegateMacroCreation or CreateUseMacroTextor or CreateCastMacrotext or CreateClickMacrotext
        if(skipcontents==nil)then
            macrotext = macro_generation_function(spell,unit)
        end
        macro = (prefix or "").."\n"..macrotext.."\n"..(suffix or "")

        _spellunit_to_combo_map[spellunit] = nextbind
        if not shh_binding_announcements then
            print("Creating bind for "..spellunit.." via "..nextbind.." as "..macro)
        end
        CreateButton(spellunit,nextbind,macro)
    end
end

--BindMacroToUnits(_assist,hostile_units,"/assist ","" ) => creates the macros "/assist Party1" to "/assist Party4" etc
function BindMacroToUnits(spell,units,prefix,suffix)
    --print("Binding ",spell," to ",units[1]," et al")
    for i,unit in ipairs(units) do
        --shh_binding_announcements = unit ~= "target"
        BindSpellToUnit(spell,unit,prefix..unit..suffix,nil,_skipSpell)
    end
end

function BindSpellToUnits(spell,units,prefix,suffix,skipcontents,DelegateMacroCreation)
    --print("Binding ",spell," to ",units[1]," et al")
    for i,unit in ipairs(units) do
        --shh_binding_announcements = unit ~= "target"
        BindSpellToUnit(spell,unit,prefix,suffix,skipcontents,DelegateMacroCreation)
    end
end

function CreateUseMacroText(spell,unit)
    if (unit==_null)then
        return "/use "..spell
    else
        return "/use [@"..unit.."] "..spell
    end
end

function CreateCastMacrotext(spell,unit)
    if (unit==_null)then
        return "/cast "..spell
    else
        return "/cast [@"..unit.."] "..spell
    end
end

function CreateClickMacrotext(spell,unit)
    if (unit==_null)then
        return "/click "..spell
    else
        return "/click [@"..unit.."] "..spell
    end
end

--/run CreateButton("test","U","/say hi")
function CreateButton(spellunit,bind,macrotext)
    _button[spellunit] = CreateFrame("Button", bind, UIParent, "SecureActionButtonTemplate")
    _button[spellunit]:SetAttribute("type", "macro")
    SetOverrideBindingClick(_button[spellunit], true, bind, bind);
    _button[spellunit]:SetAttribute("macrotext", macrotext)
    _combo_status[bind] = true -- _combo_status["LSHIFT-4"]
    _button[spellunit]:RegisterForClicks("AnyDown","AnyUp")
    print("creating button using spellunit: "..spellunit.." bind: "..bind.. " macro: "..macrotext)
end

--print("Core_Input_Keybinds.lua loaded")
