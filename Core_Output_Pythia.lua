--[[
 ███████████  █████ █████ ███████████ █████   █████ █████   █████████  
░░███░░░░░███░░███ ░░███ ░█░░░███░░░█░░███   ░░███ ░░███   ███░░░░░███ 
 ░███    ░███ ░░███ ███  ░   ░███  ░  ░███    ░███  ░███  ░███    ░███ 
 ░██████████   ░░█████       ░███     ░███████████  ░███  ░███████████ 
 ░███░░░░░░     ░░███        ░███     ░███░░░░░███  ░███  ░███░░░░░███ 
 ░███            ░███        ░███     ░███    ░███  ░███  ░███    ░███ 
 █████           █████       █████    █████   █████ █████ █████   █████
░░░░░           ░░░░░       ░░░░░    ░░░░░   ░░░░░ ░░░░░ ░░░░░   ░░░░░    
--]]
local print = DelphiPrint
local _global_pythia             = delphi.pythia
local _spellunit_to_keycombo    = delphi.bind.spellunit_to_keycombo
local _spellunit_key            = delphi.keycombo.key_ascii
local _spellunit_mod            = delphi.keycombo.mod_ascii
local _safetycheck = 37

function CreatePythia(pythia_name,x,y,size)
    local _pythia = {}
    --create it's frame
    _pythia.name = pythia_name
    _pythia.frame = CreateFrame("Frame", nil, UIParent)
    _pythia.frame:SetFrameStrata ("TOOLTIP")
    _pythia.frame:SetWidth (size)
    _pythia.frame:SetHeight (size)
    --creeate it's colour/texture
    _pythia.colour = _pythia.frame:CreateTexture (nil, "OVERLAY")
    _pythia.colour:SetColorTexture (0, 0, 0)
    _pythia.colour:SetAllPoints (_pythia.frame)
    _pythia.frame.texture = _pythia.colour _pythia.frame:SetPoint ("TOPLEFT", -x, -y) _pythia.frame:Show ()

    --used to set pythia by a spell-unit combo, the unit portion is optional
    _pythia.SetSpellUnit = 
        function (spell,unit)
            local spellunit = spell..(unit or _null)
            --tell me if the spellunit isn't bound
            if not _spellunit_to_keycombo[spellunit] then
                print("BIND MISSING => spell:",spell," unit:",unit)
            else
                local bind = _spellunit_to_keycombo[spellunit]
                local mods = _spellunit_mod[bind]
                local key  = _spellunit_key[bind]

                local last_spellunit = _pythia.last_spellunit or ""

                if(spellunit ~= last_spellunit)then
                    --print(_pythia.name.." : "..spell.." @ "..unit)
                    _pythia.last_unit = unit
                    _pythia.last_spell = spell
                    _pythia.last_spellunit = spellunit
                    --print(_pythia.last_spellunit)
                end
                GreenlistSpellUnit(spell,unit)
                _pythia.colour:SetColorTexture (_safetycheck/255.0,mods/255.0,key/255.0)
                --print("Set the pythia by spellunit")
            end
        end
    --used to turn pythia off
    _pythia.Off = 
        function ()
            _pythia.colour:SetColorTexture (0,0,0) --> alternative syntax, _pythia.colour:SetColorTexture (_pythia.colour,r/255.0,g/255.0,b/255.0)
        end
    --just used for testing
    _pythia.SetColour = 
        function (r,g,b)
            _pythia.colour:SetColorTexture (_pythia.colour,r/255.0,g/255.0,b/255.0) --> alternative syntax, _pythia.colour.SetColorTexture (_pythia.colour,r/255.0,g/255.0,b/255.0)
        end

    --create our new pythia
    _global_pythia[pythia_name] = _pythia
end


--[[dragonflight zero day]]
CreatePythia("global",0,0,2)
CreatePythia("instant",0,2,2) 
--[[/dragonflight zero day]]

-- /run delphi.pythia.instant.SetColour(250,0,250)
-- /run delphi.pythia.global.SetColour(0,252,250)
-- /run delphi.pythia.instant.SetSpellUnit("lifetap","player")


print("Core_Output_Pythia.lua")
