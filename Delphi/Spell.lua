local _spell = delphi.spell

local spell_meta = {__index = function(t,spell) 
    local metric_data = {}
    local metric_meta = {}
    metric_meta.__index = 
        function(t,metric) -- delphi.spell["Corruption"]
            if 1==0 then 
            elseif metric == "ready" then -- delphi.spell["Corruption"].ready
                return C_Spell.IsSpellUsable(spell) and RemainingCooldown(spell) < 0.5
            elseif metric == "cooldown" then -- delphi.spell["Corruption"].cooldown
                return RemainingCooldown(spell) or 0
            elseif metric == "cd" then -- delphi.spell["Corruption"].cd
                return RemainingCooldown(spell) or 0
            elseif metric == "charges" then
                local spell_charges,spell_charges_timetillnext,spell_charges_timetillcap = RemainingCharges(spell)
                return spell_charges
            elseif metric == "charges_full_in" then
                local spell_charges,spell_charges_timetillnext,spell_charges_timetillcap = RemainingCharges(spell)
                return spell_charges_timetillcap
            elseif metric == "charges_next_in" then
                local spell_charges,spell_charges_timetillnext,spell_charges_timetillcap = RemainingCharges(spell)
                return spell_charges_timetillnext
            elseif metric == "base_cooldown" then -- /run print(delphi.spell["Penance"].base_cooldown)  /run print(delphi.spell[47540].base_cooldown)
                return BaseCooldown(spell) or 0
            else -- _unit[unit].resource.???
                print("Unknown 'metric' in table:delphi.spell[",spell,"].",metric)
                return -1
            end
        end
    setmetatable(metric_data,metric_meta)
    return metric_data   
end}
setmetatable(_spell,spell_meta)

print("Spell.lua")
