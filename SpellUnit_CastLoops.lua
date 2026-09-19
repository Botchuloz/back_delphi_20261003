_global  = delphi.pythia.global

function CheckLogicDelegates(spell,unit,delegates)
    if delegates == nil then
        return true
    end

    if type(delegates) == "function" then
        return delegates(spell,unit)
    end

    if type(delegates) == "table" then
        for i,delegate in pairs(delegates) do --for k,v in pairs(delegates) do
            if not delegate(spell,unit) then
                return false
            end
        end
        return true
    end

    return false
end

function CheckRankDelegates(spell,unit,delegates)
    if delegates == nil then
        return true
    end

    if type(delegates) == "function" then
        return delegates(spell,unit)
    end

    if type(delegates) == "table" then
        print("RANK DOES NOT SUPPORT ARRAYS OF DELEGATES, ONLY A SINGLE DELEGATE")
        return -1
    end

    return -1
end

function CastSpellUnits(spell,units,logic,delegates_logic,delegates_rank)
    if not logic then
        return false
    end

    local unit_scores = {}
    for i,unit in pairs(units) do
        logic_result = CheckLogicDelegates(spell,unit,delegates_logic)
        if delegates_rank == nil then
            if logic_result then
                _global.SetSpellUnit(spell,unit)
                return true
            end
        else
            if logic_result then
                local rank_result = CheckRankDelegates(spell,unit,delegates_rank)
                unit_scores[unit] = rank_result
            end
        end
    end

    best_score = 0
    best_unit  = ""
    for unit,score in pairs(unit_scores) do
        if score > best_score then
            best_unit = unit
            best_score = score
        end
    end

    if best_unit ~= "" then
        _global.SetSpellUnit(spell,best_unit)
        return true
    end

    return false
end
