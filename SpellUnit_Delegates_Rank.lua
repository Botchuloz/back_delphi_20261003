local print = DelphiPrint

print("hi")

--/run print(RankUnits_BrezTargets("","player"))
function RankUnits_BrezTargets(spell,unit)
    local unit_class = UnitClass(unit) or ""
    local unit_role  = UnitGroupRolesAssigned(unit) or ""

    if unit_role == "HEALER" then
        return 999  
    elseif unit_role == "TANK" then
        return 888
    elseif unit_role == "DAMAGER" or unit_role == "NONE" then
        if unit_class == "Druid" then
            return 777
        elseif unit_class == "Death Knight" then
            return 666
        else
            return 100
        end
    else 
        print("Unknown unit_class : ",unit_class)
        return -1
    end
end

function RankUnits_MaxHealthDeficit(spell,unit)
    return delphi.unit[unit].health.deficit
end

function RankUnits_MaxHealthDeficitPercent(spell,unit)
    return delphi.unit[unit].health.deficit_percent
end

function SpellUnit_RankPositiveForXkdAndNegativeForAnyoneElse(spell,unit)
    if UnitName(unit) == "Xkd" then
        print("unit ",unit," is important")
        return 100
    end
    print("unit ",unit," is not important")
    return -1
end
