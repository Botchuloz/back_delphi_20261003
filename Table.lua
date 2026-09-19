function update_table(dict_of_dicts,row,col,value)
    if type(dict_of_dicts) ~= "table" then
        dict_of_dicts = {}
    end


    if not dict_of_dicts[row] then
        dict_of_dicts[row] = {}
    end


    dict_of_dicts[row][col] = value
end


function insert_if_missing(dict,k,v)
    if not dict[k] then
        dict[k] = v
    end
    return dict
end


function select_row(dict_of_dicts,row)
    if not dict_of_dicts[row] then
        dict_of_dicts[row] = {}
    end
    return dict_of_dicts[row]
end


function count_table(t)
    local count = 0
    for k,v in next,t do
        count = count + 1
    end
    return count
end


function SafeNumber(value, fallback)
    if issecretvalue(value) then
        return fallback or 0
    end
    return value
end